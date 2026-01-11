#!/bin/bash
set -e

if [[ ! -f /etc/lightning/cluster_name.txt ]] ; then
    echo "/etc/lightning/cluster_name.txt was not found, so we don't know the name of the cluster we should join"
    exit 1
fi

if grep -q '[$%\\/;:]' /etc/lightning/cluster_name.txt ; then
  echo "/etc/lightning/cluster_name.txt contains invalid characters"
  exit 1
fi

instance_id=$(ec2-metadata --instance-id --quiet)
availability_zone=$(ec2-metadata --availability-zone --quiet)
region=$(ec2-metadata --region --quiet)
cluster_name=$(cat /etc/lightning/cluster_name.txt)
cluster_endpoint=$(AWS_USE_DUALSTACK_ENDPOINT=true aws eks describe-cluster --name lightning-unstable --query "cluster.endpoint" --output text)

# Put the ca data to a file
AWS_USE_DUALSTACK_ENDPOINT=true aws eks describe-cluster --name lightning-unstable --query "cluster.certificateAuthority.data" --output text | base64 -d > /etc/lightning/pki_ca.crt

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
  --hostname-override=$instance_id \
  --config=/etc/lightning/kublet_config.yaml \
  --kubeconfig=/etc/lightning/kube_client_config.yaml \
  --image-credential-provider-bin-dir=/usr/local/bin
