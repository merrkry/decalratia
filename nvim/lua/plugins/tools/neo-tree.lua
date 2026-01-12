---@type LazySpec
return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		lazy = false,
		opts = {
			close_if_last_window = true,
			popup_border_style = "", -- use `vim.owinborder`
			filesystem = {
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
			},
			window = {
				mappings = {
					["<leader>e"] = "close_window",
				},
			},
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree<CR>", desc = "Open file explorer" },
		},
	},
}
