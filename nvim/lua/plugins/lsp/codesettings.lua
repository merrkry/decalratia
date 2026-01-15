---@type LazySpec
return {
	{
		"mrjones2014/codesettings.nvim",
		ft = { "json", "jsonc", "lua" },
		opts = {
			lua_ls_integration = function()
				return vim.uv.cwd() == ("%s/.config/nvim"):format(vim.env.HOME)
			end,
		},
	},
}
