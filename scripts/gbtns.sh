#!/bin/dash
read -r cbtns </sys/class/backlight/radeon_bl0/actual_brightness
btns=$(yad --title=Brightness --image=brightnesssettings --no-buttons --entry \
           --text="Brightness (1-255)" --entry-text="$cbtns" --entry-label=Level: --numeric 1 255)
[ "$btns" -ge 1 ] && [ "$btns" -le 255 ] && echo "$btns" >/sys/class/backlight/radeon_bl0/brightness
