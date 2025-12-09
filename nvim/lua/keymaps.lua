if vim.g.vscode then
	local vscode = require("vscode")
	vim.keymap.set("n", "<S-h>", function()
		vscode.call("workbench.action.previousEditor")
	end)
	vim.keymap.set("n", "<S-l>", function()
		vscode.call("workbench.action.nextEditor")
	end)
end
