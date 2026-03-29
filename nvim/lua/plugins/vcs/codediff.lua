-- Note that for inline mode, or "current version" buffer in side-by-side mode,
-- the buffer points directly to the original file. This mean the diff view shares
-- the same per-buffer settings, e.g. inlay hints, as non-diff views.

---@type LazySpec
return {
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		build = ":CodeDiff install",
		cmd = "CodeDiff",
		opts = {
			explorer = {
				view_mode = "tree",
			},
		},
		keys = {
			{
				"<leader>c",
				"<cmd>CodeDiff --inline<CR>",
				desc = "Show git diff",
			},
		},
	},
}
