---@type vim.lsp.Config
return {
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "-pv", "%f" },
				-- onSave = true, # TODO: command to toggle build on save, maybe also include `-pv` dynamically.
				forwardSearchAfter = false,
			},
			forwardSearch = {
				executable = "sioyek",
				args = {
					"--reuse-window",
					"--execute-command",
					"toggle_synctex",
					"--inverse-search",
					'texlab inverse-search -i "%%1" -l %%2',
					"--forward-search-file",
					"%f",
					"--forward-search-line",
					"%l",
					"%p",
				},
			},
		},
	},
}
