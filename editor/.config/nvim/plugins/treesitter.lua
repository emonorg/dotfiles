-- Treesitter configuration
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter.config").setup({
			ensure_installed = {
				"c",
				"cpp",
				"go",
				"gomod",
				"lua",
				"javascript",
				"typescript",
				"json",
				"yaml",
				"bash",
				"html",
				"css",
				"markdown",
				"markdown_inline",
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
		})
	end,
}


