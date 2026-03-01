---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		config = function()
			local conform = require("conform")

			conform.setup({
				-- Although some of these formatters are also provided via LSP,
				-- it is useful to format through conform in scenarios where project root
				-- markers doesn't exist, e.g. when editing config files.
				formatters_by_ft = {
					bib = { "tex-fmt" },
					cls = { "tex-fmt" },
					css = { "prettier" },
					go = { "goimports", "gofumpt" },
					json = { "prettier" },
					jsonc = { "prettier" },
					kdl = { "kdlfmt" },
					lua = { "stylua" },
					markdown = { "prettier" },
					nix = { "nixfmt" },
					python = {
						"ruff_format",
						"ruff_organize_imports",
						-- "ruff_fix"
					},
					rust = { "rustfmt" },
					sty = { "tex-fmt" },
					tex = { "tex-fmt" },
					toml = { "taplo" },
					yaml = { "prettier" },
					["_"] = { "trim_whitespace" },
				},
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
