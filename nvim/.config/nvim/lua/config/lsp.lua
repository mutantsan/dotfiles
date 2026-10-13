-- Server definitions are in lsp/<name>.lua. The servers themselves come from
-- the system (nixpkgs on NixOS), so a server that isn't installed is skipped.
local servers = { 'lua_ls', 'nixd', 'basedpyright', 'ruff' }

for _, name in ipairs(servers) do
  local cmd = vim.lsp.config[name].cmd
  if type(cmd) == 'table' and vim.fn.executable(cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end

-- Neovim maps the rest by default: grn rename, gra code action, grr
-- references, gri implementation, grt type definition, gO symbols, K hover.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
    end
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('<leader>ch', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, 'Toggle inlay hints')
  end,
})
