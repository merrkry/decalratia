local M = {}

M.default_lsp = {
	"bashls",
	"clangd",
	"emmylua_ls",
	"gopls",
	"jsonls",
	"mesonlsp",
	"nixd",
	"pyrefly",
	"ruff",
	-- "rust_analyzer", -- managed by rustaceanvim
	"taplo",
	"texlab",
	"tinymist",
	"typos_lsp",
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

M.disable_treesitter = {
	"csv",
}

return M
