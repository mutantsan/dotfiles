-- A project's own [tool.pyright] config makes basedpyright ignore the editor
-- settings below and fall back to its "recommended" rules, so these are
-- dropped on the client instead.
local ignored = { reportAny = true, reportExplicitAny = true }

-- Single messages, for rules that are otherwise worth keeping
-- (this one is reportCallIssue).
local ignored_messages = { '^No overloads for ' }

local function is_ignored(d)
  if ignored[d.code] then
    return true
  end
  for _, pattern in ipairs(ignored_messages) do
    if d.message:find(pattern) then
      return true
    end
  end
  return false
end

local function without_ignored(diagnostics)
  return vim.tbl_filter(function(d)
    return not is_ignored(d)
  end, diagnostics)
end

-- Source directories of the virtualenv's editable installs. setuptools
-- installs them behind an import hook, which a static checker can't follow,
-- so they are read from the hook's MAPPING table and passed as extraPaths.
local function editable_paths(venv)
  local paths, seen = {}, {}
  local finders = vim.fn.glob(venv .. '/lib/python*/site-packages/__editable___*_finder.py', true, true)
  for _, finder in ipairs(finders) do
    for line in io.lines(finder) do
      if line:find('^MAPPING') then
        for name, path in line:gmatch("'([^']+)': '([^']+)'") do
          -- 'a.b' mapped to <src>/a/b: go up one level per name component.
          local dir = path
          for _ in name:gmatch('[^.]+') do
            dir = vim.fs.dirname(dir)
          end
          if not seen[dir] then
            seen[dir] = true
            paths[#paths + 1] = dir
          end
        end
        break
      end
    end
  end
  return paths
end

return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'pyrightconfig.json',
    '.git',
  },
  settings = {
    basedpyright = {
      -- The default, "recommended", is very noisy on untyped code.
      analysis = { typeCheckingMode = 'standard' },
    },
    python = {},
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx)
      if result and result.diagnostics then
        result.diagnostics = without_ignored(result.diagnostics)
      end
      return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
    end,
    ['textDocument/diagnostic'] = function(err, result, ctx)
      if result and result.items then
        result.items = without_ignored(result.items)
      end
      return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
    end,
  },
  before_init = function(_, config)
    -- The active virtualenv, or else the nearest .venv at or above the root.
    local venv = vim.env.VIRTUAL_ENV
    if not venv and config.root_dir then
      venv = vim.fs.find('.venv', { path = config.root_dir, upward = true, type = 'directory' })[1]
      if venv then
        config.settings.python.pythonPath = venv .. '/bin/python'
      end
    end
    if venv then
      config.settings.basedpyright.analysis.extraPaths = editable_paths(venv)
    end
  end,
}
