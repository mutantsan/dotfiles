local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.showmode = false -- lualine shows it
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.winborder = 'rounded'

-- Two spaces by default; ftplugins override it (Python sets 4).
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.inccommand = 'split'

o.splitright = true
o.splitbelow = true

o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.undofile = true
o.confirm = true
o.updatetime = 250
o.timeoutlen = 400

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = true,
  float = { source = true },
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Flash the yanked text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Treesitter folds, all open to start with.
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevel = 99
o.foldtext = ''
