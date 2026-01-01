--- Add support for the LazyFile event
--- https://github.com/LazyVim/LazyVim/discussions/1583
---@return nil
local function register_lazy_file_event()
	local Event = require("lazy.core.handler.event")

	local lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
	Event.mappings.LazyFile = { id = "LazyFile", event = lazy_file_events }
	Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

register_lazy_file_event()

---@diagnostic disable-next-line: undefined-field
require("lazy").setup({
	spec = require("plugins"),
	rocks = { enabled = false },
	install = { colorscheme = { "habamax" } },
	checker = { enabled = false },
	change_detection = { enabled = false },
})
