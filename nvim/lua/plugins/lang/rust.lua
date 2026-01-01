---@type LazySpec
return {
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		tag = "stable",
		config = function()
			require("crates").setup({
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
			})
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "*",
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				server = {
					---@diagnostic disable-next-line: undefined-field
					default_settings = vim.lsp.config["rust_analyzer"].settings,
				},
			}
		end,
	},
}
