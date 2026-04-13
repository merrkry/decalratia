vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<S-l>", "gt", { remap = true })
vim.keymap.set("n", "<S-h>", "gT", { remap = true })

if vim.g.vscode then
	return
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-s>", "<Cmd>silent! noautocmd update | redraw<CR>", { desc = "Save" })
vim.keymap.set("x", "<C-s>", "<Esc><Cmd>silent! noautocmd update | redraw<CR>", { desc = "Save and go to Normal mode" })

vim.keymap.set({ "n" }, "<leader>l", function()
	-- Save all buffers to work with linters that don't rely on stdin,
	-- also triggers format-on-save etc. before linting.
	vim.cmd.wall()

	if vim.bo.filetype == "rust" then
		vim.cmd.RustLsp({ "flyCheck", "run" })
	else
		require("lint").try_lint()
	end
end, { desc = "Flycheck" })
vim.keymap.set("x", "<leader>l", function()
	require("conform").format()
end, { desc = "Range format" })

vim.keymap.set("n", "<leader>ta", "<cmd>tabnew<CR>", { desc = "Create new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })

vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "q")
