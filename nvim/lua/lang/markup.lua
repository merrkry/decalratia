return {
	{
		ft = { "json", "jsonc" },
		lsp = { "jsonls" },
		formatters = { "oxfmt" },
	},
	{
		ft = { "markdown", "yaml" },
		formatters = { "oxfmt" },
	},
	{
		ft = { "kdl" },
		formatters = { "kdlfmt" },
	},
	{
		ft = { "toml" },
		lsp = { "taplo" },
		formatters = { "taplo" },
	},
}
