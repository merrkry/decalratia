---@type LazySpec
return {
	{
		enabled = false,
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeSend",
			"ClaudeCodeAdd",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeTreeAdd",
			"ClaudeCodeStatus",
		},
		opts = {
			terminal = {
				provider = "none",
				-- provider = "snacks",
				-- split_side = "right",
				-- snacks_win_opts = {
				-- 	position = "right",
				-- 	width = 0.4,
				-- 	height = 1.0,
				-- },
			},
		},
	},
}
