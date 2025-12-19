---@type LazySpec
return {
	{
		"drop-stones/im-switch.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {
			linux = {
				enabled = true,
				default_im = "keyboard-us",
				get_im_command = { "fcitx5-remote", "-n" },
				set_im_command = { "fcitx5-remote", "-s" },
			},
		},
	},
}
