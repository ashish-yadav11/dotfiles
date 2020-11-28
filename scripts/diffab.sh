#!/bin/bash
mdiff_cmd="diff --color=always -r"
mdiff_str="diff '--color=always' -r"
sdiff_cmd="diff --color=always"
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
        grep -Ev '^Only.*' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd -I '^token = ' /media/storage/.backup/ /home/ashish/.config/ |
        grep -Ev '^Only.*' |
            sed -e "s/^$mdiff_str -I '\\^token = '/diff/"

    $mdiff_cmd /media/storage/.backup/ /home/ashish/.local/share/ |
        grep -Ev '^Only.*' |
            sed -e "s/^$mdiff_str/diff/"
)
print_mdiff


echo -e "\e[1;32mdsblocks\e[0m"
mdiff=$(
    $mdiff_cmd "$dsblocks/helpers/scripts/" /home/ashish/.scripts/ |
        grep -Ev '^Only.*' |
            sed -e "s/^$mdiff_str/diff/"
)
print_mdiff


echo -e "\e[1;32mdotfiles\e[0m"
mdiff=$(
    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/bash.bashrc" /etc/bash.bashrc
    )
    [[ -n $sdiff ]] &&
        printf "diff $dotfiles/configs/bash.bashrc /etc/bash.bashrc\n%s\n" "$sdiff"

    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/crontab" <( crontab -l )
    )
    [[ -n $sdiff ]] &&
        printf "diff $dotfiles/configs/crontab crontab\n%s\n" "$sdiff"

    $mdiff_cmd -I "^history\|^lastVisited\|^':" "$dotfiles/configs/" /home/ashish/.config/ |
        grep -Ev '^Only.*(configs?/:)|(nvim: \.netrwhist)|(ranger: tagged)|(newsboat: cache.db)|(msmtp: msmtp.log)|(mpv: watch_later)' |
            sed -e "s/^$mdiff_str -I '\\^history\\\\|\\^lastVisited\\\\|\\^'\\\\'':'/diff/"

    $mdiff_cmd "$dotfiles/configs/" /home/ashish/ |
        grep -Ev '^Only.*(configs/:)|(ashish/(:)|(.surf:))|(GmailAPI: token)|(\.gnupg: )' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/locals/" /home/ashish/.local/ |
        grep -Ev '^Only.*(local/(:)|(share(:)|(applications: (mimeapps\.list)|(mimeinfo\.cache))|(builds: dwm)))' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/scripts/" /home/ashish/.scripts/ |
        sed -e "s/^$mdiff_str/diff/"
)
print_mdiff


echo -e "\e[1;32mpackage list\e[0m"
mdiff=$(
    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/pacsoff.txt" <( pacman -Qqen | grep -Fxvf <( pacman -Qqg base-devel ) |
            grep -Ev '(^base$)|(^efibootmgr$)|(^grub$)|(^linux$)|(^linux-firmware$)|(^linux-lts$)' )
    )
    [[ -n $sdiff ]] &&
        printf "diff $dotfiles/configs/pacsoff.txt pacsoff\n%s\n" "$sdiff"

    sdiff=$(
        $sdiff_cmd "$dotfiles/configs/pacsaur.txt" <( pacman -Qqem )
    )
    [[ -n $sdiff ]] &&
        printf "diff $dotfiles/configs/pacsaur.txt pacsaur\n%s\n\n" "$sdiff"
)
print_mdiff
