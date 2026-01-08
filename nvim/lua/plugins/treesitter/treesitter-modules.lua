---@type LazySpec
return {
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
}
