local M = {}

---@class LangEntry
---@field ft string[]
---@field lsp? string[]
---@field formatters? string[]
---@field linters? string[]
---@field editPrediction? boolean

---@class LangResolvedConfig
---@field formatters? string[]
---@field linters? string[]
---@field editPrediction? boolean

---@type table<string, LangResolvedConfig>?
local configs_by_ft

---@type string[]?
local default_lsps

---@param target table<string, any>
---@param entry LangEntry
---@return nil
local function merge_entry(target, entry)
	for key, value in pairs(entry) do
		if key ~= "ft" and key ~= "lsp" then
			target[key] = value
		end
	end
end

---@return string[]
local function module_paths()
	local paths = vim.api.nvim_get_runtime_file("lua/lang/*.lua", true)
	local modules = {}

	for _, path in ipairs(paths) do
		if vim.fn.fnamemodify(path, ":t") ~= "init.lua" then
			table.insert(modules, path)
		end
	end

	table.sort(modules)
	return modules
end

---@return table<string, LangResolvedConfig>
local function init()
	if configs_by_ft then
		return configs_by_ft
	end

	configs_by_ft = {}
	default_lsps = {}
	local seen_lsps = {}

	for _, path in ipairs(module_paths()) do
		local name = vim.fn.fnamemodify(path, ":t:r")
		local ok, lang_entries = pcall(require, "lang." .. name)
		if not ok then
			error(lang_entries)
		end

		for _, entry in ipairs(lang_entries) do
			if entry.lsp then
				for _, lsp in ipairs(entry.lsp) do
					if not seen_lsps[lsp] then
						seen_lsps[lsp] = true
						table.insert(default_lsps, lsp)
					end
				end
			end

			for _, ft in ipairs(entry.ft) do
				configs_by_ft[ft] = configs_by_ft[ft] or {}
				merge_entry(configs_by_ft[ft], entry)
			end
		end
	end

	return configs_by_ft
end

---@return table<string, LangResolvedConfig>
function M.by_ft()
	return init()
end

---@return table<string, string[]>
function M.formatters_by_ft()
	local formatters_by_ft = {}

	for ft, config in pairs(init()) do
		if config.formatters then
			formatters_by_ft[ft] = config.formatters
		end
	end

	return formatters_by_ft
end

---@return table<string, string[]>
function M.linters_by_ft()
	local linters_by_ft = {}

	for ft, config in pairs(init()) do
		if config.linters then
			linters_by_ft[ft] = config.linters
		end
	end

	return linters_by_ft
end

---@return string[]
function M.edit_prediction_filetypes()
	local filetypes = {}

	for ft, config in pairs(init()) do
		if config.editPrediction then
			table.insert(filetypes, ft)
		end
	end

	table.sort(filetypes)
	return filetypes
end

---@return string[]
function M.default_lsps()
	init()
	return default_lsps
end

---@return string[]
function M.treesitter_excludes()
	return { "csv" }
end

-- TODO: add treesitter-related settings after deciding whether they should be
-- modeled by filetype, parser language, or kept as a small hardcoded list.

return M
