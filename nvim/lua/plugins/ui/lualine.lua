---@type LazySpec
return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"AndreM222/copilot-lualine",
		},
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
				},
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
						},
					},
					lualine_x = {
						"copilot",
						{
							"lsp_status",
							ignore_lsp = { "copilot" },
						},
					},
				},
			})
		end,
	},
}
