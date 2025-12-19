if not vim.g.vscode then
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})
end

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste after curcor, from system clipboard" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste before curcor, from system clipboard" })
