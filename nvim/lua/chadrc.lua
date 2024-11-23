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

-- Automatically open the file explorer on startup
vim.cmd([[autocmd VimEnter * NvimTreeToggle]])

-- Enable spell checking
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require'nvim-tree'.setup {
    filters = {
        git_ignored = false,  -- Set to false to show git ignored files
    },
}


return M
