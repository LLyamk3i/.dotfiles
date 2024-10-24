return {
  -- ncm2 auto-completion engine
  {
    'ncm2/ncm2' ,
    event = 'BufRead',
    config = function()
      vim.opt.completeopt = { "noinsert", "menuone", "noselect" }
    end,

  },

  -- Completion sources for ncm2
  { 'ncm2/ncm2-bufword', event="BufRead"},
  { 'ncm2/ncm2-path', event="BufRead" },
}
