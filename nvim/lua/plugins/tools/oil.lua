---@type LazySpec
return {
	{
		"stevearc/oil.nvim",
		dependencies = { { "echasnovski/mini.nvim", opts = {} } },
		lazy = false, -- discrouaged by the author
		keys = {
			{ "<leader>E", "<cmd>Oil<cr>", desc = "Open buffer file explorer" },
		},
		config = function()
			require("oil").setup({
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				prompt_save_on_select_new_entry = true,
				lsp_file_methods = {
					autosave_changes = true,
				},
				watch_for_changes = true,

				keymaps = {
					["<C-h>"] = false,
					["<C-l"] = false,
					-- <C-p> to preview with automatically selected position
					["<A-h>"] = { "actions.select", opts = { horizontal = true } },
					["<A-v>"] = { { "actions.select", opts = { vertical = true } } },
				},
				view_options = {
					show_hidden = true,
				},
			})
		end,
	},
}
