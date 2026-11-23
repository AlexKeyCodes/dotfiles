# Read by every zsh, including the login shell that starts Hyprland.
typeset -U path
path=("$HOME/.local/bin" $path)
export EDITOR=nvim
