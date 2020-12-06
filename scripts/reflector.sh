#!/bin/dash
reflector --latest 50 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
