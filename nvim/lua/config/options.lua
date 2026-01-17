vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.showmode = false

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.infercase = true

vim.o.inccommand = "split"

-- mini.basics used as baseline
if vim.g.vscode then
	return
end

vim.o.relativenumber = true

vim.o.updatetime = 1000
vim.o.timeoutlen = 250

vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.scrolloff = 8

vim.o.laststatus = 3 -- always and ONLY the last window

vim.o.swapfile = false
vim.o.autoread = true

vim.o.showtabline = 2 -- always

vim.o.winborder = "rounded"

-- Ref: https://xxiaoa.github.io/posts/4ac5e739/
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- Hitting <CR> inherits comment environment.
		vim.opt.formatoptions:append("r")
		-- Hitting o/O gives blank new line.
		vim.opt.formatoptions:remove({ "o" })
	end,
})

vim.filetype.add({
	pattern = {
		[".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
		[".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
	},
})
