---@type LazySpec
return {
	{
		"s1n7ax/nvim-window-picker",
		event = "VeryLazy",
		version = "2.*",
		opts = {
			hint = "floating-big-letter",
			picker_config = {
				handle_mouse_click = true,
			},
			show_prompt = false,
			filter_rules = {
				include_current_win = true,
				bo = {
					filetype = { "notify", "snacks_notif" },
					buftype = {},
				},
			},
		},
		keys = {
			{
				"<leader>w",
				function()
					local win_id = require("window-picker").pick_window({})
					if win_id then
						vim.api.nvim_set_current_win(win_id)
					end
				end,
				desc = "Show window picker",
			},
		},
	},
}
