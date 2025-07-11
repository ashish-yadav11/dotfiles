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
    prefix="$dotfiles/config/root-"
    for f in "$prefix"* ; do
        name="${f#"$prefix"}"
        if [ -d "$f" ] ; then
            $mdiff_cmd "$f" "/etc/$name" 2>/dev/null |
                grep -Ev '^Only in /etc/.*'
        elif [ -f "$f" ] ; then
            sdiff="$(
                $sdiff_cmd "$f" "/etc/$name"
            )"
            [[ -n "$sdiff" ]] &&
                printf "diff $f /etc/$name\n%s\n" "$sdiff"
        fi
    done

    $mdiff_cmd -I "^history\|^lastVisited\|^x-scheme-handler/tg=\|^':\|^\(Builtin\|Quick\)AnnotationTools=" "$dotfiles/config" /home/ashish/.config |
        grep -Ev '^Only in .*(config:|\.config(:|/mpv(: watch_later$|/watch_later: )|/nvim: \.netrwhist$|/pipewire: media-session.d$|/ranger(: bookmarks$|/.*: __)))' |
            sed -e "s/^$mdiff_str -I '\\^history\\\\|[^ ]*' /diff /"

    $mdiff_cmd "$dotfiles/config" /home/ashish |
        grep -Ev '^Only in .*(config:|ashish(:|/\.gnupg: |/\.password-store: secret-service$))' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/local" /home/ashish/.local |
        grep -Ev '^Only in .*(local(:|/share(:|/applications: (brave-.*\.desktop|mimeinfo\.cache)|/icons: hicolor)|/builds(: (dwm|st)$|/keynav: keynav$|.*\.pkg\.tar\.zst$)|/bin: spotify_to_ytmusic$))' |
            sed -e "s/^$mdiff_str/diff/"

    $mdiff_cmd "$dotfiles/scripts" /home/ashish/.scripts |
        grep -Ev '^Only in /home/ashish/.scripts[^.]*$' |
            sed -e "s/^$mdiff_str/diff/"
)"
print_mdiff


echo -e '\e[1;32mpackage list\e[0m'
mdiff="$(
    sdiff="$(
        $sdiff_cmd "$dotfiles/config/pacsoff.txt" <(pacman -Qqen |
            grep -Ev '^(base|base-devel|efibootmgr|grub|linux|linux-firmware|linux-lts)$')
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
