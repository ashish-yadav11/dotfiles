#!/bin/bash
diff_cmd="diff --color=always -r"

echo ""
$diff_cmd /home/ashish/.scripts/ /home/ashish/.local/projects/dsblocks/helpers/scripts/ |
    grep -Ev '^Only.*'
$diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/.config/ |
    grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)'
$diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/ |
    grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)'
$diff_cmd /home/ashish/.local/dotfiles/locals/ /home/ashish/.local/ |
    grep -Ev '^Only.*(local/(:)|(share(:)|(applications: (mimeapps\.list)|(mimeinfo\.cache))|(builds: dwm)))'
$diff_cmd /home/ashish/.local/dotfiles/scripts/ /home/ashish/.scripts/

echo -e "\ndiff package list"
$diff_cmd /home/ashish/.local/dotfiles/configs/pacsoff.txt <( pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) |
    grep -Ev "(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)" )
$diff_cmd /home/ashish/.local/dotfiles/configs/pacsaur.txt <( pacman -Qqem )

echo -e "\nManually check crontab for updates\n"
