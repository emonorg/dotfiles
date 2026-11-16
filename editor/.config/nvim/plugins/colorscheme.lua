-- Colorscheme configuration
return {
	"ellisonleao/gruvbox.nvim",
	lazy = false, -- load at start
	priority = 1000, -- load first
	config = function()
		require("gruvbox").setup({
			contrast = "", -- "hard", "soft" or ""
			palette_overrides = {
				bright_red = "#fc6c5c", -- default #fb4934, slightly lighter
			},
		})
		vim.o.background = "dark"
		vim.cmd([[colorscheme gruvbox]])

		-- Directory colors in neo-tree (blue instead of gruvbox yellow)
		vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#83a598" })
		vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#83a598" })

		-- Distinct color for methods (e.g. the `.get` in config_json.get())
		for _, group in ipairs({ "@function.method.call", "@function.method", "@lsp.type.method" }) do
			vim.api.nvim_set_hl(0, group, { fg = "#8ec07c" })
		end

		-- Make it clearly visible which argument we're at.
		local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
		vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })
	end
}
