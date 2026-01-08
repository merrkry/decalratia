---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "LazyFile",
		opt = {
			select = {
				lookahead = true,
				include_surrounding_whitespace = false,
			},
		},
	},
}
