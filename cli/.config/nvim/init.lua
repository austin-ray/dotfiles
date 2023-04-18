-- ~/.config/nvim/lua/config/base.lua
require("config.base")

-- Automatically install the `lazy` plugin manager.
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

-- ~/.config/nvim/lua/config/plugins
require("lazy").setup("config.plugins")

-- Try loading a work configuration.
-- ~/.config/nvim/lua/config/work.lua
pcall(require, "config.work")
