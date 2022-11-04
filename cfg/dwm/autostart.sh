#!/bin/bash

feh --bg-scale $HOME/.config/dwm/wallpaper.png
xrdb -merge $HOME/.Xresources

pgrep picom || picom --config=$HOME/.config/dwm/picom.conf -b

script () {
  $HOME/.config/dwm/scripts/${@} &
}

pgrep bar.sh || script bar.sh
