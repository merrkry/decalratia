---@type vim.lsp.Config
return {
	-- https://zed.dev/docs/languages/typescript
	settings = {
		javascript = {
			inlayHints = {
				parameterNames = {
					enabled = "all",
					suppressWhenArgumentMatchesName = false,
				},
				parameterTypes = {
					enabled = true,
				},
				variableTypes = {
					enabled = true,
					suppressWhenTypeMatchesName = true,
				},
				propertyDeclarationTypes = {
					enabled = true,
				},
				functionLikeReturnTypes = {
					enabled = true,
				},
				enumMemberValues = {
					enabled = true,
				},
			},
		},
		typescript = {
			inlayHints = {
				parameterNames = {
					enabled = "all",
					suppressWhenArgumentMatchesName = false,
				},
				parameterTypes = {
					enabled = true,
				},
				variableTypes = {
					enabled = true,
					suppressWhenTypeMatchesName = true,
				},
				propertyDeclarationTypes = {
					enabled = true,
				},
				functionLikeReturnTypes = {
					enabled = true,
				},
				enumMemberValues = {
					enabled = true,
				},
			},
		},
	},
}
