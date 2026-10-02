-- Nix substitutes these values with immutable store paths when deploying this file.
local executables = {
  alejandra = "@alejandra@",
  black = "@black@",
  gofumpt = "@gofumpt@",
  ktfmt = "@ktfmt@",
  prettier = "@prettier@",
  rustfmt = "@rustfmt@",
  stylua = "@stylua@",
  usort = "@usort@",
  zig = "@zig@",
}

local options = {
  formatters_by_ft = {
    css = { "prettier" },
    go = { "gofumpt" },
    html = { "prettier" },
    kotlin = { "ktfmt" },
    lua = { "stylua" },
    nix = { "alejandra" },
    python = { "usort", "black" },
    rust = { "rustfmt" },
    zig = { "zigfmt" },
    ["_"] = { "trim_whitespace" },
  },

  formatters = {
    alejandra = { command = executables.alejandra },
    black = { command = executables.black },
    gofumpt = { command = executables.gofumpt },
    ktfmt = {
      command = executables.ktfmt,
      prepend_args = { "--google-style" },
    },
    prettier = { command = executables.prettier },
    rustfmt = { command = executables.rustfmt },
    stylua = { command = executables.stylua },
    usort = { command = executables.usort },
    zigfmt = {
      command = executables.zig,
      args = { "fmt", "--stdin" },
    },
  },

  format_on_save = function(bufnr)
    local slow = vim.tbl_contains({
      "python", -- black is slow
      "kotlin", -- ktfmt is slow
    }, vim.bo[bufnr].filetype)
    return {
      timeout_ms = slow and 2000 or 500,
      lsp_format = "fallback",
    }
  end,
}

return options
