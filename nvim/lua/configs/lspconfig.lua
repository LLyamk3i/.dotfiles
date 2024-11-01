-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "ast_grep", "bashls", "jsonls"}
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.phpactor.setup{
  cmd = { "phpactor", "language-server" },  -- Adjust the command if necessary
  filetypes = { "php" },
  root_dir = function()
    return vim.fn.getcwd()  -- Use the current directory as the root
  end,
  on_init = nvlsp.on_init,
  n_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
}

-- configuring single server, example: typescript
lspconfig.denols.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  single_file_support = false
}

-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
--   root_dir = lspconfig.util.root_pattern("package.json"),
-- }

