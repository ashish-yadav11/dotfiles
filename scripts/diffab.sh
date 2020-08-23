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
    $diff_cmd /media/storage/.backup/ /home/ashish/ |
        grep -Ev '^Only.*'
    $diff_cmd /media/storage/.backup/ /home/ashish/.config/ |
        grep -Ev '^Only.*'
)
print

echo -e "\e[1;32mdsblocks\e[0m"
diff=$(
    $diff_cmd /home/ashish/.local/projects/dsblocks/helpers/scripts/ /home/ashish/.scripts/ |
        grep -Ev '^Only.*'
)
print

echo -e "\e[1;32mdotfiles\e[0m"
diff=$(
    $diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/.config/ |
        grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)|(mpv: watch_later)'
    $diff_cmd /home/ashish/.local/dotfiles/configs/ /home/ashish/ |
        grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)|(\.gnupg: )'
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
