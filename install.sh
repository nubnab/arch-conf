#!/bin/bash
efi_platform=$(</sys/firmware/efi/fw_platform_size)

pacman -Sy jq

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

DISK_LOC="/dev/${DISK}"

parted $DISK_LOC --script mklabel gpt
parted $DISK_LOC --script mkpart primary fat32 1MiB 513MiB
parted $DISK_LOC --script set 1 esp on

parted $DISK_LOC --script mkpart primary btrfs 513MiB 100%

if [[ "$DISK" == nvme* ]]; then
  EFI_PART="/dev/${DISK}p1"
  ROOT_PART="/dev/${DISK}p2"
else
  EFI_PART="/dev/${DISK}1"
  ROOT_PART="/dev/${DISK}2"
fi

mkfs.fat -F 32 $EFI_PART
#investigate -f
mkfs.btrfs -f $ROOT_PART

mount $ROOT_PART /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

umount /mnt

mount -o compress=zstd,subvol=@ $ROOT_PART /mnt
mkdir -p /mnt/home
mount -o compress=zstd,subvol=@home $ROOT_PART /mnt/home

mkdir -p /mnt/boot
mount -o fmask=0137,dmask=0027 $EFI_PART /mnt/boot

pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs \
amd-ucode networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack \
nano wireplumber reflector openssh man sudo

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

read -p "Enter your username: " USERNAME

arch-chroot /mnt /bin/bash -c "
ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime &&
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&
locale-gen &&
echo \"LANG=en_US.UTF-8\" >> /etc/locale.conf &&
echo \"KEYMAP=us\" >> /etc/vconsole.conf &&
echo \"arch\" >> /etc/hostname &&
hwclock --systohc &&
passwd && 
useradd -m -G wheel -s /bin/bash ${USERNAME} &&
passwd ${USERNAME} &&
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers"

#bootctl --path=/boot install (in chroot)
#systemctl enable NetworkManager (in chroot)
cp nvidia.hook /mnt/home/$USERNAME
cp post-install.sh /mnt/home/$USERNAME

#umount -R /mnt

#reboot
