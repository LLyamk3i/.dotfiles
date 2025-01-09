return {
  {
    "gbprod/phpactor.nvim",
    ft = "php",
    build = function()
      require "phpactor.handler.update"()
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },
}
