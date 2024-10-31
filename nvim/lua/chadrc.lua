-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

-- In your chadrc.lua file
local opt = {
    -- Other options...
    guicursor = "n-v-c:block-Cursor/lCursor-blinkon0",  -- Set cursor to block and enable blinking
}

-- Apply the options
vim.opt.guicursor = opt.guicursor

return M
