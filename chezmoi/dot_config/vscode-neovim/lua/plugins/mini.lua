return {
	{
		"nvim-mini/mini.nvim",
		config = function()
			require("mini.ai").setup()
			require("mini.splitjoin").setup()
		end,
	},
}
