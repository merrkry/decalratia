local M = {}

---@alias helpers.UserEvent "User VeryLazy" | "User LazyFile"

--- Create an autocommand for User events.
---@param user_event helpers.UserEvent
---@param opts vim.api.keyset.create_autocmd
---@return integer
M.create_user_autocmd = function(user_event, opts)
	local user_prefix = "User "
	if vim.startswith(user_event, user_prefix) then
		local user_event_name = string.sub(user_event, #user_prefix + 1)
		return vim.api.nvim_create_autocmd(
			"User",
			vim.tbl_extend("error", opts, {
				pattern = user_event_name,
			})
		)
	else
		error("Invalid UserEvent: " .. user_event)
	end
end

--- Create an autocommand with builtin events or User events.
---@param events vim.api.keyset.events | vim.api.keyset.events[] | helpers.UserEvent
---@param opts vim.api.keyset.create_autocmd
---@return integer
M.create_autocmd = function(events, opts)
	if type(events) == "string" and vim.startswith(events, "User ") then
		return M.create_user_autocmd(events --[[@as helpers.UserEvent]], opts)
	else
		return vim.api.nvim_create_autocmd(events --[[@as (vim.api.keyset.events | vim.api.keyset.events[])]], opts)
	end
end

helpers = M
