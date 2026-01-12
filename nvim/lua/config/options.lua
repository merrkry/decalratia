vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.showmode = false

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.inccommand = "split"

if not vim.g.vscode then
	vim.o.number = true
	vim.o.relativenumber = true

	vim.o.mouse = "a"

	vim.o.breakindent = false

	vim.o.undofile = true

	-- vim.o.statuscolumn = "%s%l"
	-- vim.o.signcolumn = "yes:1"

	vim.o.updatetime = 250
	vim.o.timeoutlen = 300

	-- vim.o.list = true
	-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
	vim.o.shiftwidth = 4
	vim.o.tabstop = 4

	vim.o.cursorline = true

	vim.o.scrolloff = 8

	vim.o.laststatus = 3 -- always and ONLY the last window

	vim.o.swapfile = false
	vim.o.autoread = true

	vim.o.showtabline = 2 -- always

	vim.o.winborder = "rounded"

	vim.o.splitright = true
	vim.o.splitbelow = true

	-- https://xxiaoa.github.io/posts/4ac5e739/
	vim.api.nvim_create_autocmd("FileType", {
		callback = function()
			vim.opt.formatoptions:remove({ "o" })
		end,
	})

	vim.filetype.add({
		pattern = {
			[".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
			[".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
		},
	})
end
