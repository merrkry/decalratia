---@type LazySpec
return {
	{
		"max397574/better-escape.nvim",
		opts = {
			timeout = 100,
			default_mappings = false,
			mappings = {
				t = {
					j = {
						k = "<C-\\><C-n>",
					},
				},
			},
		},
	},
}
