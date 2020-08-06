#!/bin/dash
reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
