#!/bin/bash
efi_plaftorm=$(</sys/firmware/efi/fw_platform_size)

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

fdisk -l
