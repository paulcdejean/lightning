#!/bin/bash
set -euo pipefail

export AWS_USE_DUALSTACK_ENDPOINT=true
export AWS_PAGER=""

if [[ ! -f /etc/lightning/cluster_name.txt ]] ; then
    echo "/etc/lightning/cluster_name.txt was not found, so we don't know the name of the cluster we should join"
    exit 1
fi

if grep -q '[$%\\/;: ]' /etc/lightning/cluster_name.txt ; then
  echo "/etc/lightning/cluster_name.txt contains invalid characters"
  exit 1
fi

instance_id=$(ec2-metadata --instance-id --quiet)
availability_zone=$(ec2-metadata --availability-zone --quiet)
region=$(ec2-metadata --region --quiet)
private_hostname=$(ec2-metadata --local-hostname --quiet)

ipv4_info=$(ip -json -br -4 addr show scope global)
ipv4_addr=$(jq -r '.[0]["addr_info"][0]["local"]' <<< "$ipv4_info")
ipv4_length=$(jq -r '.[0]["addr_info"][0]["prefixlen"]' <<< "$ipv4_info")
adder_number="$(( 2 ** (31 - $ipv4_length) ))"
eni_addr=$(python3 -c "import ipaddress; print(ipaddress.IPv4Address('$ipv4_addr') + $adder_number)")
eni_info=$(aws --output json ec2 describe-network-interfaces --filters "Name=private-ip-address,Values=$eni_addr")
ipv6_prefix=$(jq -r '.NetworkInterfaces[0].Ipv6Prefixes[0].Ipv6Prefix' <<< "$eni_info")
eni_id=$(jq -r '.NetworkInterfaces[0].NetworkInterfaceId' <<< "$eni_info")
eni_mac=$(jq -r '.NetworkInterfaces[0].MacAddress' <<< "$eni_info")
instance_id=$(ec2-metadata --instance-id --quiet)

cat | tee /etc/systemd/network/10-kube.link << HEREDOC
[Match]
MACAddress=$eni_mac

[Link]
Name=kube
HEREDOC

# Required to pick up the new link file.
udevadm control --reload

aws ec2 attach-network-interface --network-interface-id "$eni_id" --instance-id "$instance_id" --device-index 1
udevadm wait /sys/class/net/kube
ip addr add "$ipv6_prefix" dev kube
ip a

cluster_name=$(cat /etc/lightning/cluster_name.txt)
cluster_endpoint=$(aws eks describe-cluster --name lightning-unstable --query "cluster.endpoint" --output text)

# Put the ca data to a file
aws eks describe-cluster --name lightning-unstable --query "cluster.certificateAuthority.data" --output text | base64 -d > /etc/lightning/pki_ca.crt

# Configure kube client config
sed -i \
  -e s%__SERVER__%$cluster_endpoint% \
  -e s%__CLUSTER__%$cluster_name% \
  -e s%__REGION__%$region% \
  /etc/lightning/kube_client_config.yaml

# Configure kubelet config
sed -i \
  -e s%__ZONE__%$availability_zone% \
  -e s%__INSTNACE__%$instance_id% \
  /etc/lightning/kublet_config.yaml

# Notes:
# Cluster name format according to the AWS console:
# "The cluster name should begin with letter or digit and can have any of the following characters:
# the set of Unicode letters, digits, hyphens and underscores. Maximum length of 100."
# --node-ip=:: according to the docs:
# "You can pass '::' to make it prefer the default IPv6 address rather than the default IPv4 address."

exec /usr/bin/kubelet \
  --image-credential-provider-config=/etc/lightning/credential_provider_config.yaml \
  "--node-ip=::" \
  --cloud-provider=external \
  --hostname-override=$private_hostname \
  --config=/etc/lightning/kublet_config.yaml \
  --kubeconfig=/etc/lightning/kube_client_config.yaml \
  --image-credential-provider-bin-dir=/usr/local/bin
