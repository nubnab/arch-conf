#!/bin/bash

sudo pacman -Sy

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sudo sed -i '/^#\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|}' /etc/pacman.conf
sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf

yay -Syu

yay -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

sudo sed -i 's|^MODULES=()|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' /etc/mkinitcpio.conf
sudo sed -i '/^HOOKS=/ s|modconf kms keyboard|modconf keyboard|' /etc/mkinitcpio.conf

sudo mkdir -p /etc/pacman.d/hooks/ 
sudo mv nvidia.hook /etc/pacman.d/hooks/

sudo pacman -Sy linux-headers vim fastfetch kitty thunar sddm waybar xdg-desktop-portal-hyprland hyprland \
                polkit-gnome firefox wget unzip rofi-wayland swaync swww qt5-wayland qt6-wayland cliphist \
                thunar-volman thunar-archive-plugin ark unrar gvfs tumbler brightnessctl slurp nwg-look \
                network-manger-applet grim swappy gnome-themes-extra gtk-engine-murrine steam starship \
                bluez bluez-utils hyprlock hypridle gamemode lib32-gamemode ttf-font-awesome \
                otf-font-awesome ttf-fira-sans ttf-fira-code ttf-firacode-nerd noto-fonts-cjk --noconfirm

yay -S waypaper hyprland-qtutils vesktop gimgv intellij-toolbox wlogout qogir-gtk-theme qogir-icon-theme --noconfirm

sudo mkinitcpio -P

sudo usermod -aG gamemode $USER

sudo systemctl enable sddm.service
