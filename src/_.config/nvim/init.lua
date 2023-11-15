vim.opt.mouse = 'v'
vim.opt.number = true

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wildmenu = true

vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)

  require('lazy').setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
  {'airblade/vim-gitgutter'},
  {'folke/tokyonight.nvim'},
  {'nvim-lualine/lualine.nvim'},
})

vim.opt.termguicolors = true
vim.cmd.colorscheme('slate')

require('lualine').setup({
  options = {
    icons_enabled = false,
    section_separators = '',
    component_separators = ''
  }
})
