---@type LazySpec
return {
	{
		"julienvincent/hunk.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = { "DiffEditor" },
		opts = {
			ui = {
				tree = {
					width = 50,
				},
				layout = "horizontal",
			},
		},
	},
}
