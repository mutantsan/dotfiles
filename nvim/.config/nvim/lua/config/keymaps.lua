-- Plugin keymaps live next to their plugin in lua/plugins/.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

map('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- Keep the selection when indenting.
map('v', '<', '<gv')
map('v', '>', '>gv')

map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>cq', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })

-- Carried over from VS Code. Keys with Shift or Ctrl+Shift need a terminal
-- that reports them (kitty keyboard protocol); the shifted punctuation is
-- mapped in both forms a terminal may send.
map({ 'n', 'i', 'x' }, '<C-s>', '<Cmd>write<CR>', { desc = 'Save' })

for _, lhs in ipairs({ '<C-/>', '<C-_>' }) do
  map('n', lhs, 'gcc', { remap = true, desc = 'Toggle comment' })
  map('x', lhs, 'gc', { remap = true, desc = 'Toggle comment' })
  map('i', lhs, '<Cmd>normal gcc<CR>', { desc = 'Toggle comment' })
end

for _, lhs in ipairs({ '<M-{>', '<M-S-[>' }) do
  map('n', lhs, 'zc', { desc = 'Fold' })
end
for _, lhs in ipairs({ '<M-}>', '<M-S-]>' }) do
  map('n', lhs, 'zo', { desc = 'Unfold' })
end
for _, lhs in ipairs({ '<M-+>', '<M-S-=>' }) do
  map('n', lhs, '<cmd>vsplit<CR>', { desc = 'Split right' })
end
for _, lhs in ipairs({ '<M-_>', '<M-S-->' }) do
  map('n', lhs, '<cmd>only<CR>', { desc = 'Close other splits' })
end

map('n', '<C-S-x>', '<cmd>Lazy<CR>', { desc = 'Plugins' })

-- Deletes back to the previous camelCase or snake_case boundary.
local word_parts = { '%u?%l+[_%s]*$', '%u+[_%s]*$', '%d+[_%s]*$', '[_%s]+$' }
map('i', '<C-M-BS>', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before = vim.api.nvim_get_current_line():sub(1, col)
  for _, pattern in ipairs(word_parts) do
    local start = before:find(pattern)
    if start then
      vim.api.nvim_buf_set_text(0, row - 1, start - 1, row - 1, col, {})
      return
    end
  end
  -- Punctuation and non-ASCII text: plain delete-word.
  vim.api.nvim_feedkeys(vim.keycode('<C-w>'), 'ni', false)
end, { desc = 'Delete word part left' })
