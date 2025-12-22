---@type LazySpec
return {
	{
		"chrisgrieser/nvim-origami",
		event = "VeryLazy",
		opts = {
			autoFold = {
				kinds = { "imports" }, ---@type lsp.FoldingRangeKind[]
			},
		},
		init = function()
			-- Disable vim's auto-folding
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
		end,
	},
}
