---@type LazySpec
return {
	{
		"rachartier/tiny-code-action.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
		event = "LspAttach",
		opts = {
			backend = "difftastic",
			picker = "snacks",
		},
		keys = {
			{
				"<leader>a",
				function()
					require("tiny-code-action").code_action()
				end,
				desc = "Code actions",
			},
		},
	},
}
