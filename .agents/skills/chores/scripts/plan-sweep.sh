#!/usr/bin/env bash
# plan-sweep.sh — run `tofu init -upgrade` then `tofu plan` in every tofu folder.
#
# Hard rules enforced by this script (see SKILL.md):
#   * sequential, never parallel
#   * never holds the state lock   (-lock=false)
#   * fully non-interactive        (-input=false)
#   * no color                     (-no-color)
#   * bounded per step             (timeout)
#
# Logs: /tmp/plan_<folder>.log
# Exit codes per folder are printed; a final summary greps for warnings.
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

# Discover tofu folders from the git tree (deterministic order).
mapfile -t FOLDERS < <(git ls-files '*/tofu.tf' | sed 's#/tofu.tf$##' | sort)

if [[ ${#FOLDERS[@]} -eq 0 ]]; then
  echo "No tofu.tf folders found under $ROOT" >&2
  exit 1
fi

# Ensure tofu is on PATH (sandbox installs to /usr/local/bin).
command -v tofu >/dev/null || { echo "tofu not found on PATH" >&2; exit 1; }

TIMEOUT=600   # seconds per init and per plan
FAIL=0

for d in "${FOLDERS[@]}"; do
  name="${d//\//_}"          # flatten, though top-level folders have no '/'
  log="/tmp/plan_${name}.log"
  echo "==============================================================="
  echo "### $d"
  echo "---------------------------------------------------------------"

  echo "--- tofu init -upgrade ---"
  timeout "$TIMEOUT" tofu -chdir="$d" init -upgrade -input=false -no-color \
        >"$log" 2>&1
  ec=$?
  if [[ $ec -ne 0 ]]; then
    echo "[$d] init FAILED (exit $ec)"; tail -n 30 "$log"; FAIL=1; continue
  fi

  echo "--- tofu plan -lock=false -input=false -no-color ---"
  # Append plan to the same log so the whole folder's story is in one file.
  if timeout "$TIMEOUT" tofu -chdir="$d" plan -lock=false -input=false -no-color \
        >>"$log" 2>&1; then
    ec=0
  else
    ec=$?
  fi
  echo "[$d] plan exit=$ec"
  # Show the action summary + any non-clean detail.
  tail -n 25 "$log"

  # Non-zero plan exit is a failure (0 == clean "No changes" or a diff plan).
  # A clean plan with changes still exits 0, so classify via the summary line.
  if [[ $ec -ne 0 ]]; then FAIL=1; fi
done

echo "==============================================================="
echo "### Warning / deprecation scan across all logs"
echo "---------------------------------------------------------------"
hits=0
for d in "${FOLDERS[@]}"; do
  name="${d//\//_}"
  log="/tmp/plan_${name}.log"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "[$d] $line"
    hits=1
  done < <(grep -iE 'warn|deprecat' "$log" 2>/dev/null \
            | grep -viE 'No changes|infrastructure matches')
done
[[ $hits -eq 0 ]] && echo "(no warning/deprecation lines found)"

echo "==============================================================="
echo "Logs:"
for d in "${FOLDERS[@]}"; do
  echo "  /tmp/plan_${d//\//_}.log"
done

exit "$FAIL"
