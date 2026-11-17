-- Colorscheme configuration
return {
	"tomasiser/vim-code-dark",
	lazy = false, -- load at start
	priority = 1000, -- load first
	config = function()
		vim.o.background = "dark"
		vim.cmd.colorscheme("codedark")

		-- codedark only styles legacy groups; map Treesitter control-flow keywords to its pink
		local pink = { fg = "#C586C0" }
		for _, group in ipairs({
			"@keyword.return", "@keyword.conditional", "@keyword.repeat",
			"@keyword.exception", "@keyword.import", "@keyword.conditional.ternary",
		}) do
			vim.api.nvim_set_hl(0, group, pink)
		end
	end,
}
