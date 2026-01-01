---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = "LazyFile",
	},
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "LazyFile",
		---@module 'treesitter-modules'
		---@type ts.mod.UserConfig
		opts = {
			ensure_installed = {
				"bash",
				"comment",
				"diff",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"regex",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			fold = { enable = false },
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = { enable = false },
		},
	},
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
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "LazyFile",
		opts = {
			max_lines = 16,
			min_window_height = 32,
			multiline_threshold = 16,
		},
	},
}
