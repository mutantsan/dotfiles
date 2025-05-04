---@diagnostic disable: undefined-global

-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- toggle neotree visibility
vim.keymap.set("n", "<C-n>", function()
	require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
end, { desc = "Toggle Neo-tree" })
