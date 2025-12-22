---@module 'blink.cmp'
---@type blink.cmp.Config
local opts = {
	keymap = {
		preset = "none",

		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },

		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },

		["<C-k>"] = { "select_prev", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },

		["<CR>"] = { "accept", "fallback" },
		["<C-y>"] = { "accept", "fallback" },

		["<C-c>"] = { "hide", "fallback_to_mappings" },

		["<C-d>"] = { "show_documentation", "hide_documentation", "fallback" },

		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 1000,
			window = { border = vim.o.winborder },
		},
		menu = {
			border = vim.o.winborder,
			draw = {
				-- This might create lots of empty buffers, causing lag, espcially with rust-analyzer.
				treesitter = {},
			},
		},
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
		sorts = {
			"exact",
			"score",
			"sort_text",
		},
	},

	signature = {
		enabled = true,
		window = { border = vim.o.winborder },
	},

	cmdline = {
		keymap = {
			preset = "inherit",
			["<Tab>"] = { "show_and_insert_or_accept_single", "select_next" },
			["<S-Tab>"] = { "show_and_insert_or_accept_single", "select_prev" },
		},
	},
}

-- colorful-menu.nvim
opts = vim.tbl_deep_extend("error", opts, {
	completion = {
		menu = {
			draw = {
				columns = { { "kind_icon" }, { "label", gap = 1 } },
				components = {
					label = {
						text = function(ctx)
							return require("colorful-menu").blink_components_text(ctx)
						end,
						highlight = function(ctx)
							return require("colorful-menu").blink_components_highlight(ctx)
						end,
					},
				},
			},
		},
	},
})

---@type LazySpec
return {
	{
		"saghen/blink.cmp",

		-- version = "1.*",
		build = "cargo +nightly build --release",
		-- build = 'nix run .#build-plugin',

		event = { "LazyFile" },

		opts = opts,
		opts_extend = { "sources.default" },
	},
}
