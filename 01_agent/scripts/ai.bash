#!/bin/bash
set -euo pipefail

if ! container system status > /dev/null ; then
  container system start
fi

localhost_ip="203.0.113.113"
git_dir=$(git rev-parse --show-toplevel)
tag=lightning-agent:$(date +%Y%m%d)

if ! container image inspect $tag > /dev/null ; then
  container build --pull --no-cache -t $tag --dns $localhost_ip -f $git_dir/01_agent/jail.containerfile $git_dir/01_agent
else
  container build --pull -t $tag --dns $localhost_ip -f $git_dir/01_agent/jail.containerfile $git_dir/01_agent
fi

exec container run --rm --dns $localhost_ip --env-file $git_dir/01_agent/.env -v $git_dir:/root/lightning/ -it $tag
