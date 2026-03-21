---@type LazySpec
return {
	"nanozuki/tabby.nvim",
	version = "2.*",
	event = "User LazyFile",
	config = function()
		local theme = {
			fill = "TabLineFill",
			head = "TabLine",
			tab = { bg = "#333333" },
			current_tab = "TabLineSel",
			win = "TabLine",
			tail = "TabLineSel",
		}

		local opts = {
			preset = "tab_only",
			option = {
				nerdfont = true,
				lualine_theme = true,
			},
			line = function(line)
				return {
					-- {
					-- 	{ "  ", hl = theme.head },
					-- 	line.sep("", theme.head, theme.fill),
					-- },
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl, theme.fill),
							-- tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							-- tab.close_btn(""),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					-- line.spacer(),
					-- line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
					-- 	return {
					-- 		line.sep("", theme.win, theme.fill),
					-- 		win.is_current() and "" or "",
					-- 		win.buf_name(),
					-- 		line.sep("", theme.win, theme.fill),
					-- 		hl = theme.win,
					-- 		margin = " ",
					-- 	}
					-- end),
					{
						-- line.sep("", theme.tail, theme.fill),
						{ " ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end,
		}

		require("tabby").setup(opts)
	end,
}
