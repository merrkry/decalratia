local M = {}

---@return nil
function M.pre_lazy()
	require("config.options")
end

---@return nil
function M.post_lazy()
	require("config.autocmd")
	require("config.clipboard")
	require("config.commands")
	require("config.keymaps")
end

return M
