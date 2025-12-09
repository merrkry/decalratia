return {
	{
		"nvim-mini/mini.nvim",
		config = function()
			require("mini.ai").setup()
			require("mini.comment").setup()
			require("mini.splitjoin").setup()
			require("mini.surround").setup()
		end,
	},
}
