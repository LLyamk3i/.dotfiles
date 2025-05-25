return {
  { import = "nvchad.blink.lazyspec" },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "rust",
        "css",
        "json",
        "bash",
        "blade",
        "php",
        "php_only",
        "vue",
        "javascript",
        "typescript",
      },
      highlight = {
        enable = true,
      },
    },
    config = function(_, opts)
      require "configs.treesitter"(opts)
    end,
  },

  {
    "mg979/vim-visual-multi", -- Plugin repository
    event = "VeryLazy", -- Load the plugin when Neovim is idle
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "phpactor",
        "ast-grep",
        "bash-language-server",
        "deno",
        "json-lsp",
        "python-lsp-server",
        "rust-analyzer",
        "clangd",
        "prettierd",
        "black",
        "isort",
        "pint",
        "beautysh",
        "intelephense",
        "volar",
        "tailwindcss-language-server",
      },
    },
  },
}
