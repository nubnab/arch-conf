#!/bin/bash

timedatectl set-ntp true

sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /etc/systemd/system/grub-btrfsd.service

sudo systemctl enable grub-btrfsd

sudo pacman -S --needed base-devel

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

yay -S timeshift-autosnap

sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sudo sed -i 's/^#Include = \/etc\/pacman.d\/mirrorlist\/Include = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
