-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Nix substitutes these values with immutable store paths when deploying this file.
local servers = {
  cssls = { cmd = { "@vscode-css-language-server@", "--stdio" } },
  gopls = {
    cmd = { "@gopls@" },
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        gofumpt = true,
        staticcheck = true,
        usePlaceholders = true,
      },
    },
  },
  helm_ls = {
    cmd = { "@helm-ls@", "serve" },
    settings = {
      ["helm-ls"] = {
        yamlls = { path = "@yaml-language-server@" },
      },
    },
  },
  html = { cmd = { "@vscode-html-language-server@", "--stdio" } },
  kotlin_language_server = { cmd = { "@kotlin-language-server@" } },
  lua_ls = { cmd = { "@lua-language-server@" } },
  nil_ls = { cmd = { "@nil@" } },
  pyright = { cmd = { "@pyright-langserver@", "--stdio" } },
  rust_analyzer = { cmd = { "@rust-analyzer@" } },
  ts_ls = { cmd = { "@typescript-language-server@", "--stdio" } },
  yamlls = {
    cmd = { "@yaml-language-server@", "--stdio" },
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        },
      },
    },
  },
  zls = { cmd = { "@zls@" } },
  -- ansiblels = {}, -- unmaintained
}

vim.lsp.config("*", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
})

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
