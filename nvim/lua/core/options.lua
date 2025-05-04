---@diagnostic disable: undefined-global

vim.cmd("set expandtab") -- Use spaces instead of tabs
vim.cmd("set tabstop=4") -- Set tab width to 2 spaces
vim.cmd("set softtabstop=4") -- Set soft tab width to 2 spaces
vim.cmd("set shiftwidth=4") -- Set shift width to 2 spaces

vim.opt.clipboard = "unnamedplus" -- Use system clipboard as default
vim.opt.number = true -- Show absolute line number on the current line
vim.opt.relativenumber = true -- Show relative line numbers on other lines

-- Tree-sitter-based foldings
vim.opt.foldlevel = 20
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = "\\" -- Set local leader key to backslash

vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Can be '■', '▎', 'x'
		spacing = 2,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
