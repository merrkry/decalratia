local M = {}

---@alias UserEvent "User VeryLazy" | "User LazyFile" | "User LspClientReady" | "User LspBufReady"

---@alias AutocmdEvents vim.api.keyset.events | vim.api.keyset.events[] | UserEvent

--- Strip `User ` prefix
---@param full_event_name UserEvent
---@return string
local function get_user_event_name(full_event_name)
	local user_prefix = "User "
	if not vim.startswith(full_event_name, user_prefix) then
		error("Invalid UserEvent: " .. full_event_name)
	end

	return string.sub(full_event_name, #user_prefix + 1)
end

--- Create an autocommand for User events.
--- If `buffer` is provided, the autocmd will only trigger for that buffer and
--- will be automatically cleaned up on `BufWipeout`.
---@param user_event UserEvent
---@param opts vim.api.keyset.create_autocmd
---@return integer
function M.create_user_autocmd(user_event, opts)
	local buffer = opts.buffer

	local original_callback = opts.callback ---@as -nil
	opts.callback = function(event)
		if event.data and event.data._bufnr then
			if buffer and event.data._bufnr ~= buffer then
				return
			end
			event.buf = event.data._bufnr
		end
		original_callback(event)
	end
	opts.buffer = nil

	local autocmd_id = vim.api.nvim_create_autocmd(
		"User",
		vim.tbl_extend("error", opts, {
			pattern = get_user_event_name(user_event),
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

--- Execute an autocommand for User events.
--- If `buffer` is provided, the autocmd will only be executed for that buffer.
---@param user_event UserEvent
---@param opts vim.api.keyset.create_autocmd
---@return nil
function M.exec_user_autocmd(user_event, opts)
	local buffer = opts.buffer

	if buffer then
		opts.data = vim.tbl_extend("error", opts.data or {}, { _bufnr = buffer })
		opts.buffer = nil
	end

	vim.api.nvim_exec_autocmds(
		"User",
		vim.tbl_extend("error", opts, {
			pattern = get_user_event_name(user_event),
		})
	)
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
