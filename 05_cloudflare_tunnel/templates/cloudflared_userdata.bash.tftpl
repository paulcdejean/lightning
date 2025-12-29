#!/bin/bash
set -e

# Sleeps until the network is online
/usr/bin/nm-online -q -t 300

tunnel_token=$(aws secretsmanager get-secret-value --secret-id ${secret_id} --query SecretString --output text)

mkdir -p /root/.cloudflared/

cat > /root/.cloudflared/config.yml << HEREDOC
tunnel: ${tunnel_id}
token: $tunnel_token
edge-ip-version: "6"
warp-routing:
  enabled: true
HEREDOC
