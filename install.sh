#!/bin/bash
efi_platform=$(</sys/firmware/efi/fw_platform_size)

pacman -Sy jq ansible

set -e

echo "$efi_platform" | grep -qwE '32|64' || {
  echo "Not in UEFI mode!"
  exit 1
}

nc -dzw1 8.8.8.8 443 >/dev/null 2>&1 || {
  echo "No internet connection!"
  exit 1
}

timedatectl set-ntp true

#list all unpartitioned disks, needs improvement
lsblk --json -o NAME,TYPE,FSTYPE,MOUNTPOINT | jq -r '.blockdevices[] | select(.type == "disk" and (.children == null or .children == [])) | .name'

read -p "Enter the disk to partition: " DISK

parted /dev/$DISK --script mklabel gpt
parted /dev/$DISK --script mkpart primary fat32 1MiB 513MiB
parted /dev/$DISK --script set 1 esp on

parted /dev/$DISK --script mkpart primary btrfs 513MiB 100%
