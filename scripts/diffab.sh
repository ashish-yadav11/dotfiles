#!/bin/bash
mdiff_cmd="diff --no-dereference --color=always -r"
mdiff_str="diff --no-dereference '--color=always' -r"
sdiff_cmd="diff --color=always"
dotfiles=/home/ashish/.local/dotfiles

print_mdiff() {
    if [[ -n "$mdiff" ]] ; then
        printf "%s\n\n" "$mdiff"
    else
        echo -e 'No changes\n'
    fi
}


echo -e '\e[1;32mbackup\e[0m'
mdiff="$(
    $mdiff_cmd /media/storage/.backup /home/ashish |
        grep -Ev '^Only in ' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd -I '^token = ' /media/storage/.backup /home/ashish/.config |
        grep -Ev '^Only in ' |
            sed -e "s/^$mdiff_str -I '\\^token = '/diff/"

    $mdiff_cmd /media/storage/.backup /home/ashish/.local/share |
        grep -Ev '^Only in ' |
            sed -e "s/^$mdiff_str/diff/"
)"
print_mdiff


echo -e '\e[1;32mdotfiles\e[0m'
mdiff="$(
    sdiff="$(
        $sdiff_cmd "$dotfiles/config/bash.bashrc" /etc/bash.bashrc
    )"
    [[ -n "$sdiff" ]] &&
        printf "diff $dotfiles/config/bash.bashrc /etc/bash.bashrc\n%s\n" "$sdiff"

    sdiff="$(
        $sdiff_cmd "$dotfiles/config/crontab" <(crontab -l)
    )"
    [[ -n "$sdiff" ]] &&
        printf "diff $dotfiles/config/crontab crontab\n%s\n" "$sdiff"

    $mdiff_cmd -I "^history\|^lastVisited\|^x-scheme-handler/tg=\|^':" "$dotfiles/config" /home/ashish/.config |
        grep -Ev '^Only in .*(config:|\.config(:|/mpv/watch_later: |/nvim: \.netrwhist$|/ranger(: bookmarks$|/.*: __)))' |
            sed -e "s/^$mdiff_str -I '\\^history\\\\|[^ ]*:'/diff/"

    $mdiff_cmd "$dotfiles/config" /home/ashish |
        grep -Ev '^Only in .*(config:|ashish(:|/\.gnupg: ))' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/local" /home/ashish/.local |
        grep -Ev '^Only in .*(local(:|/share(:|/applications: (userapp-Telegram Desktop.*\.desktop|mimeinfo\.cache$))|/builds(: (dwm|st)$|/keynav: keynav$|/yewtube: yewtube$|.*\.pkg\.tar\.zst$)))' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/scripts" /home/ashish/.scripts |
        sed -e "s/^$mdiff_str/diff/"
)"
print_mdiff


echo -e '\e[1;32mpackage list\e[0m'
mdiff="$(
    sdiff="$(
        $sdiff_cmd "$dotfiles/config/pacsoff.txt" <(pacman -Qqen | grep -Fxvf <(pacman -Qqg base-devel) |
            grep -Ev '^(base|efibootmgr|grub|linux|linux-firmware|linux-lts)$')
    )"
    [[ -n "$sdiff" ]] &&
        printf "diff $dotfiles/config/pacsoff.txt pacsoff\n%s\n" "$sdiff"

    sdiff="$(
        $sdiff_cmd "$dotfiles/config/pacsaur.txt" <(pacman -Qqem)
    )"
    [[ -n "$sdiff" ]] &&
        printf "diff $dotfiles/config/pacsaur.txt pacsaur\n%s\n\n" "$sdiff"
)"
print_mdiff
