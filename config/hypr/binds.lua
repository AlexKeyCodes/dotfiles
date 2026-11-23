-- Keybindings.
--
-- SUPER belongs to the window manager; apps never see it.
--   SUPER + key           go somewhere or open something
--   SUPER + SHIFT + key   take the window with you
--   SUPER + CTRL  + key   resize
--
-- Every bind made with bind() is also written to ~/.cache/keybinds.txt,
-- which SUPER + / shows as a searchable cheat sheet.

local mod = "SUPER"
local sheet = {}
local current_group = ""

local function group(name)
    current_group = name
end

local function bind(keys, description, action, flags)
    flags = flags or {}
    flags.description = description
    hl.bind(keys, action, flags)
    sheet[#sheet + 1] = string.format("%-10s  %-20s  %s", current_group, keys, description)
end

local function run(command)
    return hl.dsp.exec_cmd(command)
end

local directions = {
    { "H", "left" },
    { "J", "down" },
    { "K", "up" },
    { "L", "right" },
}

---------------
---- FOCUS ----
---------------
group("Focus")
for _, d in ipairs(directions) do
    bind(mod .. " + " .. d[1], "Focus " .. d[2], hl.dsp.focus({ direction = d[2] }))
end

--------------
---- MOVE ----
--------------
group("Move")
for _, d in ipairs(directions) do
    bind(mod .. " + SHIFT + " .. d[1], "Move window " .. d[2], hl.dsp.window.move({ direction = d[2] }))
end

----------------
---- RESIZE ----
----------------
group("Resize")
local step = 40
local deltas = { left = { -step, 0 }, right = { step, 0 }, up = { 0, -step }, down = { 0, step } }
for _, d in ipairs(directions) do
    local delta = deltas[d[2]]
    bind(mod .. " + CTRL + " .. d[1], "Resize " .. d[2],
        hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }),
        { repeating = true })
end

--------------------
---- WORKSPACES ----
--------------------
group("Workspace")
for i = 1, 9 do
    bind(mod .. " + " .. i, "Go to workspace " .. i, hl.dsp.focus({ workspace = i }))
end
for i = 1, 9 do
    bind(mod .. " + SHIFT + " .. i, "Send window to workspace " .. i, hl.dsp.window.move({ workspace = i }))
end

----------------
---- WINDOW ----
----------------
group("Window")
bind(mod .. " + Q", "Close window", hl.dsp.window.close())
bind(mod .. " + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind(mod .. " + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

--------------
---- APPS ----
--------------
group("Apps")
bind(mod .. " + Return", "Terminal", run("term"))
bind(mod .. " + space", "App launcher", run("fuzzel"))
bind(mod .. " + B", "Browser", run("firefox"))
bind(mod .. " + E", "Files (yazi)", run("term -e yazi"))
bind(mod .. " + N", "Neovim", run("term -e nvim"))

---------------
---- TOOLS ----
---------------
group("Tools")
bind(mod .. " + V", "Clipboard history", run("cliphist list | fuzzel --dmenu --prompt 'Clipboard: ' | cliphist decode | wl-copy"))
bind(mod .. " + S", "Screenshot a region", run("screenshot region"))
bind(mod .. " + SHIFT + S", "Screenshot the screen", run("screenshot screen"))

----------------
---- SYSTEM ----
----------------
group("System")
bind(mod .. " + Escape", "System menu", run("menu"))
bind(mod .. " + slash", "Show keybindings", run("keys"))

------------------
---- HARDWARE ----
------------------
-- Laptop keys. These also work on the lock screen.
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute",         run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   run("brightnessctl -e4 -n2 set 5%+"), held)
hl.bind("XF86MonBrightnessDown", run("brightnessctl -e4 -n2 set 5%-"), held)
hl.bind("XF86AudioNext",  run("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev",  run("playerctl previous"), { locked = true })
hl.bind("XF86AudioPlay",  run("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", run("playerctl play-pause"), { locked = true })

-- Mouse fallback: SUPER + drag moves, SUPER + right-drag resizes.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Write the cheat sheet for the `keys` script.
local cache = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")
local file = io.open(cache .. "/keybinds.txt", "w")
if file then
    file:write(table.concat(sheet, "\n"), "\n")
    file:close()
end
