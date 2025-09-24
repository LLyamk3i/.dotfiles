return {
  "github/copilot.vim",
  lazy = false, -- This tells Lazy.nvim to always load this plugin
  config = function()
    vim.keymap.set("i", "<C-F>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.g.copilot_no_tab_map = true
  end,
}
