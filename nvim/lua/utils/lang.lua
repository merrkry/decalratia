local M = {}

M.default_lsp = {
	"basedpyright",
	"bashls",
	"clangd",
	"emmylua_ls",
	"gopls",
	"mesonlsp",
	"nixd",
	"ruff",
	"rust_analyzer",
	"taplo",
	"tinymist",
	"vtsls",
}

M.allow_copilot = {
	"c",
	"cpp",
	"go",
	"javascript",
	"lua",
	"python",
	"rust",
	"typescript",
}

return M
