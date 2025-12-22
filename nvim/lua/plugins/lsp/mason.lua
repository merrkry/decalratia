---@type LazySpec
return {
	{
		"mason-org/mason.nvim",
		event = "FileType",
		opts = {
			PATH = "append",
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "FileType",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {},
		},
	},
}
