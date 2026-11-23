-- Hyprland config. Keybindings live in binds.lua.
-- Options: https://wiki.hypr.land/configuring/core/config-options/

local home = os.getenv("HOME")

-- Colours come from the current theme (written by theme-set).
local ok, theme = pcall(dofile, home .. "/.config/theme/current/hyprland.lua")
if not ok or type(theme) ~= "table" then
    theme = { accent = "rgb(cba6f7)", inactive = "rgb(45475a)", background = "rgb(1b1b26)" }
end

-- Make the scripts in ~/.local/bin (term, menu, theme-set, ...) available to binds.
local bin = home .. "/.local/bin"
local path = os.getenv("PATH") or ""
if not path:find(bin, 1, true) then
    hl.env("PATH", bin .. ":" .. path)
end

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- With auto-login (set up by install.sh) the lock screen is the login prompt.
    local autologin = io.open("/etc/systemd/system/getty@tty1.service.d/autologin.conf")
    if autologin then
        autologin:close()
        hl.exec_cmd("hyprlock")
    end

    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wallpaper")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        col = {
            active_border   = theme.accent,
            inactive_border = theme.inactive,
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 8,
        shadow   = { enabled = false },
        blur     = { enabled = true, size = 3, passes = 1 },
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = theme.background,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_options   = "caps:escape", -- Caps Lock is Escape
        follow_mouse = 1,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Three-finger swipe between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

----------------------
---- WINDOW RULES ----
----------------------

-- Ignore maximize requests from apps.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Terminal tools opened from the system menu (Wi-Fi, Bluetooth, audio) float.
hl.window_rule({
    name   = "float-tui",
    match  = { class = "^tui\\.float$" },
    float  = true,
    center = true,
    size   = { "monitor_w * 0.6", "monitor_h * 0.6" },
})

require("binds")
