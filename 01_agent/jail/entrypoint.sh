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

# Configure rootless podman storage on the persistent bind mount so container
# images and layers survive jail rebuilds.  The graph root lives under the
# persist dir alongside skills/ and memories/.  fusermount3 is needed for
# fuse-overlayfs (rootless overlay) and is already at /usr/bin/fusermount3.
PODMAN_PERSIST="${PERSIST}/podman"
mkdir -p "${PODMAN_PERSIST}/storage" "${PODMAN_PERSIST}/cache"
if [ ! -f "${HOME}/.config/containers/storage.conf" ]; then
  mkdir -p "${HOME}/.config/containers"
  cat > "${HOME}/.config/containers/storage.conf" <<EOF
[storage]
driver = "overlay"
graphroot = "${PODMAN_PERSIST}/storage"
rootless_storage_path = "${PODMAN_PERSIST}/storage"

[storage.options]
pull_options = {enable_partial_images = "false"}

[storage.options.overlay]
mount_program = "/usr/bin/fusermount3"
mountopt = "nodev,metacopy=on"
EOF
fi
# Enable ping/networking in rootless containers.  Without this, slirp4netns
# containers get ICMP blocked (ping fails), though TCP/UDP works fine via
# slirp's built-in DNS+TCP proxy.
# Also set XDG_RUNTIME_DIR for podman to use /run/user/0 (exists inside the
# user namespace after podman re-execs).
mkdir -p /run/user/0

# Generate kubeconfig so tofu's kubernetes provider (08_cilium) can access
# the EKS cluster. Uses the default AWS credentials (the same ones that
# authenticate the S3 backend). Only run if EKS cluster is reachable;
# skip silently on first boot or auth failure so the agent still starts.
# Write ~/.aws/credentials with a [default] profile so that AWS SDKs, CLI,
# and MCP servers (mcp-proxy-for-aws) can resolve credentials via the standard
# credential chain — without relying on env vars that get stripped from MCP
# subprocesses by Hermes's _build_safe_env filter.
if [ -n "${LIGHTNING_AWS_ACCESS_KEY_ID:-}" ] && [ -n "${LIGHTNING_AWS_SECRET_ACCESS_KEY:-}" ]; then
  cat > "${HOME}/.aws/credentials" <<EOF
[default]
aws_access_key_id = ${LIGHTNING_AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${LIGHTNING_AWS_SECRET_ACCESS_KEY}
EOF
  # Optional session token (only written if present, e.g. temporary STS creds)
  if [ -n "${LIGHTNING_AWS_SESSION_TOKEN:-}" ]; then
    echo "aws_session_token = ${LIGHTNING_AWS_SESSION_TOKEN}" >> "${HOME}/.aws/credentials"
  fi
  chmod 600 "${HOME}/.aws/credentials"
fi

if [ -n "${LIGHTNING_AWS_ACCESS_KEY_ID:-}" ] || [ -n "${AWS_PROFILE:-}" ]; then
  if ! [ -f "${HOME}/.kube/config" ]; then
    aws eks update-kubeconfig \
      --name lightning-unstable \
      --region "${LIGHTNING_AWS_REGION:-us-east-2}" 2>/dev/null || true
  fi

  # Fetch agent secrets from AWS Secrets Manager and export as env vars.
  # The IAM policy (01_agent/iam.tf) grants GetSecretValue on secret:agent/*.
  REGION="${LIGHTNING_AWS_REGION:-us-east-2}"

  # Context7 API key — used by the agent for context-aware tool calls.
  if CONTEXT7_API_KEY=$(aws secretsmanager get-secret-value \
    --secret-id agent/context7_api_key --region "$REGION" \
    --query SecretString --output text 2>/dev/null); then
    export CONTEXT7_API_KEY
  fi
fi

# Hand off to the declared CMD (e.g. hermes).
exec "$@"
