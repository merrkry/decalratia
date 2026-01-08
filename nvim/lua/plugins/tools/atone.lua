---@type LazySpec
return {
	{
		"XXiaoA/atone.nvim",
		cmd = "Atone",
		opts = {
			layout = {
				width = 0.2,
			},
			ui = {
				compact = true,
			},
		},
		keys = {
			{ "<leader>u", "<cmd>Aton toggle<cr>", desc = "Open undotree" },
		},
	},
}
