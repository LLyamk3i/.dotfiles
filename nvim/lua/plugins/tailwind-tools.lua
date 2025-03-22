-- ~/.config/nvim/lua/custom/plugins.lua
local nvlsp = require "nvchad.configs.lspconfig"

local plugins = {
  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      server = {
        override = true,
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
      },
      -- Additional configurations for tailwind-tools.nvim
    },
  },
}

return plugins
