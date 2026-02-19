#!/bin/bash
set -euo pipefail

lsblk -I 259 -dpn

for disk in $(lsblk -I 259 -dpno NAME) ; do
  ebs_id=$(PYTHONWARNINGS="ignore" ebsnvme-id -b $disk)
  if [[ "$ebs_id" == "${container_volume_device_name}" || "$ebs_id" == "/dev/${container_volume_device_name}" ]] ; then
    mkfs.btrfs -f $disk
    filesystem_uuid=$(blkid -o value -s UUID $disk)
    echo "UUID=$filesystem_uuid /var/lib/containerd btrfs compress=zstd:1 0 0" >> /etc/fstab
    systemctl daemon-reload
    mount -a
  fi
done
