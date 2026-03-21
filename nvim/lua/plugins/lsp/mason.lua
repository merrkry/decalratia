---@type LazySpec
return {
	{
		"mason-org/mason.nvim",
		event = "FileType",
		build = ":MasonUpdate",
		opts = {
			PATH = "prepend",
		},
		config = function(_, opts)
			require("mason").setup(opts)

			local mason_registry = require("mason-registry")

			-- Non-lsp are not supported by mason-lspconfig's ensure_installed.
			-- Consider using vim.pack after 0.12 release.
			local ensure_installed = {
				"tree-sitter-cli",
			}

			for _, pkg in ipairs(ensure_installed) do
				if not mason_registry.is_installed(pkg) then
					vim.cmd({ cmd = "MasonInstall", args = { pkg } })
				end
			end
		end,
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
