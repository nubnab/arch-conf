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

#hyprlock
#hypridle
#starship
#picom -> screen tearing
#network-manager-applet
#blueman(?) bluez / bluez-utils
#xclip unecessary
#gnome-themes-extra
#gtk-engine-murrine

pacman -Sy linux-headers vim fastfetch kitty thunar sddm waybar xdg-desktop-portal-hyprland hyprland \
           firefox wget unzip rofi-wayland dunst swww qt5-wayland qt6-wayland cliphist \
           thunar-volman thunar-archive-plugin ark gvfs tumbler brightnessctl slurp \
           grim swappy ttf-font-awesome otf-font-awesome ttf-fira-sans ttf-fira-code \
           ttf-firacode-nerd noto-fonts-cjk nwg-look --noconfirm


yay -S waypaper hyprland-qtutils --noconfirm
#qogir-gtk-theme
#qogir-icon-theme
#wlogout
#gamemode
#proton
#wine

mkinitcpio -P

systemctl enable sddm.service
