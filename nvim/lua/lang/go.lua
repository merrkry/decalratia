return {
	{
		ft = { "go" },
		lsp = { "gopls" },
		formatters = {
			-- "goimports", -- FIXME: sometimes deletes used imports
			"gofumpt",
		},
		editPrediction = true,
	},
}
