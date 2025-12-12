vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.inccommand = "split"

if vim.g.vscode then
else
	vim.o.mouse = "a"
	vim.o.relativenumber = true
	vim.o.scrolloff = 8
end
