return {
	{
		ft = { "python" },
		lsp = { "ruff", "zuban" },
		formatters = {
			"ruff_format",
			"ruff_organize_imports",
			-- "ruff_fix",
		},
		editPrediction = true,
	},
}
