---@type LazySpec
return {
	{
		"m4xshen/hardtime.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			notification = false,
			disable_mouse = false,
			-- https://github.com/m4xshen/hardtime.nvim/blob/6d7664d5bdfaea44c5f50b29f5239fab7b00c273/lua/hardtime/config.lua#L50-L61
			restricted_keys = {
				["h"] = false,
				["j"] = false,
				["k"] = false,
				["l"] = false,
				["+"] = false,
				["gj"] = false,
				["gk"] = false,
				["<C-M>"] = false,
				["<C-N>"] = false,
				["<C-P>"] = false,
			},
			disabled_keys = {
				["<Up>"] = false,
				["<Down>"] = false,
				["<Left>"] = false,
				["<Right>"] = false,
			},
		},
	},
}
