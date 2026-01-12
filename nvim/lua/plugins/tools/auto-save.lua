---@type LazySpec
return {
	{
		"okuuva/auto-save.nvim",
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
		config = function()
			---@param bufnr integer
			---@return boolean
			local function is_excluded_ft(bufnr)
				if
					vim.tbl_contains({
						"gitcommit",
						"harpoon",
						"oil",
					}, vim.fn.getbufvar(bufnr, "&filetype"))
				then
					return true
				end
				return false
			end

			--- https://github.com/coder/claudecode.nvim#auto-save-plugin-issues
			---@param bufnr integer
			---@return boolean
			local function is_claudecode_buf(bufnr)
				-- Exclude claudecode diff buffers by buffer name patterns
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if
					bufname:match("%(proposed%)")
					or bufname:match("%(NEW FILE %- proposed%)")
					or bufname:match("%(New%)")
				then
					return true
				end

				-- Exclude by buffer variables (claudecode sets these)
				if
					vim.b[bufnr].claudecode_diff_tab_name
					or vim.b[bufnr].claudecode_diff_new_win
					or vim.b[bufnr].claudecode_diff_target_win
				then
					return true
				end

				-- Exclude by buffer type (claudecode diff buffers use "acwrite")
				local buftype = vim.fn.getbufvar(bufnr, "&buftype")
				if buftype == "acwrite" then
					return true
				end

				return false
			end

			require("auto-save").setup({
				trigger_events = {
					defer_save = { "InsertLeave" },
					cancel_deferred_save = { "InsertEnter" },
				},
				condition = function(bufnr)
					if is_excluded_ft(bufnr) or is_claudecode_buf(bufnr) then
						return false
					end

					return true
				end,
				write_all_buffers = true,
				noautocmd = true, -- avoid conflict with format on save
				debounce_delay = 4000,
			})

			local group = vim.api.nvim_create_augroup("autosave", {})

			vim.api.nvim_create_autocmd("User", {
				pattern = "AutoSaveEnable",
				group = group,
				callback = function(_opts)
					vim.notify("Auto save enabled", vim.log.levels.INFO)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "AutoSaveDisable",
				group = group,
				callback = function(_opts)
					vim.notify("Auto save disabled", vim.log.levels.INFO)
				end,
			})
		end,
		keys = {
			{ "<leader>ts", "<cmd>ASToggle<CR>", desc = "Toggle auto save" },
		},
	},
}
