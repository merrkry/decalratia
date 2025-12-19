---@type LazySpec
return {
	{
		"neovim/nvim-lspconfig",
		event = "FileType",
		config = require("utils.lsp").setup_lsp,
	},
}
