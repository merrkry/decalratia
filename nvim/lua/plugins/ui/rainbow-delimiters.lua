--- TODO: consider migrate to blink.pairs, after
--- https://github.com/saghen/blink.pairs/issues/69 and mismatch highlighting issues resolved
---@type LazySpec
return {
	"HiPhish/rainbow-delimiters.nvim",
	event = "VeryLazy",
	config = function()
		require("rainbow-delimiters.setup").setup({
			highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterOrange",
				"RainbowDelimiterYellow",
				"RainbowDelimiterGreen",
				"RainbowDelimiterCyan",
				"RainbowDelimiterBlue",
				"RainbowDelimiterViolet",
			},
		})
	end,
}
