local M = {}

---@param language string
---@return boolean
local function is_enabled(language)
	local available_parsers = require("nvim-treesitter").get_available()
	if not vim.tbl_contains(available_parsers, language) then
		return false
	end

	local excluded_parsers = require("utils.lang").disable_treesitter
	if vim.tbl_contains(excluded_parsers, language) then
		return false
	end

	return true
end

---@param bufnr integer
---@param language string
---@return nil
local function attach_treesitter(bufnr, language)
	vim.wo.foldmethod = "expr"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

	vim.treesitter.start(bufnr, language)

	vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

---@param parsers string[]
---@return nil
function M.install_parsers(parsers)
	require("nvim-treesitter").install(parsers)
end

---@return nil
function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("TreesitterSetup", {}),
		callback = function(args)
			local bufnr = args.buf
			local filetype = args.match
			local language = vim.treesitter.language.get_lang(filetype) or filetype

			if not is_enabled(language) then
				return
			end

			require("nvim-treesitter").install(language):await(function()
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				if not vim.treesitter.language.add(language) then
					return
				end

				attach_treesitter(bufnr, language)
			end)
		end,
	})
end

return M
