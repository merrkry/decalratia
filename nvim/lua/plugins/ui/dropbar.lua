---@type LazySpec
return {
	{
		"Bekaboo/dropbar.nvim",
		event = "VeryLazy",
		-- optional, but required for fuzzy finder support
		-- dependencies = {
		--   'nvim-telescope/telescope-fzf-native.nvim',
		--   build = 'make'
		-- },
		config = function()
			local dropbar = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar.select_next_context, { desc = "Select next context" })
		end,
	},
}
