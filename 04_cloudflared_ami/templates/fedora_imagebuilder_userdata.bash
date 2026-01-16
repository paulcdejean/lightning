#!/bin/bash
set -e

# Can prevent some dnf error spam
echo "ip_resolve=6" >> /etc/dnf/dnf.conf

# Sleeps until the network is online
/usr/bin/nm-online -q -t 300

curl --retry 5 --retry-all-errors --no-progress-meter -L https://s3.dualstack.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/linux_arm64/amazon-ssm-agent.rpm -o /tmp/amazon-ssm-agent.rpm
dnf install -y /tmp/amazon-ssm-agent.rpm
rm /tmp/amazon-ssm-agent.rpm
