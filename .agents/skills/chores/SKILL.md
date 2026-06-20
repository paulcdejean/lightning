---
name: chores
description: Run the lightning infra chores — check and bump OpenTofu required_version and provider versions across every tofu folder, check Fedora and EKS versions, run tofu init -upgrade and tofu plan in all folders, and report findings. Use when asked to "run chores" or maintain/upgrade terraform versions in this repo.
---

# Lightning infra chores

This skill is the **AI-maintained implementation** of the chore set. The
**human-maintained source of truth is [`chores.md`](../../../chores.md)** — the
list of requirements there is what this skill must satisfy. If `chores.md`
changes, update this skill (and its references) to stay in sync. `AGENTS.md`
just points here.

The procedure below is the "how"; `chores.md` is the "what".

## Hard rules (do not violate)

These come from `AGENTS.md` (Important notes) and `chores.md`.

- **Sequential, never parallel.** Process folders one at a time. `tofu init` and
  `tofu plan` must finish in a folder before moving on.
- **Never hold the state lock.** Every `tofu plan` uses `-lock=false`.
- **No web fetch / curl** for lookups. Use the opentofu MCP (provider versions),
  the `gh` CLI (OpenTofu releases, GitHub-hosted providers), and the `aws` CLI
  (EKS). If a needed MCP server is missing or `gh`/`aws` are unauthenticated,
  report it and **exit** — do not fall back to curl/web fetch.
- **Report-only items are not auto-applied.** EKS version and OpenTofu binary
  version are reported to the user, not bumped by the agent. The agent only
  edits terraform files and commits; the user applies infra changes.

## Coverage of `chores.md`

Every bullet in `chores.md` maps to a step here. When maintaining this skill,
keep this mapping accurate and complete.

| `chores.md` requirement | Step |
|---|---|
| No web fetch/curl; use MCP + `gh` + `aws`; report+exit if unavailable | Preflight |
| Do chores for each folder in the git source tree | Step 1 (discover) + sequential sweep |
| Prompt user to update OpenTofu if not latest | Step 3 (lookup) + Step 10 (report) |
| Update `tofu.tf` `required_version` to latest | Step 4 |
| Update `tofu.tf` providers to latest | Step 4 |
| If updates made, run `tofu init -upgrade` + `tofu plan` in all folders; report non-clean | Step 7 + Step 8 |
| Report provider deprecation warnings | Step 7 (scan) + Step 10 |
| Update major Fedora version if needed; report if updated | Step 5 |
| If EKS version < latest AWS-supported, report | Step 6 |

## Preflight (exit early on failure)

Run these checks first. If any fails, report and stop.

```bash
gh auth status            # must be authenticated (GH_TOKEN from .env)
aws sts get-caller-identity   # must be authenticated (lightning-agent)
tofu version              # installed binary
```

Then confirm MCP servers are connected via the MCP gateway:
- `opentofu` (provider version lookups)
- `cloudflare-docs` is optional but usually present

If `opentofu` MCP is unavailable, report and exit.

Record the installed `tofu` version for the OpenTofu report step.

## 1. Discover folders

Every directory in the git tree containing a `tofu.tf` is a chore target:

```bash
git ls-files '*/tofu.tf' | sed 's#/tofu.tf$##' | sort
```

Expected: `00_aws_users 01_ipspace 02_vpc 03_bastion 04_cloudflared_ami
05_cloudflare_tunnel 06_eks_cluster`.

## 2. Gather current versions

For each folder, read `tofu.tf` and record:
- `terraform { required_version = "…" }`
- every entry in `required_providers { … }` (source + version constraint)

## 3. Look up latest versions

Authoritative commands are in [references/version-sources.md](references/version-sources.md).
Summary:

- **OpenTofu**: `gh release view --repo opentofu/opentofu --json tagName -q .tagName`
- **Registry providers** (hashicorp/*, cloudflare/*, …): opentofu MCP — query the
  latest version for each provider source.
- **GitHub-only providers** (e.g. `Tobotimus/toml`): the opentofu MCP registry
  lookup 404s for these; fall back to
  `gh api repos/<org>/<repo>/releases/latest -q .tag_name` (strip a leading `v`).

Do **not** hardcode version numbers — look them up every run via the references.

## 4. Bump

For each folder where a pinned version is behind latest:
- set `required_version` to the latest OpenTofu version (if behind)
- set each `required_providers` version constraint to the latest

Edit `tofu.tf` only; do not hand-edit `.terraform.lock.hcl` — `tofu init
-upgrade` regenerates it.

## 5. Fedora major version

`jail.containerfile` pins the base image, e.g. `quay.io/fedora/fedora:44`.
Compare the pinned major to the latest Fedora stable. The container's own
`/etc/os-release` confirms what is running but does **not** prove "latest".

Preferred method (no curl/web fetch): use `skopeo` to list tags if available:
```bash
skopeo list-tags docker://quay.io/fedora/fedora 2>/dev/null \
  | grep -oE '"[0-9]+"' | tr -d '"' | sort -n | tail
```
If `skopeo` is absent, report that the Fedora-latest check could not be performed
mechanically and state the pinned vs. running version; let the user confirm.
Bump the major in `jail.containerfile` only if a newer stable major exists.

## 6. EKS version (report only)

- Cluster version: read `06_eks_cluster/workspace.tf` → `kube_version` for the
  active workspace (default workspace).
- Latest AWS-supported version: probe with the aws CLI in `us-east-2` — the
  highest `<v>` for which `describe-addon-versions` returns addons is the latest
  supported. Probe downward from a candidate (e.g. try 1.37, 1.36, …):
  ```bash
  aws eks describe-addon-versions --kubernetes-version <v> \
    --region us-east-2 --query 'addons[].addonVersion' --output text
  ```
  Empty output ⇒ that version is not yet supported.
- **Report** the gap. Do **not** bump `kube_version`. (EKS requires sequential
  minor upgrades; that's a user decision.)

## 7. Plan sweep (only if any edits were made in steps 4–5)

Run the helper — it is non-interactive, sequential, holds no lock, saves logs,
and surfaces warnings:

```bash
bash .agents/skills/chores/scripts/plan-sweep.sh
```

This runs `tofu init -upgrade` then `tofu plan -lock=false -input=false -no-color`
in every tofu folder, writes `/tmp/plan_<folder>.log`, and prints each folder's
exit code plus the tail of its log. At the end it greps every log for
deprecation/warning lines.

If **no** edits were made this run, skip the sweep (nothing changed to validate).

## 8. Interpret plans

- **Clean** = `No changes.` / `0 to add, 0 to change, 0 to destroy.`
- **Non-clean** = anything else. Investigate the diff. Distinguish:
  - *Environmental* drift (e.g. `03_bastion`'s `local_sensitive_file` for
    `/root/.ssh/bastion.pem`, which only exists on the admin host, not in this
    sandbox) — report as non-clean but not a config problem.
  - *Real* config drift — report and let the user decide.
- **Deprecation/prefer warnings** from providers: collect from the grep output
  and report each one.

## 9. Commit

Stage only the files the chore actually changed: bumped `tofu.tf` files, their
regenerated `.terraform.lock.hcl`, and `jail.containerfile` if Fedora moved.
Do **not** `git add -A`. Write a descriptive commit message listing every version
bump, the plan-sweep result per folder, the EKS gap, and the Fedora status.

## 10. Report to the user

Summarise:
1. Provider/OpenTofu version bumps made (folder, provider, old → new).
2. OpenTofu binary version vs latest (prompt the user to upgrade if behind).
3. Fedora: pinned vs latest; whether bumped.
4. EKS: cluster version vs latest AWS-supported; **report-only**.
5. Plan sweep: per-folder clean/non-clean; call out any environmental diffs.
6. Any provider deprecation/warning output.

Keep `handoff.md` (gitignored) updated with the run results for the next
iteration.
