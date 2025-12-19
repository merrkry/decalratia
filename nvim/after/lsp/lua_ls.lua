---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			hint = { enable = true },
			runtime = { version = "LuaJIT" },
			telemetry = { enable = false },
		},
	},
}
