#!/bin/bash
pacman -Qqem >pacsaur.txt
pacman -Qqen | grep -Ev '^(base|base-devel|efibootmgr|grub|linux|linux-firmware|linux-lts)$' >pacsoff.txt
