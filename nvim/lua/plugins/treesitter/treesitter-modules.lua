---@type LazySpec
return {
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "LazyFile",
		config = function()
			---@module 'treesitter-modules'
			---@type ts.mod.UserConfig
			opts = {
				ensure_installed = {
					"bash",
					"comment",
					"diff",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"query",
					"regex",
					"vim",
					"vimdoc",
				},
				auto_install = true,
				fold = { enable = false },
				highlight = { enable = false },
				indent = { enable = true },
				incremental_selection = { enable = false },
			}
			require("treesitter-modules").setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("OnFileType", {}),
				callback = function(event)
					local bufnr = event.buf
					local filetype = vim.bo[bufnr].filetype
					local language = vim.treesitter.language.get_lang(filetype)

					local available_parsers = require("nvim-treesitter").get_available()
					if not vim.tbl_contains(available_parsers, language) then
						return
					end

					local excluded_parsers = require("utils.lang").disable_treesitter
					if vim.tbl_contains(excluded_parsers, language) then
						return
					end

					vim.treesitter.start(bufnr)
				end,
			})
		end,
	},
}
