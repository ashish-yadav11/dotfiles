#!/bin/bash
diff_cmd="diff --color=always -r"
dsblocks=/home/ashish/.local/projects/dsblocks
dotfiles=/home/ashish/.local/dotfiles

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
    $diff_cmd "$dsblocks/helpers/scripts/" /home/ashish/.scripts/ |
        grep -Ev '^Only.*'
)
print

echo -e "\e[1;32mdotfiles\e[0m"
diff=$(
    diff1=$(
        $diff_cmd "$dotfiles/configs/bash.bashrc" /etc/bash.bashrc
    )
    if [[ -n $diff1 ]] ; then
        echo "diff '--color=always' -r "$dotfiles/configs/bash.bashrc" /etc/bash.bashrc"
        printf "%s\n" "$diff1"
    fi
    $diff_cmd "$dotfiles/configs/" /home/ashish/.config/ |
        grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)|(mpv: watch_later)'
    $diff_cmd "$dotfiles/configs/" /home/ashish/ |
        grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)|(\.gnupg: )'
    $diff_cmd "$dotfiles/locals/" /home/ashish/.local/ |
        grep -Ev '^Only.*(local/(:)|(share(:)|(applications: (mimeapps\.list)|(mimeinfo\.cache))|(builds: dwm)))'
    $diff_cmd "$dotfiles/scripts/" /home/ashish/.scripts/
)
print

echo -e "\e[1;32mpackage list\e[0m"
diff1=$(
    $diff_cmd "$dotfiles/configs/pacsoff.txt" <( pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) |
        grep -Ev '(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)' )
)
diff2=$(
    $diff_cmd "$dotfiles/configs/pacsaur.txt" <( pacman -Qqem )
)
if [[ -n $diff1 ]] ; then
    echo "diff '--color=always' -r "$dotfiles/configs/pacsoff.txt" pacsoff.txt"
    if [[ -n $diff2 ]] ; then
        printf "%s\n" "$diff1"
        echo "diff '--color=always' -r "$dotfiles/configs/pacsaur.txt" pacsaur.txt"
        printf "%s\n\n" "$diff2"
    else
        printf "%s\n\n" "$diff1"
    fi
elif [[ -n $diff2 ]] ; then
    echo "diff '--color=always' -r "$dotfiles/configs/pacsaur.txt" pacsaur.txt"
    printf "%s\n\n" "$diff2"
else
    echo -e "No changes\n"
fi

echo "Manually check crontab for updates"
