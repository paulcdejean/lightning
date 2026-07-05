from quay.io/fedora/fedora:44

# Base tooling: VCS + GitHub CLI, AWS/jq/search utilities, Node (MCP/tooling),
# and the C/Python build deps the Hermes Agent's Python install compiles native
# wheels against. The Hermes installer only auto-installs build tools on
# Debian/Ubuntu, so on Fedora we provide them up front.
run dnf install -y \
    git gh awscli jq unzip ripgrep fd \
    python3 python3-pip python3-devel gcc gcc-c++ libffi-devel \
    nodejs npm \
    chromium chromium-headless chromium-common

# uv/uvx — astral.sh's fast Python package runner. Used by the aws-mcp MCP
# server (stdio) to launch mcp-proxy-for-aws via uvx. Pre-install the proxy
# tool in the image so the MCP server starts instantly on boot (uvx would
# otherwise download + resolve deps on first invocation, adding ~10s latency).
run curl -fsSL https://astral.sh/uv/install.sh | sh \
    && ln -sf /root/.local/bin/uv /usr/local/bin/uv \
    && ln -sf /root/.local/bin/uvx /usr/local/bin/uvx \
    && uv tool install mcp-proxy-for-aws
# /root/.local/bin is where uv tool install places binaries (like
# mcp-proxy-for-aws).  The uv installer only adds it to PATH via shell
# profile hooks (.bash_profile), which don't apply to the bare container
# runtime (ENTRYPOINT runs hermes directly, not a login shell).  Set it
# at the image level so all processes find uv-managed binaries.
env PATH=/root/.local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin

# Podman — rootless container runtime for nested containers (Docker-compatible).
# The jail runs inside an Apple/macOS container on the host.  Rootless podman
# re-execs into its own user namespace and provides a full OCI container engine
# inside the jail (podman-in-container / DinD pattern).  crun is the low-level
# OCI runtime; fuse-overlayfs provides overlay-filesystem support for rootless
# mode; slirp4netns provides user-mode TCP/IP networking for nested containers.
run dnf install -y podman crun fuse-overlayfs slirp4netns
# Configure UID/GID subordinate ID ranges for rootless podman.  We're uid 0
# inside the jail (mapped from the macOS container runtime's user namespace).
# Podman re-execs into a nested user namespace and needs 65536 subordinate IDs
# so nested containers can map their own root user and other UIDs/GIDs.
run echo "root:100000:65536" > /etc/subuid \
    && echo "root:100000:65536" > /etc/subgid

run dnf install -y \
    sqlite yq iproute bind-utils sipcalc ipcalc which \
    wget tmux htop nmap-ncat vim-enhanced helm python3-pyyaml
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

# agent-browser CLI — Hermes's local browser automation backend. The npm package
# provides the agent-browser binary that drives headless Chromium via CDP.
run npm install -g agent-browser

# Verify browser stack works: agent-browser CLI + headless Chromium can
# navigate and snapshot a page.  The GITHUB_REF/HEAD env avoids real network;
# we just confirm the binary launches and can open a page via the local CDP
# daemon.  This prevents shipping an image where the browser deps silently
# drifted.
run agent-browser --version \
    && AGENT_BROWSER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
       agent-browser open https://example.com 2>/dev/null \
    && echo "browser smoke test: PASS"

# Nous Hermes Agent. Headless install: no setup wizard (we supply config.yaml
# below). Running as root on Linux, the installer symlinks the venv
# entrypoint to /usr/local/bin/hermes. HERMES_HOME is set to /root/.hermes here
# only to tell the installer where to place the initial config and bundled
# skills; at runtime entrypoint.sh leaves it unset so Hermes uses the default
# (/root/.hermes, ephemeral in the image) and symlinks skills/ + memories/ into
# the bind mount for persistence across rebuilds.
run curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
    | env HERMES_HOME=/root/.hermes bash -s -- --non-interactive --skip-setup --skip-browser

# OpenRouter server-tools plugin. Advertises OpenRouter server tools
# (web_search, web_fetch, datetime, ... — configured in jail/config.yaml) to the
# model and injects their declarations into the API request; OpenRouter executes
# them server-side.
copy plugins/openrouter-server-tools /root/.hermes/plugins/openrouter-server-tools

# Hermes config
copy jail/config.yaml /root/.hermes/config.yaml
copy jail/entrypoint.sh /root/entrypoint.sh
run chmod +x /root/entrypoint.sh

workdir /root/lightning/
entrypoint ["/root/entrypoint.sh"]
cmd ["hermes"]
