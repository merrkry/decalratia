---@type LazySpec
return {
	{
		"stevearc/oil.nvim",
		event = "VeryLazy",
		-- Load oil.nvim when opening a directory
		-- Reference: https://github.com/Parsifa1/nvim/blob/6d5a8233d8c45ec1e456abe619c1a97c6333630a/lua/plugins/ui/oil.lua
		init = function()
			if vim.fn.argc() == 1 then
				require("lazy").load({ plugins = { "oil.nvim" } })
			end
			if not require("lazy.core.config").plugins["oil.nvim"]._.loaded then
				vim.api.nvim_create_autocmd("BufNew", {
					callback = function()
						if vim.fn.isdirectory(vim.fn.expand("<afile>")) == 1 then
							require("lazy").load({ plugins = { "oil.nvim" } })
							return true
						end
					end,
				})
			end
		end,
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
