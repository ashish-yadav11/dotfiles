#!/bin/bash
pacman -Qqem >pacsaur.txt
pacman -Qqen | grep -Fxvf <(pacman -Qqg base-devel) | grep -Ev '^(base|efibootmgr|grub|linux|linux-firmware|linux-lts)$' >pacsoff.txt
