---@type LazySpec
return {
	{
		"dtormoen/neural-open.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		lazy = false, -- builtin
		opts = {
			file_sources = {
				"buffers",
				-- "neural_recent",
				"files",
				"git_files",
			},
		},
		keys = {
			{
				"<leader>f",
				function()
					local workspace = vim.lsp.buf.list_workspace_folders()
					local target
					if workspace and #workspace > 0 then
						target = workspace[1]
					else
						target = vim.uv.cwd()
					end
					require("neural-open").open({ cwd = target })
				end,
				desc = "Open file picker at LSP workspace root",
			},
			{
				"<leader>F",
				function()
					require("neural-open").open({ cwd = vim.uv.cwd() })
				end,
				desc = "Open file picker at current working directory",
			},
		},
	},
}
