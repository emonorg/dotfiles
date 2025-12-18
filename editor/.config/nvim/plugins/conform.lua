-- Conform.nvim: Formatting with conditional Prettier support
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		-- Set a longer default timeout for all formatters
		format_on_save = false, -- We handle this manually
		default_format_opts = {
			timeout_ms = 3000,
			lsp_fallback = true,
		},
		-- Define formatters by filetype (use prettierd for speed, fallback to prettier)
		formatters_by_ft = {
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
		},
		-- Customize formatters to only run when config exists
		formatters = {
			prettierd = {
				-- Only use prettier if a config file exists
				condition = function(self, ctx)
					local configs = {
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						".prettierrc.json5",
						".prettierrc.js",
						".prettierrc.cjs",
						".prettierrc.mjs",
						".prettierrc.toml",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
					}
					return vim.fs.root(ctx.buf, configs) ~= nil
				end,
			},
			prettier = {
				-- Only use prettier if a config file exists
				condition = function(self, ctx)
					local configs = {
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						".prettierrc.json5",
						".prettierrc.js",
						".prettierrc.cjs",
						".prettierrc.mjs",
						".prettierrc.toml",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
					}
					return vim.fs.root(ctx.buf, configs) ~= nil
				end,
			},
		},
	},
}
