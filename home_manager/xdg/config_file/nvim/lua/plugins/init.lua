return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = function()
      return vim.load_nix_generated_module "configs.conform"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.load_nix_generated_module "configs.lspconfig"
    end,
  },
}
