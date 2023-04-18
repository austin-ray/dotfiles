-- ~/.config/nvim/lua/config/base.lua
require("config.base")

-- Try loading a work configuration.
-- ~/.config/nvim/lua/config/work.lua
pcall(require, "config.work")
