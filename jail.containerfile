from quay.io/fedora/fedora:44
run dnf install unzip ripgrep fd git awscli jq -y
run git config --global user.name "Lightning Agent" && git config --global user.email "agent@lightning.local"
run curl -fsSL https://bun.com/install | bash
run ln -s /root/.bun/bin/bun /usr/local/bin/bun
run ln -s /root/.bun/bin/bun /usr/local/bin/node
run ln -s /root/.bun/bin/bun /usr/local/bin/npm
run bun install -g --ignore-scripts @earendil-works/pi-coding-agent
run ln -s /root/.bun/bin/pi /usr/local/bin/pi
run curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | CONFIGURE=false GOOSE_BIN_DIR=/usr/local/bin bash
run curl -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh \
    && sh /tmp/install-opentofu.sh --install-method standalone \
    && rm /tmp/install-opentofu.sh
copy jail/settings.json /root/.pi/agent/settings.json
copy jail/mcp.json /root/.pi/agent/mcp.json
copy jail/models.json /root/.pi/agent/models.json
run cd /root/.pi/agent && bun add --ignore-scripts pi-mcp-adapter@2.10.0
workdir /root/lightning/
cmd /root/.bun/bin/pi
