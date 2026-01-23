---@type LazySpec
return {
	-- To avoid race conditions, these should be loaded manually in our LSP setup module.
	{
		"felpafel/inlay-hint.nvim",
		branch = "nightly",
		lazy = true,
		opts = {
			virt_text_pos = "inline",
			-- `replace` will cause https://github.com/neovim/neovim/issues/24152
			-- `combine` will cause https://github.com/neovim/neovim/issues/24094
			-- Upstream chose `replace` and mark the latter as not planned.
			-- But IMO the latter is far more annoying.
			hl_mode = "combine",
		},
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		lazy = true,
		opts = {
			autoEnableHints = false,
			icons = {
				type = "∷ ",
				parameter = "⊸ ",
				unknown = "",
			},
			label = {
				truncateAtChars = 64,
			},
		},
	},
}
