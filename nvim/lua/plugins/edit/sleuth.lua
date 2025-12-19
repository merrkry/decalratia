---@type LazySpec
return {
	{
		"tpope/vim-sleuth",
		event = "VeryLazy",
		cond = not vim.g.vscode,
	},
}
