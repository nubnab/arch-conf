#!/bin/bash

sudo pacman -Sy

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sed -i '/^#\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|}' /etc/pacman.conf
sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf

yay -Syu

yay -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

sed -i 's|^MODULES=()|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' /etc/mkinitcpio.conf
sed -i '/^HOOKS=/ s|modconf kms keyboard|modconf keyboard|' /etc/mkinitcpio.conf

mkdir -p /etc/pacman.d/hooks/ 
mv nvidia.hook /etc/pacman.d/hooks/

pacman -Sy vim fastfetch kitty thunar sddm waybar xdg-desktop-portal-hyprland hyprland firefox

systemctl enable sddm.service
