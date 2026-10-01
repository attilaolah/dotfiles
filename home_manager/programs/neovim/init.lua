vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- Bootstrap Lazy and all plugins.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- Home Manager replaces these generated files with symlinks into a new Nix store path on every switch.
-- Neovim's Lua bytecode cache keys the stable symlink path, which can otherwise retain a previous generation's store
-- paths. Load these tiny data modules from source to avoid stale plugin and grammar paths after an update.
local function load_nix_generated_module(name)
  local path = vim.fn.stdpath "config" .. "/lua/" .. name .. ".lua"
  local file = assert(io.open(path, "r"))
  local source = file:read "*a"
  file:close()
  return assert(loadstring(source, "@" .. path))()
end

local nix_plugins = load_nix_generated_module "nix-plugins"
local nix_treesitter_grammars = load_nix_generated_module "nix-treesitter-grammars"

-- Lazy may execute NvChad's Tree-sitter config before it loads the matching declarative plugin spec.
-- Nix packages Tree-sitter's Lua module at the package root and its queries below `runtime`; both are runtime roots.
local treesitter = nix_plugins["nvim-treesitter"]
vim.opt.rtp:prepend(treesitter .. "/runtime")
vim.opt.rtp:prepend(treesitter)

local lazy_config = require "configs.lazy"

-- Load plugins.
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- Lazy rebuilds the runtime path.
-- Add the declarative Tree-sitter package and grammar roots afterwards so parsers and queries remain discoverable.
vim.opt.rtp:append(treesitter)
vim.opt.rtp:append(treesitter .. "/runtime")
for _, grammar in ipairs(nix_treesitter_grammars) do
  vim.opt.rtp:append(grammar)
end

-- Base46 owns its complete cache lifecycle.
-- This is needed when Neovim's data directory has been cleared even though NvChad itself is installed.
local function load_base46_highlights()
  local mappings = vim.g.base46_cache .. "mappings"

  local ok, base46 = pcall(require, "base46")
  if not ok then
    vim.notify("Base46 could not be loaded: " .. base46, vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(mappings) == 0 then
    vim.fn.mkdir(vim.g.base46_cache, "p")
    local mappings_ok, mappings_err = pcall(base46.str_to_cache, "mappings", "")
    if not mappings_ok then
      vim.notify("Base46 mappings cache failed: " .. mappings_err, vim.log.levels.ERROR)
      return
    end
  end

  local loaded, load_err = pcall(base46.load_all_highlights)
  if not loaded then
    vim.notify("Base46 highlight loading failed: " .. load_err, vim.log.levels.ERROR)
  end
end

load_base46_highlights()

require "options"
require "nvchad.autocmds"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
