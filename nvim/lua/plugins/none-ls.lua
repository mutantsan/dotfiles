return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.completion.spell,
        -- python
        null_ls.builtins.diagnostics.pylint.with({
          diagnostics_postprocess = function(diagnostic)
            diagnostic.code = diagnostic.message_id
          end,
        }),
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.black,
        -- javascript
        null_ls.builtins.formatting.prettier,
      },

      vim.keymap.set("n", ",f", vim.lsp.buf.format, {}),
    })
  end,
}
