---@type vim.lsp.Config
return {
	cmd = {
		"clangd",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--enable-config",
		"--fallback-style=Google",
	},
}
