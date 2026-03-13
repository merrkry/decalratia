---@type LazySpec
return {
	{
		"rmagatti/auto-session",
		lazy = false, -- builtin
		config = function()
			vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

			---@return nil
			local function clean_buffers()
				local wins = vim.api.nvim_list_wins()
				local active_bufs = {}
				for _, win in ipairs(wins) do
					local buf = vim.api.nvim_win_get_buf(win)
					local type = vim.api.nvim_get_option_value("buftype", { buf = buf })
					if type == "" then -- normal buffer
						active_bufs[buf] = true
					end
				end
				local bufs = vim.api.nvim_list_bufs()
				for _, buf in ipairs(bufs) do
					if not active_bufs[buf] then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end

			---@return boolean
			local function launch_without_command()
				for _, arg in ipairs(vim.v.argv) do
					-- Nix wrapper etc. adds `--cmd` to set variables, we should only detect `-c <cmd>` and `+<cmd>`.
					if arg == "-c" or arg:match("^%+") then
						return false
					end
				end
				return true
			end

			local opts = {
				-- Avoid conflict with plugins that relies on startup commands like hunk.nvim
				-- Although can also be done in `pre_restore_cmds` hooks, an annoying notification
				-- will be shown if rejecting through hooks.
				auto_restore = launch_without_command(),
				-- Only execute inside git directories
				auto_create = function()
					local cmd = "git rev-parse --is-inside-work-tree"
					return vim.fn.system(cmd) == "true\n"
				end,
				purge_after_minutes = 20160, -- two weeks
				continue_restore_on_error = false,
				lazy_support = true,
				legacy_cmds = false,
				pre_save_cmds = { clean_buffers },
			}

			require("auto-session").setup(opts)
		end,
	},
}
