return {
	{
		ft = {},
		lsp = { "bashls", "mesonlsp", "typos_lsp" },
	},
	{
		ft = { "yaml.ghaction" }, -- also recognizes `ghaction`
		linters = { "actionlint" },
	},
}
