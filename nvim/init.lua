-- local start_treesitter = vim.treesitter.start
--
-- vim.treesitter.start = function(arg1, arg2)
-- 	print(string.format("Starting treesitter, arg1: %s, arg2: %s", tostring(arg1), tostring(arg2)))
-- 	print(debug.traceback("TRACE:"))
--
-- 	local result = start_treesitter(arg1, arg2)
-- 	print(string.format("RETURN: %s", tostring(result)))
-- 	return result
-- end

require("config").pre_lazy()
require("lazy-bootstrap")
require("config").post_lazy()
