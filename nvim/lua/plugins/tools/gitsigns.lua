---@type LazySpec
return {
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup({
				update_debounce = 1000,
			})
		end,
	},
}
