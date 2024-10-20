require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
-- local functions = require("custom.functions")

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Key mapping for toggling nvim-tree
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Move line up
map("n", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })

-- Move line down
map("n", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true })

-- Map Alt + d to yank the current line and paste it above
map('n', '<A-d>', 'yyP', { noremap = true, silent = true })

-- Key mapping to test the add function
map('v', '<leader>cp', function () require('custom.functions').copyq() end, { noremap = true, silent = true, desc = "Copy selected strings" })
