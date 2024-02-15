-- Lazy setup as suggested at https://github.com/folke/lazy.nvim
-- Use same pattern as https://github.com/ThePrimeagen/neovimrc/blob/master/lua/theprimeagen/lazy_init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = "samueloph.lazy",
    -- TODO: Install a nerd font and drop the ui settings.
--    ui = {
--    icons = {
--      cmd = "⌘",
--      config = "🛠",
--      event = "📅",
--      ft = "📂",
--      init = "⚙",
--      keys = "🗝",
--      plugin = "🔌",
--      runtime = "💻",
--      require = "🌙",
--      source = "📄",
--      start = "🚀",
--      task = "📌",
--      lazy = "💤 ",
--    },
--  },
})
