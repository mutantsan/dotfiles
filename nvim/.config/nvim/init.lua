-- Leader has to be set before lazy.nvim loads any plugin.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('config.options')
require('config.keymaps')
require('config.lazy')
require('config.lsp')
