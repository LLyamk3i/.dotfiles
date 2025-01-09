-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "ast_grep", "bashls", "jsonls", "pylsp", "intelephense", "vuels" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- configuring single server, example: typescript
lspconfig.denols.setup {
  on_attach = function(client, bufnr)
    if vim.fn.filereadable(vim.fn.getcwd() .. "/deno.json") == 1 then
      if client.name == "tsserver" then
        client.stop()
        print "Stopped tsserver because deno.json was found."
      end
    else
      nvlsp.on_attach(client, bufnr)
    end
  end,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  single_file_support = false,
}

lspconfig.ts_ls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  root_dir = lspconfig.util.root_pattern "package.json",
  single_file_support = true,
}

lspconfig.phpactor.setup {
  root_dir = function(_)
    return vim.loop.cwd()
  end,
  on_init = nvlsp.on_init,
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  init_options = {
    ["language_server.diagnostics_on_update"] = false,
    ["language_server.diagnostics_on_open"] = false,
    ["language_server.diagnostics_on_save"] = false,
    ["language_server_phpstan.enabled"] = false,
    ["language_server_psalm.enabled"] = false,
  },
}
