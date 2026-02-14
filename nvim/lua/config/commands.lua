vim.api.nvim_create_user_command("RestoreStyling", function()
	local extmarks = {
		"nvim.lsp.hover_range",
		"nvim.lsp.references_some",
	}
	for _, extmark in ipairs(extmarks) do
		local ns_id = vim.api.nvim_get_namespaces()[extmark] ---@as integer | nil
		if ns_id then
			vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
		end
	end

	if vim.snippet.active() then
		vim.snippet.stop()
	end

	vim.lsp.buf.clear_references()
end, {})
