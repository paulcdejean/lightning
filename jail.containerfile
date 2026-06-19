from quay.io/fedora/fedora:44
run dnf install unzip ripgrep fd git -y
run git config --global user.name "Lightning Agent" && git config --global user.email "agent@lightning.local"
run curl -fsSL https://bun.com/install | bash
run ln -s /root/.bun/bin/bun /usr/local/bin/bun
run ln -s /root/.bun/bin/bun /usr/local/bin/node
run ln -s /root/.bun/bin/bun /usr/local/bin/npm
run bun install -g --ignore-scripts @earendil-works/pi-coding-agent
run ln -s /root/.bun/bin/pi /usr/local/bin/pi
run curl -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh \
    && sh /tmp/install-opentofu.sh --install-method standalone \
    && rm /tmp/install-opentofu.sh
copy jail/settings.json /root/.pi/agent/settings.json
workdir /root/lightning/
