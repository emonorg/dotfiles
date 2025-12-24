-- Autocompletion configuration
return {
	-- nvim-cmp: Completion engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",     -- LSP completion source
			"hrsh7th/cmp-buffer",        -- Buffer completion source
			"hrsh7th/cmp-path",          -- Path completion source
			"L3MON4D3/LuaSnip",          -- Snippet engine
			"saadparwaiz1/cmp_luasnip",  -- Snippet completion source
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				-- Disable completion in comments and prompts
				enabled = function()
					-- Disable in Telescope prompts and other prompt buffers
					local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
					if buftype == "prompt" then
						return false
					end
					
					local context = require("cmp.config.context")
					-- Keep completion enabled in command mode
					if vim.api.nvim_get_mode().mode == 'c' then
						return true
					else
						-- Disable in comments for better relevance
						return not context.in_treesitter_capture("comment")
							and not context.in_syntax_group("Comment")
					end
				end,
				-- VS Code-like completion behavior
				completion = {
					completeopt = "menu,menuone,noinsert",
					keyword_length = 1,
				},
				-- Better filtering and matching
				matching = {
					disallow_fuzzy_matching = false,
					disallow_fullfuzzy_matching = false,
					disallow_partial_fuzzy_matching = false,
					disallow_partial_matching = false,
					disallow_prefix_unmatching = true,
				},
				-- Performance settings
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 500,
					max_view_entries = 15, -- Limit suggestions like VS Code
				},
				-- Intelligent sorting and deduplication
				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						-- Prioritize by kind
						function(entry1, entry2)
							local kind1 = entry1:get_kind()
							local kind2 = entry2:get_kind()
							if kind1 ~= kind2 then
								return kind1 - kind2 < 0
							end
						end,
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				-- Source priority and limits
				sources = {
					{ 
						name = "nvim_lsp",
						max_item_count = 10,
						entry_filter = function(entry, ctx)
							local kind = entry:get_kind()
							local line = ctx.cursor_line
							local col = ctx.cursor.col
							local char_before = string.sub(line, col - 1, col - 1)
							
							-- Don't show snippets when accessing members
							if char_before == "." or char_before == ":" then
								return kind ~= 15 -- Snippet kind
							end
							
							return true
						end,
					},
					{ 
						name = "luasnip",
						max_item_count = 5,
					},
					{ 
						name = "buffer",
						max_item_count = 5,
						keyword_length = 3,
						option = {
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
					},
					{ 
						name = "path",
						max_item_count = 5,
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.dup = 0 -- No duplicates
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				-- Window styling
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = true,
				},
			})
		end,
	},
}
