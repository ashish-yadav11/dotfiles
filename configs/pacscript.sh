#!/bin/bash
pacman -Qqem >/media/storage/.configs/pacsaur.txt
pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) | grep -Ev "(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)" >/media/storage/.configs/pacsoff.txt
