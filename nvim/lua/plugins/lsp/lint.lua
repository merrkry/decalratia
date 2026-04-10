---@type LazySpec
return {
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			require("lint").linters_by_ft = require("lang").linters_by_ft()
		end,
	},
}
