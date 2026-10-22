require "nvchad.mappings"

for _, mode in ipairs { "n", "t" } do
  for _, lhs in ipairs { "<M-h>", "<M-v>", "<M-i>" } do
    pcall(vim.keymap.del, mode, lhs)
  end
end

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

map("n", ";", ":", { desc = "CMD enter command mode" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Ctrl + Alt/Meta + Arrow keys
map("n", "<C-M-Left>", "<cmd>TmuxNavigateLeft<CR>", opts)
map("n", "<C-M-Down>", "<cmd>TmuxNavigateDown<CR>", opts)
map("n", "<C-M-Up>", "<cmd>TmuxNavigateUp<CR>", opts)
map("n", "<C-M-Right>", "<cmd>TmuxNavigateRight<CR>", opts)
