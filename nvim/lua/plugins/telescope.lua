---@diagnostic disable: undefined-global

require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "node_modules/",
            "dist/",
            "build/",
            "__pycache__/",
            "webassets",
            "^webassets-external",
        },
    },
})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
