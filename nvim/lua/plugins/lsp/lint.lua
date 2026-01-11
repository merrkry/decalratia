---@type LazySpec
return {
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			require("lint").linters_by_ft = {
				-- NOTE: see options.lua for custom ft yaml.ghaction
				ghaction = { "actionlint" },
				nix = { "statix" },
			}
		end,
	},
}
