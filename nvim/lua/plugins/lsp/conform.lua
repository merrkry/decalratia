---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		config = function()
			local conform = require("conform")
			local formatters_by_ft = require("lang").formatters_by_ft()
			formatters_by_ft["_"] = { "trim_whitespace" }

			conform.setup({
				-- Although some of these formatters are also provided via LSP,
				-- it is useful to format through conform in scenarios where project root
				-- markers doesn't exist, e.g. when editing config files.
				formatters_by_ft = formatters_by_ft,
				default_format_opts = {
					lsp_format = "fallback",
				},
				format_on_save = {},
			})

			conform.formatters.rustfmt = {
				options = {
					default_edition = "2024",
					nightly = true,
				},
			}

			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
