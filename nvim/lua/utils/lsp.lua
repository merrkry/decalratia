local M = {}

local autocmd = require("utils.autocmd")
local languages = require("utils.lang")
local lsp_progress = require("config.autocmd.lsp_progress")

local SHOW_DIAGNOSTICS = "<leader>k"

---@return nil
local function unregister_builtin_lsp_keymaps()
	-- :h lsp-defaults
	vim.keymap.del("n", "gra")
	vim.keymap.del("n", "gri")
	vim.keymap.del("n", "grn")
	vim.keymap.del("n", "grr")
	vim.keymap.del("n", "grt")
	vim.keymap.del("n", "gO")
	vim.keymap.del({ "i", "s" }, "<C-S>")
end

---@return nil
local function register_lsp_keymaps()
	---@param key string
	---@param func fun()
	---@param desc string
	local function register(key, func, desc)
		vim.keymap.set("n", key, func, { desc = desc })
	end

	---@param name string
	---@return fun(): nil
	local function snacks_picker(name)
		return function()
			Snacks.picker(name, {})
		end
	end

	-- Reference: https://docs.helix-editor.com/keymap.html

	register("gd", snacks_picker("lsp_definitions"), "Go to definitions")
	register("gD", snacks_picker("lsp_declarations"), "Go to declarations")
	register("gy", snacks_picker("lsp_type_definitions"), "Go to type definitions")
	register("gr", snacks_picker("lsp_references"), "Go to references")
	register("gi", snacks_picker("lsp_implementations"), "Go to implementations")
	register("gai", snacks_picker("lsp_incoming_calls"), "Open incoming calls picker")
	register("gao", snacks_picker("lsp_outgoing_calls"), "Open outgoing calls picker")

	register("<leader>r", vim.lsp.buf.rename, "Rename symbol")

	-- Handled by tiny-code-action.nvim.
	-- register("<leader>a", vim.lsp.buf.code_action, "Code actions")

	register(SHOW_DIAGNOSTICS, vim.diagnostic.open_float, "Show diagnostics")

	register("<leader>d", snacks_picker("diagnostics_buffer"), "Open diagnostics picker")
	register("<leader>D", snacks_picker("diagnostics"), "Open workspace diagnostics picker")

	register("<leader>s", snacks_picker("lsp_symbols"), "Open document symbol picker")
	register("<leader>S", snacks_picker("lsp_workspace_symbols"), "Open workspace symbol picker")
end

--- Reference: https://github.com/nvim-lua/kickstart.nvim/blob/3338d3920620861f8313a2745fd5d2be39f39534/init.lua#L588-L615
---@param bufnr integer
---@return nil
local function setup_cursor_highlight(bufnr)
	local group_name = "LspCursorHighlight"
	-- Set `clear = false` to avoid highlights not being cleared up,
	-- when jumping between buffers through go to definition etc.
	-- The autocmd will be cleared manually in LspDetach callback below.
	-- https://github.com/nvim-lua/kickstart.nvim/pull/874
	local group = vim.api.nvim_create_augroup(group_name, { clear = false })

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.clear_references,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("LspCursorHighlightDetach", {}),
		callback = function(args)
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = group_name, buffer = args.buf })
		end,
	})
end

---@return nil
local function setup_global_inlay_hints()
	-- require("lazy").load({ plugins = { "inlay-hint.nvim" } })
	require("lazy").load({ plugins = { "nvim-lsp-endhints" } })

	-- Configured globally. Execute this on `LspAttach` per buf might introduce race conditions,
	-- e.g. codediff.nvim tries to disable inlay hints on diff buffers.
	-- FIXME: still see inlay hints in codediff.nvim sessions.
	vim.lsp.inlay_hint.enable(true, { bufnr = nil })

	-- Disable inlay hints in insert mode.
	-- https://github.com/neovim/neovim/discussions/29078#discussioncomment-9865397
	-- vim.api.nvim_create_autocmd("InsertEnter", {
	-- 	desc = "Disable inlay hints when entering insert mode",
	-- 	callback = function(args)
	-- 		local filter = { bufnr = args.buf }
	-- 		local inlay_hint = vim.lsp.inlay_hint
	-- 		if inlay_hint.is_enabled(filter) then
	-- 			inlay_hint.enable(false, filter)
	-- 			vim.api.nvim_create_autocmd("InsertLeave", {
	-- 				once = true,
	-- 				desc = "Re-enable inlay hints when leaving insert mode",
	-- 				callback = function()
	-- 					inlay_hint.enable(true, filter)
	-- 				end,
	-- 			})
	-- 		end
	-- 	end,
	-- })
end

---@param bufnr integer
---@return nil
local function setup_buf_inlay_hints(bufnr)
	local filter = { bufnr = bufnr }

	vim.keymap.set("n", "\\H", function()
		local enabled = vim.lsp.inlay_hint.is_enabled(filter)
		vim.lsp.inlay_hint.enable(not enabled, filter)
	end, { desc = "Toggle inlay hints" })

	-- Some slow LSPs, like rust-analyzer, might not be able to display inlay hints right after launch.
	-- We call `inlay_hint.enable` to force re-trigger the rendering of inlay hints after all progress ending.
	if vim.lsp.inlay_hint.is_enabled(filter) then
		vim.lsp.inlay_hint.enable(true, filter)
	end
	-- Seems fixed as of 2026-01-16
end

---@return nil
local function setup_diagnostics()
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = vim.o.winborder, source = true },
		underline = { severity = { min = vim.diagnostic.severity.ERROR } },
		signs = {
			-- Read by tiny-inline-diagnostic.nvim and statuscolumn
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "󰀪",
				[vim.diagnostic.severity.INFO] = "󰋽",
				[vim.diagnostic.severity.HINT] = "󰌶",
			},
			-- severity = {}, -- don't display anything on statuscolumn
		},
		virtual_text = false,
		-- virtual_text = {
		-- 	current_line = nil, -- show both current and other lines
		-- 	spacing = 4,
		-- 	format = function(diagnostic)
		-- 		local diagnostic_message = {
		-- 			[vim.diagnostic.severity.ERROR] = diagnostic.message,
		-- 			[vim.diagnostic.severity.WARN] = diagnostic.message,
		-- 			[vim.diagnostic.severity.INFO] = diagnostic.message,
		-- 			[vim.diagnostic.severity.HINT] = diagnostic.message,
		-- 		}
		-- 		return diagnostic_message[diagnostic.severity]
		-- 	end,
		-- },
		update_in_insert = false,
	} --[[@as vim.diagnostic.Opts]])

	-- https://github.com/zed-industries/zed/blob/main/assets/themes/one/one.json
	vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#d07277" })
	vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#dec184" })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#74ade8" })
	vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#788ca6" })
end

---@param bufnr integer
---@return nil
local function setup_buf(bufnr)
	local supports_document_highlight = false
	local supports_inlay_hint = false

	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		if client:supports_method("textDocument/documentHighlight", bufnr) then
			supports_document_highlight = true
		end

		if client:supports_method("textDocument/inlayHint", bufnr) then
			supports_inlay_hint = true
		end

		if client.name == "rust-analyzer" then
			vim.keymap.set("n", SHOW_DIAGNOSTICS, function()
				vim.cmd.RustLsp({ "renderDiagnostic", "current" })
			end, { desc = "Show diagnostics", buffer = bufnr })
		end
	end

	if supports_document_highlight then
		setup_cursor_highlight(bufnr)
	end
	if supports_inlay_hint then
		setup_buf_inlay_hints(bufnr)
	end
end

---@return nil
local function setup_highlights()
	-- Highlight `{}` and `{var}` in format strings.
	-- FIXME: requires redraw to take effect
	vim.api.nvim_set_hl(0, "@lsp.type.formatSpecifier.rust", { link = "@punctuation.bracket" })
	vim.api.nvim_set_hl(0, "@lsp.type.variable.rust", { link = "@variable" })
end

---@return nil
local function setup_lsp_config()
	-- blink.cmp
	---@diagnostic disable-next-line: undefined-field
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	vim.lsp.config("*", { capabilities = capabilities })

	-- codesettings.nvim
	vim.lsp.config("*", {
		before_init = function(_, config)
			local codesettings = require("codesettings")
			codesettings.with_local_settings(config.name, config)
		end,
	})

	vim.lsp.log.set_level(vim.log.levels.OFF)

	local servers = languages.default_lsp
	vim.lsp.enable(servers, true)
end

---@return nil
function M.setup_lsp()
	lsp_progress.setup()

	unregister_builtin_lsp_keymaps()
	-- Some may prefer register them on a per buf basis, but in some cases,
	-- e.g. using nvim-lint with no LSP attached, we still want these keymaps to be available.
	register_lsp_keymaps()

	setup_global_inlay_hints()

	setup_diagnostics()

	setup_highlights()

	autocmd.create_user_autocmd("User LspBufReady", {
		group = vim.api.nvim_create_augroup("OnLspBufReady", {}),
		callback = function(event)
			setup_buf(event.buf)
		end,
	})

	setup_lsp_config()
end

return M
