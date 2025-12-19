---@type LazySpec
return {
	{
		"nvim-mini/mini.nvim",
		lazy = false,
		config = function()
			require("mini.ai").setup()
			require("mini.comment").setup()
			require("mini.splitjoin").setup()
			require("mini.surround").setup()

			if not vim.g.vscode then
				require("mini.move").setup()

				require("mini.bracketed").setup()

				require("mini.files").setup({
					options = {
						permanent_delete = true, -- mini doesn't support xdg trash
						use_as_default_explorer = false,
					},
					windows = {
						max_number = 3,
						preview = true,
						width_preview = 80,
					},
				})

				require("mini.cursorword").setup()

				-- TODO: consider replace with `textDocument/documentColor`
				require("mini.hipatterns").setup({
					highlighters = {
						hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
					},
				})

				require("mini.icons").setup()
				require("mini.icons").mock_nvim_web_devicons()

				-- Ensure this is lazily loaded to avoid conflict with Snacks.dashboard
				vim.api.nvim_create_autocmd("InsertEnter", {
					once = true,
					callback = function()
						require("mini.trailspace").setup({
							only_in_normal_buffers = true,
						})
					end,
				})
			end
		end,
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0))
				end,
				desc = "Open floating file explorer",
			},
		},
	},
}
