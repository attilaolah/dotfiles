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
    alejandra = { command = "@alejandra@" },
    black = { command = "@black@" },
    gofumpt = { command = "@gofumpt@" },
    ktfmt = {
      command = "@ktfmt@",
      prepend_args = { "--google-style" },
    },
    prettier = { command = "@prettier@" },
    rustfmt = { command = "@rustfmt@" },
    stylua = { command = "@stylua@" },
    usort = { command = "@usort@" },
    zigfmt = {
      command = "@zig@",
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
