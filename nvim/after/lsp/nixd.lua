---@type vim.lsp.Config
return {
	settings = {
		nixpkgs = {
			expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
		},
	},
}
