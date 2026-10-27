-- Colorscheme configuration
return {
	"jaljoue/dracula-alucard.nvim",
	lazy = false, -- load at start
	priority = 1000, -- load first
	config = function()
		require("dracula-alucard").setup({
			italic_comment = true,
		})
		-- Use "dracula-alucard-soft" for the softer variant
		vim.cmd([[colorscheme dracula-alucard]])

		-- Make it clearly visible which argument we're at.
		local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
		vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })
	end
}
