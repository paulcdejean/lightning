from quay.io/fedora/fedora:44

# Base tooling: VCS + GitHub CLI, AWS/jq/search utilities, Node (MCP/tooling),
# and the C/Python build deps the Hermes Agent's Python install compiles native
# wheels against. The Hermes installer only auto-installs build tools on
# Debian/Ubuntu, so on Fedora we provide them up front.
run dnf install -y \
    git gh awscli jq unzip ripgrep fd \
    python3 python3-pip python3-devel gcc gcc-c++ libffi-devel \
    nodejs npm
run dnf install -y \
    sqlite yq iproute bind-utils sipcalc ipcalc which \
    wget tmux htop nmap-ncat vim-enhanced helm
run git config --global user.name "Lightning Agent" && git config --global user.email "agent@lightning.local"

# kubectl (not in Fedora repos, install from Kubernetes upstream)
run KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt) \
    && curl -fsSL -o /usr/local/bin/kubectl \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# OpenTofu (terraform state lives on Cloudflare R2 via the [cloudflare] AWS
# profile that entrypoint.sh writes from the R2_* env vars).
run curl -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh \
    && sh /tmp/install-opentofu.sh --install-method standalone \
    && rm /tmp/install-opentofu.sh

# Nous Hermes Agent. Headless install: no setup wizard (we supply config.yaml
# below) and no browser/Playwright stack (this agent does infra work, not web
# automation). Running as root on Linux, the installer symlinks the venv
# entrypoint to /usr/local/bin/hermes. HERMES_HOME is set to /root/.hermes here
# only to tell the installer where to place the initial config and bundled
# skills; at runtime entrypoint.sh leaves it unset so Hermes uses the default
# (/root/.hermes, ephemeral in the image) and symlinks skills/ + memories/ into
# the bind mount for persistence across rebuilds.
run curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
    | env HERMES_HOME=/root/.hermes bash -s -- --non-interactive --skip-setup --skip-browser

# Hermes config: OpenRouter (OpenAI-compatible router) as a custom provider
# keyed off OPENROUTER_API_KEY, defaulting to GLM 5.2 with :online web search,
# plus the OpenTofu / Cloudflare docs MCP servers. OPENROUTER_API_KEY and the
# AWS/Cloudflare creds are injected at runtime from 01_agent/.env (container run
# --env-file 01_agent/.env).
copy jail/config.yaml /root/.hermes/config.yaml
copy jail/entrypoint.sh /root/entrypoint.sh
run chmod +x /root/entrypoint.sh

workdir /root/lightning/
entrypoint ["/root/entrypoint.sh"]
cmd ["hermes"]
