-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Nix substitutes these values with immutable store paths when deploying this file.
local executables = {
  cssls = "@vscode-css-language-server@",
  gopls = "@gopls@",
  helm_ls = "@helm_ls@",
  html = "@vscode-html-language-server@",
  kotlin_language_server = "@kotlin-language-server@",
  lua_ls = "@lua-language-server@",
  nil_ls = "@nil@",
  pyright = "@pyright-langserver@",
  rust_analyzer = "@rust-analyzer@",
  ts_ls = "@typescript-language-server@",
  yamlls = "@yaml-language-server@",
  zls = "@zls@",
}

local servers = {
  "cssls",
  "gopls",
  "helm_ls",
  "html",
  "kotlin_language_server",
  "nil_ls",
  "pyright",
  "rust_analyzer",
  "ts_ls",
  "yamlls",
  "zls",
  -- "ansiblels", -- unmaintained
}

vim.lsp.config("*", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
})

vim.lsp.config("cssls", { cmd = { executables.cssls, "--stdio" } })

-- Go
vim.lsp.config("gopls", {
  cmd = { executables.gopls },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
    },
  },
})

-- Helm
vim.lsp.config("helm_ls", {
  cmd = { executables.helm_ls, "serve" },
  settings = {
    ["helm-ls"] = {
      yamlls = {
        path = executables.yamlls,
      },
    },
  },
})

vim.lsp.config("html", { cmd = { executables.html, "--stdio" } })
vim.lsp.config("kotlin_language_server", { cmd = { executables.kotlin_language_server } })
vim.lsp.config("lua_ls", { cmd = { executables.lua_ls } })
vim.lsp.config("nil_ls", { cmd = { executables.nil_ls } })
vim.lsp.config("pyright", { cmd = { executables.pyright, "--stdio" } })
vim.lsp.config("rust_analyzer", { cmd = { executables.rust_analyzer } })
vim.lsp.config("ts_ls", { cmd = { executables.ts_ls, "--stdio" } })

-- YAML
vim.lsp.config("yamlls", {
  cmd = { executables.yamlls, "--stdio" },
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
    },
  },
})

vim.lsp.config("zls", { cmd = { executables.zls } })

-- Enable LSPs only after their Nix-backed commands have been configured.
vim.lsp.enable(servers)
