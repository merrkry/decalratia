---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		opts = {
			formatters_by_ft = {
				css = { "prettier" },
				kdl = { "kdlfmt" },
				lua = { "stylua" },
				markdown = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				["_"] = { "trim_whitespace" },
			},
			default_format_opts = {
				lsp_format = "first",
			},
			format_on_save = {},
		},
	},
}
