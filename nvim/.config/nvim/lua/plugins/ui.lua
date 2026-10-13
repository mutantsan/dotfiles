-- The Noctalia shell's nvim template (nixos-config) writes its current palette
-- here. On machines without it the file is missing and Nord keeps its colours.
local noctalia_palette = vim.fn.stdpath('data') .. '/noctalia.lua'

local function load_colorscheme()
  local ok, n = pcall(dofile, noctalia_palette)

  require('nord').setup({
    on_colors = function(c)
      if not ok then
        return
      end
      c.polar_night.origin = n.surface
      c.polar_night.bright = n.surface_container
      c.polar_night.brighter = n.surface_container_high
      c.polar_night.brightest = n.outline_variant
      c.polar_night.light = n.outline
      c.snow_storm.origin = n.on_surface
      c.snow_storm.brighter = n.on_surface
      c.snow_storm.brightest = n.on_surface
      c.frost.polar_water = n.tertiary
      c.frost.ice = n.primary
      c.frost.artic_water = n.secondary
      c.frost.artic_ocean = n.terminal_normal_blue
      c.aurora.red = n.error
      c.aurora.orange = n.terminal_bright_red
      c.aurora.yellow = n.terminal_normal_yellow
      c.aurora.green = n.terminal_normal_green
      c.aurora.purple = n.terminal_normal_magenta
    end,
    on_highlights = function(hl)
      if ok then
        -- Nord puts its lightest text on the accent here, unreadable when the
        -- accent is itself a light colour.
        hl.IncSearch = { fg = n.on_primary, bg = n.primary }
      end
    end,
  })
  if ok then
    require('nord.colors').default_bg = n.surface
    vim.o.background = n.mode
  end
  vim.cmd.colorscheme('nord')
end

return {
  {
    'gbprod/nord.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      load_colorscheme()
      -- Noctalia signals running instances when the palette changes. nested,
      -- so lualine's ColorScheme handler runs too.
      vim.api.nvim_create_autocmd('Signal', {
        pattern = 'SIGUSR1',
        nested = true,
        callback = load_colorscheme,
      })
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = { theme = 'nord', globalstatus = true },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>b', group = 'buffer' },
        { '<leader>c', group = 'code' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { 'gs', group = 'surround' },
      },
    },
  },
}
