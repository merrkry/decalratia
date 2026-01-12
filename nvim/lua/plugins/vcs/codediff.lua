---@type LazySpec
return {
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		build = ":CodeDiff install",
		cmd = "CodeDiff",
		opts = {
			explorer = {
				view_mode = "tree",
			},
		},
		keys = {
			{
				"<leader>c",
				"<cmd>CodeDiff<CR>",
				desc = "Show git diff",
			},
		},
	},
}
