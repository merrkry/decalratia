local pluginSpecs = {
	{ import = "plugins.mini" },
	{ import = "plugins.snacks" },

	{ import = "plugins.edit" },
}

if not vim.g.vscode then
	vim.list_extend(pluginSpecs, {
		{ import = "plugins.ai" },
		{ import = "plugins.lang" },
		{ import = "plugins.lsp" },
		{ import = "plugins.tools" },
		{ import = "plugins.ui" },
	})
end

return pluginSpecs
