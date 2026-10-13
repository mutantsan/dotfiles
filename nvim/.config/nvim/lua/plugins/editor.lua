return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = {
      { '<C-p>', '<cmd>FzfLua files<CR>', desc = 'Find files' },
      -- Needs a terminal that tells it apart from <C-p> (kitty keyboard protocol).
      { '<C-S-p>', '<cmd>FzfLua commands<CR>', desc = 'Commands' },
      { '<leader><space>', '<cmd>FzfLua files<CR>', desc = 'Find files' },
      { '<leader>ff', '<cmd>FzfLua files<CR>', desc = 'Files' },
      { '<leader>fg', '<cmd>FzfLua live_grep<CR>', desc = 'Grep' },
      { '<M-f>', '<cmd>FzfLua live_grep<CR>', desc = 'Grep' },
      { '<C-f>', '<cmd>FzfLua blines<CR>', desc = 'Search in file' },
      { '<C-S-g>', '<cmd>FzfLua git_status<CR>', desc = 'Changed files' },
      { '<leader>fw', '<cmd>FzfLua grep_cword<CR>', desc = 'Word under cursor' },
      { '<leader>fb', '<cmd>FzfLua buffers<CR>', desc = 'Buffers' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<CR>', desc = 'Recent files' },
      { '<leader>fh', '<cmd>FzfLua helptags<CR>', desc = 'Help' },
      { '<leader>fk', '<cmd>FzfLua keymaps<CR>', desc = 'Keymaps' },
      { '<M-k>', '<cmd>FzfLua keymaps<CR>', desc = 'Keymaps' },
      { '<leader>fd', '<cmd>FzfLua diagnostics_workspace<CR>', desc = 'Diagnostics' },
      { '<leader>fs', '<cmd>FzfLua lsp_document_symbols<CR>', desc = 'Document symbols' },
      { '<leader>f.', '<cmd>FzfLua resume<CR>', desc = 'Resume last picker' },
    },
    opts = {},
  },

  {
    -- Type a few characters of the target, then the label shown on it.
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
      {
        's',
        function()
          require('flash').jump()
        end,
        mode = { 'n', 'x', 'o' },
        desc = 'Jump',
      },
    },
    opts = {},
  },

  {
    'stevearc/oil.nvim',
    -- Not lazy, so that `nvim <dir>` opens in oil.
    lazy = false,
    keys = {
      { '-', '<cmd>Oil<CR>', desc = 'Open parent directory' },
      { '<C-S-e>', '<cmd>Oil<CR>', desc = 'Open parent directory' },
    },
    opts = {
      view_options = { show_hidden = true },
      -- Oil's buffer-local defaults would shadow the global maps for these keys.
      keymaps = {
        ['<C-p>'] = false, -- preview, moved to gp
        ['gp'] = 'actions.preview',
        ['<C-h>'] = false, -- open in a horizontal split
        ['<C-l>'] = false, -- refresh, moved to <M-r>
        ['<M-r>'] = 'actions.refresh',
        -- New entries are lines in the buffer, created on :w. A trailing
        -- slash makes a directory.
        ['<M-n>'] = { 'o', desc = 'New file' },
        ['<M-N>'] = { 'o/<Left>', desc = 'New folder' },
        ['<M-S-n>'] = { 'o/<Left>', desc = 'New folder' },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map('n', ']h', function()
          gs.nav_hunk('next')
        end, 'Next hunk')
        map('n', '[h', function()
          gs.nav_hunk('prev')
        end, 'Previous hunk')
        map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>gb', function()
          gs.blame_line({ full = true })
        end, 'Blame line')
        map('n', '<leader>gd', gs.diffthis, 'Diff this')
      end,
    },
  },

  {
    'echasnovski/mini.nvim',
    lazy = false,
    config = function()
      require('mini.icons').setup()
      -- Stands in for nvim-web-devicons (fzf-lua, oil and lualine ask for it).
      MiniIcons.mock_nvim_web_devicons()
      require('mini.pairs').setup()
      -- Under gs, so that plain s is free for flash.
      require('mini.surround').setup({
        mappings = {
          add = 'gsa',
          delete = 'gsd',
          replace = 'gsr',
          find = 'gsf',
          find_left = 'gsF',
          highlight = 'gsh',
          update_n_lines = 'gsn',
        },
      })
      require('mini.ai').setup()
    end,
  },
}
