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

if [[ "$DISK" == nvme* ]]; then
  EFI_PART="/dev/${DISK}p1"
  ROOT_PART="/dev/${DISK}p2"
else
  EFI_PART="/dev/${DISK}1"
  ROOT_PART="/dev/${DISK}2"
fi

mkfs.fat -F 32 /dev/$EFI_PART
mkfs.btrfs /dev/$ROOT_PART

mount /dev/$ROOT_PART /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

umount /mnt

mount -o compress=zstd,subvol=@ /dev/$ROOT_PART /mnt
mkdir -p /mnt/home
mount -o compress=zstd,subvol=@home /dev/$ROOT_PART /mnt/home

mkdir -p /mnt/efi
mount /dev/$EFI_PART /mnt/efi

pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs grub efibootmgr grub-btrfs \
inotify-tools timeshift amd-ucode networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack \
wireplumber reflector openssh man sudo

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

arch-chroot /mnt
