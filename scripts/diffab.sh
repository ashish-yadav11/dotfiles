#!/bin/bash
diff_cmd="diff --color=always -r"

print() {
    if [[ -n $diff ]] ; then
        printf "%s\n\n" "$diff"
    else
        echo -e "No changes\n"
    fi
}

echo -e "\e[1;32mbackup\e[0m"
diff=$(
    $diff_cmd /home/ashish/ /media/storage/.backup/ |
        grep -Ev '^Only.*'
    $diff_cmd /home/ashish/.config/ /media/storage/.backup/ |
        grep -Ev '^Only.*'
)
print

echo -e "\e[1;32mdsblocks\e[0m"
diff=$(
    $diff_cmd /home/ashish/.scripts/ /home/ashish/.local/projects/dsblocks/helpers/scripts/ |
        grep -Ev '^Only.*'
)
print

echo -e "\e[1;32mdotfiles\e[0m"
diff=$(
    $diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/.config/ |
        grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)|(mpv: watch_later)'
    $diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/ |
        grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)'
    $diff_cmd /home/ashish/.local/dotfiles/locals/ /home/ashish/.local/ |
        grep -Ev '^Only.*(local/(:)|(share(:)|(applications: (mimeapps\.list)|(mimeinfo\.cache))|(builds: dwm)))'
    $diff_cmd /home/ashish/.local/dotfiles/scripts/ /home/ashish/.scripts/
)
print

echo -e "\e[1;32mpackage list\e[0m"
diff=$(
    $diff_cmd /home/ashish/.local/dotfiles/configs/pacsoff.txt <( pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) |
        grep -Ev "(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)" )
    $diff_cmd /home/ashish/.local/dotfiles/configs/pacsaur.txt <( pacman -Qqem )
)
print

echo "Manually check crontab for updates"
