---@type vim.lsp.Config
return {
	settings = {
		-- NOTE: rust-analyzer does expect settings to be under the "rust-analyzer" key.
		["rust-analyzer"] = {
			check = {
				command = "clippy",
				extraArgs = {
					"--",
					"-W",
					"clippy::pedantic",
					-- "-W",
					-- "clippy::restriction",
					"-W",
					"clippy::nursery",
					"-W",
					"clippy::cargo",
				},
			},
			diagnostics = { experimental = { enable = true } },
			inlayHints = {
				bindingModeHints = { enable = false },
				closingBraceHints = { minLines = 8 },
				closureReturnTypeHints = { enable = "with_block" },
				discriminantHints = { enable = "fieldless" },
				lifetimeElisionHints = { enable = "skip_trivial" },
				typeHints = { hideClosureInitialization = false },
			},
			rustfmt = {
				extraArgs = { "--unstable-features" },
				rangeFormatting = { enable = true },
			},
		},
	},
}
