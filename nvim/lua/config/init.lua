local M = {}

---@return nil
M.pre_lazy = function()
	require("config.helpers")
	require("config.options")
end

---@return nil
M.post_lazy = function()
	require("config.clipboard")
	require("config.commands")
	require("config.keymaps")
end

return M
