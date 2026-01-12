vim.api.nvim_create_user_command("RestoreStyling", function()
	local ns_id = vim.api.nvim_get_namespaces()["nvim.lsp.references_some"]
	if ns_id ~= nil then
		vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
	end

	if vim.snippet.active() then
		vim.snippet.stop()
	end
end, {})
