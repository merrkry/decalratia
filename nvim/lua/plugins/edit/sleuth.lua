---@type LazySpec
return {
	{
		"tpope/vim-sleuth",
		event = "LazyFile",
		cond = not vim.g.vscode,
	},
}
