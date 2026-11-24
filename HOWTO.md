# Keys and how-tos

How to drive this desktop: every keybinding, the laptop keys, and the everyday
tasks a menu bar would normally handle. Setup and themes are in the
[README](README.md).

## Keybindings

`SUPER` belongs to the window manager. The modifier tells you what kind of
action it is:

- `SUPER + key` goes somewhere or opens something
- `SUPER + SHIFT + key` takes the window with you
- `SUPER + CTRL + key` resizes

| Group | Keys | Action |
|---|---|---|
| Focus | `SUPER + H / J / K / L` | Focus the window left / down / up / right |
| Move | `SUPER + SHIFT + H / J / K / L` | Move the window |
| Resize | `SUPER + CTRL + H / J / K / L` | Resize the window |
| Workspace | `SUPER + 1–9` | Go to a workspace |
| Workspace | `SUPER + SHIFT + 1–9` | Send the window to a workspace |
| Window | `SUPER + Q` | Close |
| Window | `SUPER + F` | Fullscreen |
| Window | `SUPER + T` | Toggle floating |
| Apps | `SUPER + Return` | Terminal, opened in the focused terminal's directory |
| Apps | `SUPER + Space` | App launcher |
| Apps | `SUPER + B` | Browser |
| Apps | `SUPER + E` | Files (yazi) |
| Apps | `SUPER + N` | Neovim |
| Tools | `SUPER + V` | Clipboard history |
| Tools | `SUPER + S` | Screenshot a region |
| Tools | `SUPER + SHIFT + S` | Screenshot the whole screen |
| System | `SUPER + Escape` | System menu: lock, suspend, log out, reboot, shut down, theme, Wi-Fi, Bluetooth, audio |
| System | `SUPER + /` | Searchable list of every keybinding |

Also:

- Caps Lock is Escape.
- Volume, brightness and media keys work, including on the lock screen.
- Three-finger swipe moves between workspaces.
- `SUPER` + left-drag moves a window; `SUPER` + right-drag resizes it.
- Screenshots are copied to the clipboard and saved in `~/Pictures/Screenshots`.

There are no terminal splits. `SUPER + Return` opens another terminal and
Hyprland tiles it, so one set of keys moves between everything. That leaves
`ctrl + h/j/k/l` for Neovim's own windows.

To change a binding, edit `config/hypr/binds.lua`. Hyprland reloads on save and
the `SUPER + /` list updates itself.

## Laptop keys

These are not in the `SUPER + /` list. They also work on the lock screen.

| Key | Action |
|---|---|
| Volume up / down | Speaker volume in 5% steps |
| Mute | Mute or unmute the speakers |
| Mic mute | Mute or unmute the microphone |
| Brightness up / down | Screen brightness in 5% steps |
| Play / pause, next, previous | Control whatever is playing |

## How do I...

The bar shows the Wi-Fi network, volume and battery, but it is display only.
Everything a menu bar would do is behind `SUPER + Escape`.

| I want to... | Do this |
|---|---|
| Connect to Wi-Fi | `SUPER + Escape` → Wi-Fi, then "Activate a connection" in `nmtui` |
| Pair or connect a Bluetooth device | `SUPER + Escape` → Bluetooth (`bluetui`) |
| Change the volume | The volume keys |
| Switch speakers, headphones or HDMI, or set one app's volume | `SUPER + Escape` → Audio (`pulsemixer`) |
| Change the screen brightness | The brightness keys |
| Lock, suspend, log out, reboot or shut down | `SUPER + Escape`, then the matching entry |
| Switch theme | `SUPER + Escape` → Theme |
| Make a new workspace | `SUPER + <number>` you are not using yet. Workspaces 1–9 appear when you go to them and disappear when empty |
| Move a window to another workspace | `SUPER + SHIFT + <number>` |
| Open another terminal | `SUPER + Return`. It starts in the focused terminal's directory |
| Close a window | `SUPER + Q` |
| Find a key I forgot | `SUPER + /` |
