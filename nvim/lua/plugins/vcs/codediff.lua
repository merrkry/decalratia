---@type LazySpec
return {
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		build = ":CodeDiff install",
		cmd = "CodeDiff",
	},
}
