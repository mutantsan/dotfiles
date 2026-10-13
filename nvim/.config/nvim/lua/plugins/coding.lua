return {
  {
    -- The main branch builds parsers with the tree-sitter CLI and a C compiler.
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'bash',
        'css',
        'diff',
        'dockerfile',
        'gitcommit',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'python',
        'query',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
      })
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Treesitter highlighting, where a parser is installed',
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter-textobjects').setup({ move = { set_jumps = true } })
      local move = require('nvim-treesitter-textobjects.move')
      local targets = { f = { '@function.outer', 'function' }, c = { '@class.outer', 'class' } }
      for key, target in pairs(targets) do
        local query, name = target[1], target[2]
        for lhs, spec in pairs({
          [']' .. key] = { move.goto_next_start, 'Next ' .. name },
          ['[' .. key] = { move.goto_previous_start, 'Previous ' .. name },
        }) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            -- In a diff, ]c and [c keep their meaning: next and previous change.
            if key == 'c' and vim.wo.diff then
              vim.cmd.normal({ lhs, bang = true })
            else
              spec[1](query, 'textobjects')
            end
          end, { desc = spec[2] })
        end
      end
    end,
  },

  {
    -- Not lazy: it registers its LSP capabilities when it loads, which has to
    -- happen before the first server starts.
    'saghen/blink.cmp',
    version = '1.*',
    lazy = false,
    opts = {
      keymap = { preset = 'default' }, -- <C-y> accept, <C-n>/<C-p> select, <C-space> open
      completion = { documentation = { auto_show = true } },
      signature = { enabled = true },
      -- Falls back to the Lua matcher if the prebuilt binary can't be loaded.
      fuzzy = { implementation = 'prefer_rust' },
    },
  },

  {
    -- Formatting is manual: <leader>cf. The formatters come from the system.
    'stevearc/conform.nvim',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true })
        end,
        mode = { 'n', 'v' },
        desc = 'Format',
      },
      {
        '<C-S-i>',
        function()
          require('conform').format({ async = true })
        end,
        mode = { 'n', 'v', 'i' },
        desc = 'Format',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        nix = { 'nixfmt' },
        python = { 'ruff_format' },
      },
      default_format_opts = { lsp_format = 'fallback' },
    },
  },
}
