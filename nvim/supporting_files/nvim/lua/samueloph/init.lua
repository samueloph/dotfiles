-- Lazy recomments loading the mapleader remap first.
require("samueloph.remap")
require("samueloph.set")
require("samueloph.lazy_init")
require("samueloph.colorscheme")
require('lualine').setup()

-- nvim-tree settings
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true
