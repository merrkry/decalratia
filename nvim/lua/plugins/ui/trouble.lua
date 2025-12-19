---@type LazySpec
return {
	{
		"folke/trouble.nvim",
		opts = {
			focus = true,
			-- NOTE: `gb` to toggle current buffer filter, `s` to cycle severity filter
			keys = { ["<CR>"] = "jump_close" },
		},
		cmd = "Trouble",
		keys = {
			{
				"<leader>D",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Show diagnostics panel",
			},
		},
	},
}
