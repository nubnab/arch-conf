#!/bin/bash

timedatectl set-ntp true

sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /etc/systemd/system/grub-btrfsd.service

sudo systemctl daemon-reload
sudo systemctl restart grub-btrfsd
