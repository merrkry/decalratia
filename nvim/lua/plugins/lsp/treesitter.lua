---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
	},
	{
		"meanderingprogrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
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
