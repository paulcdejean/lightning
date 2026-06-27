#!/usr/bin/env bash
# Container entrypoint for the lightning agent jail.
#
# Generates ~/.aws/config with a [profile cloudflare] pointing the S3 backend
# at Cloudflare R2, from the R2_* env vars that 01_agent/.env injects at runtime.
# This lets `tofu init`/`tofu plan` reach the S3-on-R2 state backend that every
# tofu.tf references via `profile = "cloudflare"`.
#
# The format mirrors the proven working ~/.aws/config used outside the sandbox.
# Whitespace in the [services cloudflare] nested block IS significant: the
# `endpoint_url` line must be indented by exactly two spaces under `s3 =`.
set -euo pipefail

mkdir -p "${HOME}/.aws"

if [ -n "${R2_ACCESS_KEY_ID:-}" ] && [ -n "${R2_SECRET_ACCESS_KEY:-}" ] && [ -n "${R2_ENDPOINT:-}" ]; then
  cat > "${HOME}/.aws/config" <<EOF
[profile cloudflare]
aws_access_key_id = ${R2_ACCESS_KEY_ID}
aws_secret_access_key = ${R2_SECRET_ACCESS_KEY}
services = cloudflare

[services cloudflare]
s3 =
  endpoint_url = ${R2_ENDPOINT}
EOF
  chmod 600 "${HOME}/.aws/config"
else
  echo "entrypoint: R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY / R2_ENDPOINT not set;" \
       "the [cloudflare] AWS profile will not be written and tofu cannot reach the R2 backend." >&2
fi

# HERMES_HOME stays at the image default (/root/.hermes) — config, sessions,
# logs, and state.db are ephemeral per rebuild, which is fine for a disposable
# jail. Only skills and memories need to survive rebuilds, so those two
# directories are symlinked into the bind mount at /root/lightning/.hermes-persist.
# The image's bundled skills are merged in on each startup (without clobbering
# agent-created skills) so Hermes updates bring fresh bundled skills through.
PERSIST=/root/lightning/.hermes-persist
mkdir -p "$PERSIST/skills" "$PERSIST/memories"

# Merge fresh bundled skills from the image into the persist dir. cp -an
# (archive, no-clobber) preserves agent-created/patched skills; new bundled
# skills from a Hermes update get added. Then replace the image dir with a
# symlink so skill_manage writes land in the persist dir.
if [ -d /root/.hermes/skills ] && [ ! -L /root/.hermes/skills ]; then
  cp -an /root/.hermes/skills/. "$PERSIST/skills/"
  rm -rf /root/.hermes/skills
fi
ln -sfn "$PERSIST/skills" /root/.hermes/skills

# Memories are purely agent-created (no bundled memories to seed).
if [ -d /root/.hermes/memories ] && [ ! -L /root/.hermes/memories ]; then
  rm -rf /root/.hermes/memories
fi
ln -sfn "$PERSIST/memories" /root/.hermes/memories

# Generate kubeconfig so tofu's kubernetes provider (08_cilium) can access
# the EKS cluster. Uses the default AWS credentials (the same ones that
# authenticate the S3 backend). Only run if EKS cluster is reachable;
# skip silently on first boot or auth failure so the agent still starts.
if [ -n "${AWS_ACCESS_KEY_ID:-}" ] || [ -n "${AWS_PROFILE:-}" ]; then
  if ! [ -f "${HOME}/.kube/config" ]; then
    aws eks update-kubeconfig \
      --name lightning-unstable \
      --alias lightning-unstable \
      --region "${AWS_REGION:-us-east-2}" 2>/dev/null || true
  fi
fi

# Hand off to the declared CMD (e.g. hermes).
exec "$@"
