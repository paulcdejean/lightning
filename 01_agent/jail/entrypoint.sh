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

# Pin HERMES_HOME inside the bind mount (/root/lightning) so that memories,
# skills, sessions, and state.db survive container rebuilds. The Hermes venv
# and code live at /usr/local/lib/hermes-agent (baked into the image) and are
# unaffected. On first run the image's /root/.hermes (populated during build
# by the installer + our COPY) is used as a seed; after that the bind mount
# is the source of truth.
export HERMES_HOME=/root/lightning/.hermes
mkdir -p "$HERMES_HOME"
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
  echo "entrypoint: seeding HERMES_HOME from /root/.hermes (first run)" >&2
  cp -a /root/.hermes/. "$HERMES_HOME/"
fi

# Hand off to the declared CMD (e.g. hermes).
exec "$@"
