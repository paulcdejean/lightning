#!/bin/bash
set -e

# Sleeps until the network is online
/usr/bin/nm-online -q -t 300

echo "${cluster_name}" > /etc/lightning/cluster_name.txt
