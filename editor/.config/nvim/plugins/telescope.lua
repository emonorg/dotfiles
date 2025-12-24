-- Telescope fuzzy finder
return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				path_display = function(opts, path)
					local tail = require("telescope.utils").path_tail(path)
					local parent = vim.fn.fnamemodify(path, ":h:t")
					local grandparent = vim.fn.fnamemodify(path, ":h:h:t")
					local greatgrandparent = vim.fn.fnamemodify(path, ":h:h:h:t")
					return string.format("%s/%s/%s/%s", greatgrandparent, grandparent, parent, tail)
				end,
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
				-- Disable treesitter syntax highlighting in previews to avoid compatibility issues
				preview = {
					treesitter = false,
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		})

		-- Load fzf extension for better performance
		pcall(telescope.load_extension, "fzf")
	end,
}
