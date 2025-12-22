---@class MiniPluginCfg
---@field cond boolean | nil
---@field event vim.api.keyset.events | vim.api.keyset.events[] | helpers.UserEvent | nil
---@field opts table | nil
---@field setup (fun(plugin: any, opt: table): nil) | nil

---@param configs table<string, MiniPluginCfg>
---@return nil
local function lazy_setup(configs)
	local group = vim.api.nvim_create_augroup("MiniLazySetup", {})

	for plugin_name, plugin_cfg in pairs(configs) do
		local cond = plugin_cfg.cond ~= false
		if cond then
			---@return nil
			local function setup_func()
				local plugin = require("mini." .. plugin_name)
				local opts = plugin_cfg.opts or {}
				if plugin_cfg.setup ~= nil then
					plugin_cfg.setup(plugin, opts)
				else
					plugin.setup(opts)
				end
			end

			if plugin_cfg.event then
				helpers.create_autocmd(plugin_cfg.event, {
					group = group,
					once = true,
					callback = setup_func,
				})
			else
				setup_func()
			end
		end
	end
end

---@type table<string, MiniPluginCfg>
local mini_opts = {
	ai = {
		event = "User VeryLazy",
		setup = function(plugin, _)
			local gen_spec = plugin.gen_spec

			---@param name string
			---@return table
			local function gen_ts_ai_pair(name)
				return gen_spec.treesitter({
					a = "@" .. name .. ".outer",
					i = "@" .. name .. ".inner",
				})
			end

			plugin.setup({
				custom_textobjects = {
					a = gen_ts_ai_pair("parameter"),
					-- b: builtin ( [ {
					B = gen_ts_ai_pair("block"),
					c = gen_ts_ai_pair("class"),
					C = gen_ts_ai_pair("comment"),
					f = gen_ts_ai_pair("function"),
					F = gen_ts_ai_pair("call"),
					i = gen_ts_ai_pair("conditional"),
					I = gen_ts_ai_pair("loop"),
					-- p: builtin paragraph
					-- q: builtin " ' `
					r = gen_ts_ai_pair("return"),
					s = gen_ts_ai_pair("statement"),
					-- t: builtin tag
				},
				search_method = "cover_or_nearest",
			})
		end,
	},
	bracketed = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
	},
	comment = {
		event = "User VeryLazy",
	},
	cursorword = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
	},
	files = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
		opts = {
			options = {
				permanent_delete = true, -- mini doesn't support xdg trash
				use_as_default_explorer = false,
			},
			windows = {
				max_number = 3,
				preview = true,
				width_preview = 80,
			},
		},
	},
	-- TODO: consider replace with `textDocument/documentColor`
	hipatterns = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
		setup = function(plugin, _)
			plugin.setup({
				highlighters = {
					hex_color = plugin.gen_highlighter.hex_color(),
				},
			})
		end,
	},
	icons = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
		setup = function(plugin, opts)
			plugin.setup(opts)
			plugin.mock_nvim_web_devicons()
		end,
	},
	move = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
	},
	splitjoin = {
		event = "User VeryLazy",
	},
	surround = {
		event = "User VeryLazy",
	},
	trailspace = {
		cond = not vim.g.vscode,
		event = "User VeryLazy",
		opts = {
			only_in_normal_buffers = true,
		},
	},
}

---@type LazySpec
return {
	{
		"nvim-mini/mini.nvim",
		lazy = false,
		priority = 900,
		config = function()
			lazy_setup(mini_opts)
		end,
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0))
				end,
				desc = "Open floating file explorer",
			},
		},
	},
}
