---@type LazySpec
return {
	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 30,
			minimumBufferNum = 4,
			deleteBufferWhenFileDeleted = true,
		},
	},
}
