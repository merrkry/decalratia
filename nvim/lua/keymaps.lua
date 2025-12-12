vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("i", "<M-k>", "<up>")
vim.keymap.set("i", "<M-j>", "<down>")
vim.keymap.set("i", "<M-h>", "<left>")
vim.keymap.set("i", "<M-l>", "<right>")

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste after curcor, from system clipboard" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste before curcor, from system clipboard" })

if vim.g.vscode then
	local vscode = require("vscode")
	vim.keymap.set("n", "<S-h>", function()
		vscode.call("workbench.action.previousEditor")
	end)
	vim.keymap.set("n", "<S-l>", function()
		vscode.call("workbench.action.nextEditor")
	end)
else
end
