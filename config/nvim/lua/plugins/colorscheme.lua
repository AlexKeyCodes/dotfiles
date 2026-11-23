-- The active colorscheme is whatever theme-set last wrote to
-- ~/.config/theme/current/nvim. Each theme in the dotfiles repo names one of
-- the colorschemes installed below.
local function current_theme()
  local file = io.open(vim.fn.expand("~/.config/theme/current/nvim"))
  if not file then
    return "catppuccin-mocha"
  end
  local name = file:read("l")
  file:close()
  return (name and name ~= "") and name or "catppuccin-mocha"
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = true,
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "darker", -- dark, darker, cool, deep, warm, warmer
      transparent = true,
    },
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  { "Mofiqul/dracula.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd.colorscheme(current_theme())
      end,
    },
  },
}
