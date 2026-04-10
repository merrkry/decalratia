local allowed_filetypes = require("lang").edit_prediction_filetypes()

---@type LazySpec
return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		ft = allowed_filetypes, -- Avoid launch node when e.g. editing config.
		config = function()
			local filetypes = {
				["*"] = false,
			}
			for _, filetype in ipairs(allowed_filetypes) do
				filetypes[filetype] = true
			end

			require("copilot").setup({
				panel = {
					enabled = false,
				},
				suggestion = {
					enabled = true,
					auto_trigger = false,
					debounce = 100,
					trigger_on_accept = false, -- Next/prev can still trigger completion.
					keymap = {
						accept = "<Tab>",
						accept_word = "<C-l>",
						accept_line = "<C-j>",
						next = "<A-]>",
						prev = "<A-[>",
						dismiss = "<C-e>",
						-- toggle_auto_trigger = "\\I", -- seems broken
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
					require("copilot.suggestion").dismiss()
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
		keys = {
			{
				"\\I",
				function()
					require("copilot.suggestion").toggle_auto_trigger()
				end,
				desc = "Toggle automatic inline completion",
			},
		},
	},
}
