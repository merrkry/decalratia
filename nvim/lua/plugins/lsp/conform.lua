---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		opts = {
			formatters_by_ft = {
				bib = { "tex-fmt" },
				cls = { "tex-fmt" },
				css = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				kdl = { "kdlfmt" },
				lua = { "stylua" },
				markdown = { "prettier" },
				sty = { "tex-fmt" },
				tex = { "tex-fmt" },
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
