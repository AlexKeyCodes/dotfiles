#!/usr/bin/env bash
# Sets up a fresh Arch + Hyprland install from this repo. Safe to re-run.
#
#   ./install.sh               run every phase
#   ./install.sh link theme    run only the named phases
#
# Phases: packages link theme cleanup shell services login git dev
set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP=$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)
PHASES=(packages link theme cleanup shell services login git dev)
AUTOLOGIN=/etc/systemd/system/getty@tty1.service.d/autologin.conf

say()  { printf '\n\033[1;35m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
note() { printf '    %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
ask()  { local reply; read -rp "    $1 [y/N] " reply; [[ $reply == [yY]* ]]; }

# --- packages: everything in packages/pacman.txt ---------------------------
phase_packages() {
  say "Installing packages"
  local pkgs
  mapfile -t pkgs < <(grep -Ev '^[[:space:]]*(#|$)' "$DOTFILES/packages/pacman.txt")
  sudo pacman -Syu --needed "${pkgs[@]}"
}

# --- link: symlink configs into place with stow ----------------------------
# Any existing file that is not already our symlink is moved to $BACKUP first.
link_package() {
  local pkg=$1 target=$2 src rel dst
  mkdir -p "$target"
  while IFS= read -r -d '' src; do
    rel=${src#"$DOTFILES/$pkg/"}
    dst=$target/$rel
    if [[ -e $dst || -L $dst ]] && [[ ! $dst -ef $src ]]; then
      mkdir -p "$BACKUP/$pkg/$(dirname "$rel")"
      mv "$dst" "$BACKUP/$pkg/$rel"
      note "backed up $dst"
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)
  stow --no-folding --restow --dir "$DOTFILES" --target "$target" "$pkg"
}

phase_link() {
  say "Linking configs"
  command -v stow >/dev/null || die "stow is missing; run ./install.sh packages first."
  link_package config "${XDG_CONFIG_HOME:-$HOME/.config}"
  link_package home "$HOME"
  link_package bin "$HOME/.local/bin"
  [[ -d $BACKUP ]] && note "replaced files are in $BACKUP"
  return 0
}

# --- theme: render the current theme (Catppuccin on first run) -------------
phase_theme() {
  say "Applying theme"
  "$DOTFILES/bin/theme-set" --reload
}

# --- cleanup: defaults from archinstall's Hyprland profile that we replace --
phase_cleanup() {
  say "Checking for replaced default packages"
  local found=() pkg
  for pkg in kitty dolphin wofi dunst polkit-kde-agent; do
    # Removing kitty also removes its terminfo, which breaks the kitty window
    # this script is running in.
    if [[ $pkg == kitty && ${TERM:-} == xterm-kitty ]]; then
      note "skipping kitty: you are using it now. Run ./install.sh cleanup from ghostty later."
      continue
    fi
    if pacman -Qq "$pkg" &>/dev/null; then found+=("$pkg"); fi
  done
  if (( ${#found[@]} == 0 )); then note "nothing to remove"; return 0; fi
  note "installed but replaced by this setup: ${found[*]}"
  if ask "Remove them?"; then
    sudo pacman -Rns "${found[@]}" || note "pacman refused; remove them by hand if you want"
  fi
}

# --- shell: make zsh the login shell ---------------------------------------
phase_shell() {
  say "Setting login shell"
  if [[ $(getent passwd "$USER" | cut -d: -f7) == */zsh ]]; then
    note "already zsh"
  else
    chsh -s "$(command -v zsh)"
  fi
}

# --- services --------------------------------------------------------------
phase_services() {
  say "Enabling services"
  sudo systemctl enable --now bluetooth.service
}

# --- login: auto-login on tty1; hyprlock is then the password prompt -------
phase_login() {
  say "Login screen"
  if [[ -f $AUTOLOGIN ]]; then note "auto-login already set up"; return 0; fi
  note "Replacing the graphical login screen with auto-login on tty1."
  note "Hyprland starts on its own and hyprlock asks for your password."

  sudo mkdir -p "$(dirname "$AUTOLOGIN")"
  sudo tee "$AUTOLOGIN" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USER %I \$TERM
EOF

  local dm
  for dm in sddm gdm lightdm ly greetd; do
    if systemctl is-enabled --quiet "$dm" 2>/dev/null; then
      sudo systemctl disable "$dm"
      note "disabled $dm (the package is still installed)"
    fi
  done
  note "takes effect on the next reboot"
}

# --- git: identity and SSH key ---------------------------------------------
phase_git() {
  say "Git and SSH"
  local value key=$HOME/.ssh/id_ed25519 url
  if [[ -z $(git config --global user.name || true) ]]; then
    read -rp "    Git name: " value
    git config --global user.name "$value"
  fi
  if [[ -z $(git config --global user.email || true) ]]; then
    read -rp "    Git email: " value
    git config --global user.email "$value"
  fi
  git config --global init.defaultBranch main

  if [[ -f $key ]]; then
    note "SSH key already exists"
  else
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$key"
    if [[ -n ${WAYLAND_DISPLAY:-} ]] && command -v wl-copy >/dev/null; then
      wl-copy < "$key.pub"
      note "public key copied to the clipboard"
    fi
    note "add this key at https://github.com/settings/keys"
    note "$(cat "$key.pub")"
  fi

  url=$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)
  if [[ $url == https://github.com/* ]]; then
    git -C "$DOTFILES" remote set-url origin "git@github.com:${url#https://github.com/}"
    note "this repo's remote now uses SSH"
  fi
}

# --- dev: Ruby and Node through mise, plus Claude Code ---------------------
# Last on purpose: Ruby compiles from source and is the step most likely to fail.
phase_dev() {
  say "Installing Ruby and Node (Ruby compiles from source; this takes a while)"
  mise install

  if command -v claude >/dev/null || [[ -x $HOME/.local/bin/claude ]]; then
    note "Claude Code already installed"
  else
    say "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

# ---------------------------------------------------------------------------
[[ $EUID -ne 0 ]] || die "Run this as your normal user, not root."
command -v pacman >/dev/null || die "This script is for Arch Linux."

(( $# )) || set -- "${PHASES[@]}"
for phase in "$@"; do
  declare -F "phase_$phase" >/dev/null || die "Unknown phase '$phase'. Phases: ${PHASES[*]}"
done
for phase in "$@"; do
  "phase_$phase"
done

say "Done"
note "Reboot (or log out and back in) so the new shell and login setup apply."
note "SUPER + / shows every keybinding."
