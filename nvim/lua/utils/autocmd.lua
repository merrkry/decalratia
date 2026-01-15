local M = {}

---@alias UserEvent "User VeryLazy" | "User LazyFile" | "User LspClientReady" | "User LspBufReady"

---@alias AutocmdEvents vim.api.keyset.events | vim.api.keyset.events[] | UserEvent

--- Create an autocommand for User events.
--- If `buffer` is provided, the autocmd will only trigger for that buffer and
--- will be automatically cleaned up on `BufWipeout`.
---@param user_event UserEvent
---@param opts vim.api.keyset.create_autocmd
---@return integer
function M.create_user_autocmd(user_event, opts)
	local user_prefix = "User "
	if not vim.startswith(user_event, user_prefix) then
		error("Invalid UserEvent: " .. user_event)
	end

	local user_event_name = string.sub(user_event, #user_prefix + 1)
	local buffer = opts.buffer

	if buffer then
		local original_callback = opts.callback ---@as -nil
		opts.callback = function(event)
			if event.buf == buffer then
				original_callback(event)
			end
		end
		opts.buffer = nil
	end

	local autocmd_id = vim.api.nvim_create_autocmd(
		"User",
		vim.tbl_extend("error", opts, {
			pattern = user_event_name,
		})
	)

	if buffer then
		vim.api.nvim_create_autocmd("BufWipeout", {
			buffer = buffer,
			once = true,
			callback = function()
				pcall(vim.api.nvim_del_autocmd, autocmd_id)
			end,
		})
	end

	return autocmd_id
end

--- Create an autocommand with builtin events or User events.
---@param events AutocmdEvents
---@param opts vim.api.keyset.create_autocmd
---@return integer
function M.create_autocmd(events, opts)
	if type(events) == "string" and vim.startswith(events, "User ") then
		return M.create_user_autocmd(events --[[@as UserEvent]], opts)
	else
		return vim.api.nvim_create_autocmd(events --[[@as (vim.api.keyset.events | vim.api.keyset.events[])]], opts)
	end
end

return M
