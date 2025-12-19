---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		opts = {
			formatters_by_ft = {
				css = { "prettier" },
				kdl = { "kdlfmt" },
				lua = { "stylua" },
				markdown = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				["_"] = { "trim_whitespace" },
			},
			default_format_opts = {
				lsp_format = "first",
				async = true,
			},
			format_on_save = {},
		},
		keys = {
			{
				"<leader>l",
				function()
					require("conform").format()
				end,
				mode = { "n", "x" },
				desc = "Format buffer",
			},
			{
				-- Toggling format on save not planned
				-- https://github.com/stevearc/conform.nvim/issues/192#issuecomment-2817321950
				"<leader>W",
				"<cmd>noautocmd w<CR>",
				desc = "Format buffer without autocmd",
			},
		},
	},
}
