---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "LazyFile",
		opts = {
			max_lines = 8,
			min_window_height = 32,
			multiline_threshold = 4,
		},
	},
}
