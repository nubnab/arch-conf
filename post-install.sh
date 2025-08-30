#!/bin/bash

sudo pacman -Sy

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sudo sed -i '/^#\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|}' /etc/pacman.conf
sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf

yay -Sy

sudo mkdir -p /etc/pacman.d/hooks/ 
sudo mv nvidia.hook /etc/pacman.d/hooks/

sudo pacman -Sy linux-headers vim fastfetch kitty thunar sddm waybar xdg-desktop-portal-hyprland hyprland \
                polkit-gnome firefox wget unzip rofi-wayland swaync swww qt5-wayland qt6-wayland cliphist \
                thunar-volman thunar-archive-plugin ark unrar gvfs tumbler brightnessctl slurp nwg-look \
                network-manager-applet grim swappy gnome-themes-extra gtk-engine-murrine steam starship \
                mangohud lib32-mangohud bluez bluez-utils hyprlock hypridle gamemode vala lib32-gamemode \
                yazi btop nvtop vulkan-tools mesa-utils ttf-font-awesome otf-font-awesome ttf-fira-sans \
                ttf-fira-code ttf-firacode-nerd noto-fonts-cjk --noconfirm

yay -S waypaper hyprland-qtutils vesktop qimgv intellij-toolbox wlogout qogir-gtk-theme qogir-icon-theme \
       github-desktop nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings --noconfirm

sudo sed -i 's|^MODULES=()|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' /etc/mkinitcpio.conf
sudo sed -i '/^HOOKS=/ s|modconf kms keyboard|modconf keyboard|' /etc/mkinitcpio.conf

cp -rf config/. ~/.config/
cp -rf local/. ~/.local/

sudo mkinitcpio -P

sudo usermod -aG gamemode $USER

git clone https://github.com/radiolamp/mangojuice.git && cd mangojuice
meson setup build
sudo ninja -C build install

sudo systemctl enable sddm.service
