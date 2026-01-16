---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		opts = {
			-- Although some of these formatters are also provided via LSP,
			-- it is useful to format through conform in scenarios where project root
			-- markers doesn't exist, e.g. when editing config files.
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
				toml = { "taplo" },
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
