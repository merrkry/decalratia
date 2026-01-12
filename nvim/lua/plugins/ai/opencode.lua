---@type LazySpec
return {
	{
		enabled = true,
		"NickvanDyke/opencode.nvim",
		dependencies = {
			{ "folke/snacks.nvim" },
		},
		config = function()
			vim.o.autoread = true

			---@type opencode.Opts
			vim.g.opencode_opts = {
				port = nil, -- uses `lsof` to search for opencode process in cwd
				provider = {
					enabled = false,
				},
				events = {
					enabled = true,
					reload = true,
					permissions = {
						enabled = false,
					},
				},
			}
		end,
		keys = {
			{
				"go",
				function()
					return require("opencode").operator("@this ")
				end,
				mode = { "n", "x" },
				expr = true,
				desc = "Add range to opencode",
			},
			{
				"goo",
				function()
					return require("opencode").operator("@this ") .. "_"
				end,
				mode = "n",
				expr = true,
				desc = "Add line to opencode",
			},
		},
	},
}
