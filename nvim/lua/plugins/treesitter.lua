return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")

		config.setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"python",
				"javascript",
				"typescript",
				"rust",
				"bash",
				"markdown",
				"markdown_inline",
				"jinja",
				"yaml",
				"json",
				"toml",
				"dockerfile",
				"gitignore",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
		})
	end,
}
