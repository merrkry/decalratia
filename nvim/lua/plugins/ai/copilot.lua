---@type LazySpec
return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "VeryLazy",
		config = function()
			local filetypes = {
				["*"] = false,
			}
			for _, lang in ipairs(require("utils.lang").allow_copilot) do
				filetypes[lang] = true
			end

			require("copilot").setup({
				panel = {
					enabled = false,
				},
				suggestion = {
					enabled = true,
					auto_trigger = false,
					debounce = 100,
					keymap = {
						accept = "<C-y>",
						accept_word = "<C-l>",
						accept_line = "<C-j>",
						next = "<C-'>",
						prev = "<C-;>",
						dismiss = "<C-c>",
					},
				},
				filetypes = filetypes,
				server_opts_overrides = {
					settings = {
						telemetry = {
							telemetryLevel = "off",
						},
					},
				},
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuOpen",
				callback = function()
					vim.b.copilot_suggestion_hidden = true
				end,
			})
			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuClose",
				callback = function()
					vim.b.copilot_suggestion_hidden = false
				end,
			})
		end,
	},
}
