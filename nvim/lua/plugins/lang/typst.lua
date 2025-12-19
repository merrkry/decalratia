---@type LazySpec
return {
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		opts = {
			open_cmd = "chromium --incognito --new-window %s",
			dependencies_bin = {
				["tinymist"] = "tinymist",
			},
		},
	},
}
