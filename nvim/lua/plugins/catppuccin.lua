---@diagnostic disable: undefined-global

return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		local config = require("catppuccin")
		config.setup({
			flavour = "frappe",
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = false,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
			},
		})

		-- setup must be called before loading
		vim.cmd.colorscheme("catppuccin-latte")
	end,
}
