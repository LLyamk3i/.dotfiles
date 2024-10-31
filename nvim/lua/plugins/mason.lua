return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
        "deno",
        "ast-grep",
        "bash-language-server",
        "phpactor",
        "phpstan",
        "json-lsp",
      },
      run_on_start = true,
    },
  }
}
