---@type LazySpec
return {
	{
		"mason-org/mason.nvim",
		event = "Filetype",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "Filetype",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {},
		},
	},
}
