# dotfiles

My Arch Linux + Hyprland setup: one script that takes a fresh `archinstall` to a
working, keyboard-driven desktop with a single theme across every app.

- **Minimal**: everything comes from the official Arch repos; there is no AUR helper.
- **Keyboard first**: `SUPER` drives the window manager, and `SUPER + /` lists every binding.
- **One theme everywhere**: `theme-set` recolours the desktop, terminal, prompt and Neovim together.

## Install

On a fresh install (after `archinstall` with the Hyprland profile):

```bash
sudo pacman -S git
git clone https://github.com/AlexKeyCodes/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Read the script first; it is short. It is safe to run again at any time.

Then reboot.

### What the script does

Each step is a phase. Run them all with `./install.sh`, or name the ones you
want: `./install.sh packages link`.

| Phase | What it does |
|---|---|
| `packages` | Updates the system and installs everything in `packages/pacman.txt` |
| `link` | Symlinks the configs into place with stow. Existing files are moved to `~/.dotfiles-backup/<date>/` first |
| `theme` | Renders the current theme (Catppuccin on the first run) |
| `cleanup` | Offers to remove the archinstall defaults this setup replaces (kitty, dolphin, wofi, dunst, polkit-kde-agent). Skips kitty while you are running the script inside it |
| `shell` | Makes zsh the login shell |
| `services` | Enables Bluetooth, the firewall and the weekly package cache cleanup |
| `login` | Replaces the graphical login screen with auto-login and hyprlock (see [Login](#login)) |
| `git` | Asks for your Git name and email, creates an SSH key if there is none, and switches this repo's remote to SSH |
| `dev` | Installs Ruby and Node through mise, then Claude Code. Ruby compiles from source, so this takes several minutes |

### After the first run

1. Add the SSH key the script printed to <https://github.com/settings/keys>.
2. Reboot.
3. Open Neovim once and let the plugins install.
4. Put anything specific to this machine in `~/.zshrc.local` (see [Machine-only settings](#machine-only-settings)).

## What you get

| Role | Tool |
|---|---|
| Window manager | Hyprland |
| Bar | waybar |
| Launcher and menus | fuzzel |
| Notifications | mako |
| Lock and idle | hyprlock, hypridle |
| Night light | hyprsunset |
| USB drives | udiskie |
| Firewall | ufw |
| Terminal | ghostty |
| Shell and prompt | zsh, starship |
| Editor | Neovim (LazyVim) |
| Files | yazi |
| Images, PDFs | imv, zathura |
| Screenshots | grim, slurp |
| Clipboard history | cliphist |
| Wi-Fi, Bluetooth, audio | nmtui or impala, bluetui, pulsemixer |
| Ruby and Node versions | mise |
| Apps | Firefox, mpv, OBS, Transmission |

Not included on purpose: databases and Docker. Install them when a project needs them.

## Keybindings

`SUPER` drives everything: `SUPER + Return` opens a terminal, `SUPER + Space`
the app launcher, `SUPER + Escape` the system menu (Wi-Fi, Bluetooth, audio,
power) and `SUPER + /` a searchable list of every binding.

The full list, the laptop keys and everyday how-tos (connecting to Wi-Fi,
changing volume, using workspaces) are in [HOWTO.md](HOWTO.md).

## Themes

```bash
theme-set                # pick from a menu (also in SUPER + Escape)
theme-set tokyo-night    # switch directly
theme-set --reload       # re-render the current theme
```

Included: `catppuccin` (default) and `tokyo-night`.

### How it works

A theme is one file, `themes/<name>/theme.conf`, holding about twenty named
colours and the Neovim colorscheme to use. `theme-set` fills those colours into
every file in `templates/`, writes the results to `~/.config/theme/current/`,
and tells the running apps to reload.

| App | Template | How it picks up a change |
|---|---|---|
| Hyprland (borders, background) | `hyprland.lua` | Reloaded straight away |
| waybar | `waybar.css` | Reloaded straight away |
| ghostty | `ghostty` | Reloaded straight away |
| mako | `mako` | Reloaded straight away |
| starship | `starship.toml` | Next prompt |
| fuzzel | `fuzzel.ini` | Next time it opens |
| hyprlock | `hyprlock.conf` | Next lock |
| zathura | `zathurarc` | Next time it opens |
| Neovim | `nvim` | Every running instance switches straight away |

Programs that run in the terminal (btop, yazi, fzf, zsh suggestions) use the
terminal's colours, so they follow along without any config. GTK apps and
Firefox follow the theme's light or dark `mode`.

### Editing how something looks

For waybar, mako, fuzzel, hyprlock, starship, zathura and the ghostty colours, the whole
config is a template. Edit the file in `templates/`, never the rendered copy,
then run `theme-set --reload`.

### Adding a theme

1. Copy `themes/catppuccin` to `themes/<name>` and change the values. Every key is required.
2. Set `nvim=` to a colorscheme that is installed. To add one, list its plugin in `config/nvim/lua/plugins/colorscheme.lua`.
3. Optionally drop a `wallpaper.jpg` or `wallpaper.png` in the theme folder. Without one, the background is the theme's background colour.
4. Run `theme-set <name>`.

## Layout

```
install.sh        the one script
packages/         pacman.txt: every package, one per line
config/           linked into ~/.config   (hypr, waybar, ghostty, nvim, yazi, mise)
home/             linked into ~           (.zshrc, .zshenv, .zprofile, .aliases)
bin/              linked into ~/.local/bin (theme-set, term, menu, keys, screenshot, wallpaper)
templates/        per-app files with {{colour}} placeholders
themes/           one folder per theme
```

## Day to day

| I want to... | Do this |
|---|---|
| Add a package | Add a line to `packages/pacman.txt`, run `./install.sh packages` |
| Change a config | Edit it in the repo; the files in `~/.config` are symlinks to it |
| Add a new config file | Create it under `config/` or `home/`, run `./install.sh link` |
| Change a keybinding | Edit `config/hypr/binds.lua` |
| Check the Hyprland config for mistakes | `Hyprland --verify-config` |
| Change the Ruby or Node version | Edit `config/mise/config.toml`, run `mise install` |
| Change the terminal font size | `font-size` in `config/ghostty/config` |
| Change which app opens a file type | Edit `config/hyprland-mimeapps.list` |

### Machine-only settings

`~/.zshrc.local` is loaded by `.zshrc` and is not in the repo. Use it for
project paths, SSH shortcuts and anything private:

```bash
alias work='cd ~/Work/some-project'
alias sshprod='ssh user@example.com'
```

## Login

The `login` phase replaces the graphical login screen with this:

1. The machine logs you in on the first terminal (tty1) without a password.
2. Hyprland starts on its own.
3. hyprlock comes up first and asks for your password.

The lock screen follows the theme, which is the reason for doing it this way.
Two things to know:

- The desktop can show for a moment before the lock screen appears.
- The disk is not encrypted, so neither this nor a normal login screen protects
  your files from someone who has the laptop.

To go back to a login screen:

```bash
sudo rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo systemctl enable sddm
```

The script disables the old login manager but leaves it installed. Once you
are happy, remove it with `sudo pacman -Rns sddm`.

## If something goes wrong

- **Hyprland will not start, or the screen is unusable.** Press `Ctrl + Alt + F2`
  for a plain terminal, log in and fix the config. `Hyprland --verify-config`
  points at the broken line.
- **A config file from before the install is gone.** It is in `~/.dotfiles-backup/`.
- **Colours look wrong in one app.** Run `theme-set --reload`. It warns if a
  template uses a colour the theme does not define.
- **The Wi-Fi menu says nothing is running.** It looks for NetworkManager or iwd;
  start whichever one `archinstall` set up.
