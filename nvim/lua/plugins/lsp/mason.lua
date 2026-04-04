---@type LazySpec
return {
	{
		"mason-org/mason.nvim",
		event = "FileType",
		opts = {
			PATH = "prepend",
		},
		config = function(_, opts)
			require("mason").setup(opts)

			-- Non-lsp are not supported by mason-lspconfig's ensure_installed.
			local ensure_installed = {}

			if not ensure_installed then
				return
			end

			local mason_registry = require("mason-registry")

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
