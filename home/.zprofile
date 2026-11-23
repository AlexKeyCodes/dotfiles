# Start Hyprland when logging in on the first virtual terminal.
if [[ -z $WAYLAND_DISPLAY && $XDG_VTNR == 1 ]] && (( $+commands[start-hyprland] )); then
  exec start-hyprland
fi
