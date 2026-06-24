#!/bin/bash
set -euo pipefail
# Launches the AI container jail

# TODO, start container system if it's stopped

# TODO, builder container might need to be relaunched to correct dns settings

# TODO, determine this automatically from container system settings
localhost_ip="203.0.113.113"

git_dir=$(git rev-parse --show-toplevel)

# TODO, rebuild from scratch if over 24 hours old, otherwise skip build
image_id=$(container build --dns $localhost_ip -f $git_dir/01_agent/jail.containerfile $git_dir/01_agent)

exec container run --rm --dns $localhost_ip --env-file $git_dir/01_agent/.env -v $git_dir:/root/lightning/ -it $image_id
