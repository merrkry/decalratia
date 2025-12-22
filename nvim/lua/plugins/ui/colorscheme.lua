---@type LazySpec
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
				transparent_background = true,
				float = {
					transparent = true,
					solid = true,
				},
				show_end_of_buffer = true,
				-- no_italic = true,
				styles = {
					comments = {},
				},
				auto_integrations = true,
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
