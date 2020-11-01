#!/bin/bash
mdiff_cmd="diff --color=always -r"
sdiff_cmd="diff --color=always"
sdiff_str="diff '--color=always'"
dsblocks=/home/ashish/.local/projects/dsblocks
dotfiles=/home/ashish/.local/dotfiles

print_mdiff() {
    if [[ -n $mdiff ]] ; then
        printf "%s\n\n" "$mdiff"
    else
        echo -e "No changes\n"
    fi
}

echo -e "\e[1;32mbackup\e[0m"
mdiff=$(
    $mdiff_cmd /media/storage/.backup/ /home/ashish/ |
        grep -Ev '^Only.*'
    $mdiff_cmd -I '^token = ' /media/storage/.backup/ /home/ashish/.config/ |
        grep -Ev '^Only.*'
)
print_mdiff

echo -e "\e[1;32mdsblocks\e[0m"
mdiff=$(
    $mdiff_cmd "$dsblocks/helpers/scripts/" /home/ashish/.scripts/ |
        grep -Ev '^Only.*'
)
print_mdiff

echo -e "\e[1;32mdotfiles\e[0m"
mdiff=$(
    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/bash.bashrc" /etc/bash.bashrc
    )
    [[ -n $sdiff ]] &&
        printf "$sdiff_str $dotfiles/configs/bash.bashrc /etc/bash.bashrc\n%s\n" "$sdiff"

    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/crontab" <( crontab -l )
    )
    [[ -n $sdiff ]] &&
        printf "$sdiff_str $dotfiles/configs/crontab crontab\n%s\n" "$sdiff"

    $mdiff_cmd -I "^history\|^lastVisited\|^':" "$dotfiles/configs/" /home/ashish/.config/ |
        grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)|(mpv: watch_later)'
    $mdiff_cmd "$dotfiles/configs/" /home/ashish/ |
        grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)|(\.gnupg: )'
    $mdiff_cmd "$dotfiles/locals/" /home/ashish/.local/ |
        grep -Ev '^Only.*(local/(:)|(share(:)|(applications: (mimeapps\.list)|(mimeinfo\.cache))|(builds: dwm)))'
    $mdiff_cmd "$dotfiles/scripts/" /home/ashish/.scripts/
)
print_mdiff

echo -e "\e[1;32mpackage list\e[0m"
sdiff1=$(
    $sdiff_cmd "$dotfiles/configs/pacsoff.txt" <( pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) |
        grep -Ev '(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)' )
)
sdiff2=$(
    $sdiff_cmd "$dotfiles/configs/pacsaur.txt" <( pacman -Qqem )
)
if [[ -n $sdiff1 && -n $sdiff2 ]] ; then
    printf "$sdiff_str $dotfiles/configs/pacsoff.txt pacsoff\n%s\n$sdiff_str $dotfiles/configs/pacsaur.txt pacsaur\n%s\n\n" "$sdiff1" "$sdiff2"
elif [[ -n $sdiff2 ]] ; then
    printf "$sdiff_str $dotfiles/configs/pacsaur.txt pacsaur\n%s\n\n" "$sdiff2"
else
    echo -e "No changes\n"
fi
