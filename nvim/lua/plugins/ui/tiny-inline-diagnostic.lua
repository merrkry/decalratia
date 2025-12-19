---@type LazySpec
return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		opts = {
			preset = "simple",
			-- transparent_bg = true,
			hi = {
				-- All above hg will still be blended in some mysterious way.
				-- mixing_color = "#3b414d",
				mixing_color = "#282C33", -- zed's One Dark background
				-- background = "#FFFFFF",
			},
			blend = {
				factor = 26 / 255, -- zed uses alpha 1A for background
			},
			options = {
				use_icons_from_diagnostic = true,
				throttle = 250,
				multilines = {
					enabled = true,
					always_show = true, -- otherwise only show when current line has no diagnostics
					trim_whitespaces = true,
					severity = {
						vim.diagnostic.severity.ERROR,
					},
				},
				show_all_diags_on_cursorline = false,
				enable_on_insert = false,
				enable_on_select = false,
				overflow = {
					mode = "oneline",
					-- padding = 4,
				},
				format = function(diagnostic)
					local msg = diagnostic.message
					local function apply_patterns(patterns)
						for _, pattern in ipairs(patterns) do
							msg = string.gsub(msg, pattern, "")
						end
					end

					if diagnostic.source == "clippy" then
						apply_patterns({
							"%s*for further information visit https://[^%s]+",
							"%s*`[^`]*` implied by `[^`]*`%s*to override `[^`]*`%s*add `[^`]*`",
							"%s*`[^`]*` implied by `[^`]*`",
							"`#%[warn%b()%]`%s*%b()%s*on by default",
							"`#%[warn%b()%]`%s*on by default",
						})
					elseif diagnostic.source == "rustc" then
						apply_patterns({
							"`#%[warn%b()%]`%s*%b()%s*on by default",
							"`#%[warn%b()%]`%s*on by default",
						})
					end

					return msg -- .. " [" .. diagnostic.source .. "]"
				end,

			},
		},
		keys = {
			{
				"<leader>td",
				function()
					local diag = require("tiny-inline-diagnostic.diagnostic")
					diag.toggle()
					local state = require("tiny-inline-diagnostic.state")
					if state.user_toggle_state then
						vim.notify("diagnostics enabled")
					else
						vim.notify("diagnostics disabled")
					end
				end,
				desc = "Toggle diagnostics",
			},
		},
	},
}
