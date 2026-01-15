local M = {}

local autocmd = require("utils.autocmd")

local LSP_READY_TIMEOUT = 1000

local EVENT_LSP_CLIENT_READY = "LspClientReady"
local EVENT_LSP_BUF_READY = "LspBufReady"

local AUGROUP_LSP_CLIENT_READY_CHECK = "LspClientReadyCheck"
local AUGROUP_LSP_BUF_READY_ON_ATTACH = "LspBufReadyOnAttach"
local AUGROUP_LSP_BUF_READY_DELAYED = "LspBufReadyDelayed"

---@type table<integer, uv.uv_timer_t | nil>
local client_progress_timer = {}

---@type table<integer, boolean | nil>
local client_ready_state = {}

---@param client_id integer
---@return nil
local function cancel_ready_timer(client_id)
	local timer = client_progress_timer[client_id]
	if timer then
		timer:close()
		client_progress_timer[client_id] = nil
	end
end

---@param client_id integer
---@return nil
local function mark_client_ready(client_id)
	client_ready_state[client_id] = true
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", {
			pattern = EVENT_LSP_CLIENT_READY,
			data = { client_id = client_id },
		})
	end)
end

---@param client_id integer
---@return nil
local function reset_ready_timer(client_id)
	cancel_ready_timer(client_id)
	local timer = vim.uv.new_timer() ---@as uv.uv_timer_t
	client_progress_timer[client_id] = timer
	timer:start(LSP_READY_TIMEOUT, 0, function()
		cancel_ready_timer(client_id)
		mark_client_ready(client_id)
	end)
end

--- Returns true if all LSP clients attached to the buffer are ready.
--- If no clients are attached, this also returns true.
---@param bufnr integer
---@return boolean
function M.all_clients_ready(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		if not client_ready_state[client.id] then
			return false
		end
	end
	return true
end

---@param bufnr integer
---@return nil
local function fire_lsp_buf_ready(bufnr)
	vim.api.nvim_exec_autocmds("User", {
		pattern = EVENT_LSP_BUF_READY,
		data = { bufnr = bufnr },
	})
end

function M.setup()
	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup(AUGROUP_LSP_CLIENT_READY_CHECK, {}),
		callback = function(event)
			local client_id = event.data.client_id
			reset_ready_timer(client_id)
		end,
	})

	autocmd.create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup(AUGROUP_LSP_BUF_READY_ON_ATTACH, {}),
		callback = function(args)
			local client_id = args.data.client_id
			local bufnr = args.buf

			if client_ready_state[client_id] == nil then
				client_ready_state[client_id] = false
				reset_ready_timer(client_id)
			end

			if M.all_clients_ready(bufnr) then
				fire_lsp_buf_ready(bufnr)
			else
				autocmd.create_user_autocmd("User " .. EVENT_LSP_CLIENT_READY, {
					buffer = bufnr,
					group = vim.api.nvim_create_augroup(AUGROUP_LSP_BUF_READY_DELAYED, {}),
					callback = function(event)
						if M.all_clients_ready(bufnr) then
							fire_lsp_buf_ready(bufnr)
							vim.api.nvim_del_autocmd(event.id)
						end
					end,
				})
			end
		end,
	})
end

return M
