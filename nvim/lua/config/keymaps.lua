vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- https://github.com/saghen/blink.cmp/discussions/2218
vim.keymap.set({ "i", "s" }, "<Esc>", function()
	if vim.snippet.active() then
		vim.snippet.stop()
	end
	return "<ESC>"
end, { expr = true })

vim.keymap.set("i", "<M-k>", "<up>")
vim.keymap.set("i", "<M-j>", "<down>")
vim.keymap.set("i", "<M-h>", "<left>")
vim.keymap.set("i", "<M-l>", "<right>")

vim.keymap.set("n", "<S-l>", "gt", { remap = true })
vim.keymap.set("n", "<S-h>", "gT", { remap = true })

vim.keymap.set("n", "<leader>W", "<cmd>noautocmd w<CR>", { desc = "Write buffer without autocmd" })

if not vim.g.vscode then
	vim.keymap.set("n", "<leader>l", function()
		-- Save all buffers to work with linters that don't rely on stdin,
		-- also triggers format-on-save etc. before linting.
		vim.cmd.wall()

		if vim.bo.filetype == "rust" then
			vim.cmd.RustLsp({ "flyCheck", "run" })
		else
			require("lint").try_lint()
		end
	end, { desc = "Flycheck" })
end
