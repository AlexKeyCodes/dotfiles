# Read by every zsh, including the login shell that starts Hyprland.
typeset -U path
# The mise shims put Ruby and Node on PATH for programs Hyprland starts without
# an interactive shell (SUPER + N opens Neovim that way, and Mason needs both).
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)
export EDITOR=nvim
