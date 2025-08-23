#!/bin/bash

timedatectl set-ntp true

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sudo sed -i '/^#\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|}' /etc/pacman.conf
sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf

yay -Syu

yay -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

sudo mkdir -p /etc/pacman.d/hooks/ && sudo mv nvidia.hook /etc/pacman.d/hooks/

sudo pacman -S vim fastfetch alacritty thunar sddm waybar xdg-desktop-portal-hyprland hyprland firefox

sudo systemctl enable sddm.service
