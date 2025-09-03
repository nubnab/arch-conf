#!/bin/bash

sudo pacman -Sy

base_dir=$(pwd)

cd ~ && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sudo sed -i '/^#\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|}' /etc/pacman.conf
sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf

yay -Sy

sudo pacman -S  linux-headers vim fastfetch kitty thunar sddm waybar xdg-desktop-portal-hyprland hyprland \
                polkit-gnome firefox wget unzip rofi-wayland swaync swww qt5-wayland qt6-wayland cliphist \
                thunar-volman thunar-archive-plugin unrar gvfs tumbler brightnessctl slurp nwg-look \
                network-manager-applet grim swappy gnome-themes-extra gtk-engine-murrine steam starship \
                mangohud lib32-mangohud bluez bluez-utils hyprlock hypridle gamemode vala lib32-gamemode 
                neovim yazi btop nvtop vulkan-tools mesa-utils rtorrent gtk-engines neovide \
                ttf-font-awesome otf-font-awesome ttf-fira-sans ttf-fira-code ttf-firacode-nerd noto-fonts-cjk --noconfirm

yay -S hyprland-qtutils nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings \
       waypaper vesktop qimgv jetbrains-toolbox wlogout --noconfirm
       
sudo sed -i 's|^MODULES=()|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' /etc/mkinitcpio.conf
sudo sed -i '/^HOOKS=/ s|modconf kms keyboard|modconf keyboard|' /etc/mkinitcpio.conf

sudo mkinitcpio -P

sudo mkdir -p /etc/pacman.d/hooks/ 
sudo cp "$base_dir/nvidia.hook" /etc/pacman.d/hooks/

sudo usermod -aG gamemode $USER

cd ~ && git clone https://github.com/radiolamp/mangojuice.git && cd mangojuice
meson setup build
sudo ninja -C build install

sudo systemctl enable sddm.service
#network manager

cd "$base_dir"
cp -rf "config/." ~/.config/
cp -rf "local/." ~/.local/

git clone https://github.com/vinceliuice/Qogir-theme && sh ./Qogir-theme/install.sh -c dark
git clone https://github.com/vinceliuice/Qogir-icon-theme && sh ./Qogir-icon-theme/install.sh
