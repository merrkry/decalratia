---@type vim.lsp.Config
return {
	settings = {
		gopls = {
			gofumpt = true,
			semanticTokens = true,
			usePlaceholders = true,
			staticcheck = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				ignoredError = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}
