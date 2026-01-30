---@type LazySpec
return {
	{
		enabled = true,
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "markdown" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			render_modes = true,
			latex = {
				enabled = false,
			},
		},
		config = function(_, opts)
			require("utils.treesitter").install_parsers({
				"markdown",
				"markdown_inline",
				"html",
				"yaml",
			})

			require("render-markdown").setup(opts)
		end,
	},
}
