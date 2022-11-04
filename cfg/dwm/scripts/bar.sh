#!/bin/bash

# ^b#bg^ -> background
# ^c#fg^ -> foreground

# base
darker_bg=#0b0d16
bg=#0d0f18
contrast_bg=#0f111a
lighter_bg=#11131c
fg=#a5b6cf

# base16
black=#151720
red=#dd6777
green=#90ceaa
yellow=#ecd3a0
blue=#86aaec
magenta=#c296eb
cyan=#93cee9
white=#cbced3

bg () { printf "^b${@}^"; }
fg () { printf "^c${@}^"; }

is_muted () {
  pacmd list-sinks | awk '/muted/ { print $2 }'
}

brightness_module () {
  local brightness=$(light -G | sed 's/\./ /g' | awk '{print $1}')
  local icon=""

  printf "$(bg $bg)$(fg $yellow) $icon  $brightness%%$(bg $bg)$(fg $fg)"
}

volume_module () {
  local muted=$(is_muted)
  local volume=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
  local icon=""

  if [[ $muted == "yes" ]]; then
    volume=0
    icon="婢"
  fi

  printf "$(bg $bg)$(fg $cyan) $icon  $volume%%$(bg $bg)$(fg $fg)"
}

wifi_module () {
  local name=$(iwgetid -r)
  local accent=$blue
  local icon=""
  if [[ $name == "" ]]; then
    name="Disconnected"
    accent=$red
    icon="睊"
  fi

  printf "$(bg $accent)$(fg $bg) $icon  $(bg $black)$(fg $accent) $name $(bg $bg) $(fg $fg)"
}

date_module () {
  printf "$(bg $blue)$(fg $bg)   $(bg $cyan)$(fg $bg) $(date '+%I:%M %p') $(bg $bg)$(fg $fg)"
}

while :; do
  xsetroot -name " $(brightness_module) $(volume_module)  $(wifi_module) $(date_module) "
  sleep 1
done &
