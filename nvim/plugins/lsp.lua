-- LSP Configuration
return {
	-- Mason: LSP server installer
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-LSPConfig: Bridge between mason and lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls",           -- TypeScript/JavaScript
					"rust_analyzer",   -- Rust
					"lua_ls",          -- Lua
					"clangd",          -- C/C++
					"html",            -- HTML
					"cssls",           -- CSS
					"jsonls",          -- JSON
					"yamlls",          -- YAML
				},
				automatic_installation = true,
			})
		end,
	},

	-- LSP Config: Configure LSP servers
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Setup LSP capabilities for nvim-cmp
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Auto-close location/quickfix list after selection
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "qf",
				callback = function()
					vim.keymap.set("n", "<CR>", function()
						-- Get the entry info before jumping
						local qf_idx = vim.fn.line(".")
						local is_loclist = vim.fn.getloclist(0, {filewinid = 0}).filewinid ~= 0
						
						-- Execute the default action (jump to location)
						vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<CR>", true, false, true))
						
						-- Close the list after jumping
						vim.schedule(function()
							if is_loclist then
								vim.cmd("lclose")
							else
								vim.cmd("cclose")
							end
						end)
					end, { buffer = true })
				end,
			})

			-- Setup keybindings when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local opts = { buffer = bufnr, silent = true }
					
					-- Key mappings
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
					
					-- Signature help
					vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)
				end,
			})

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
				capabilities = capabilities,
			})

			-- Rust
			vim.lsp.config("rust_analyzer", {
				cmd = { "rust-analyzer" },
				filetypes = { "rust" },
				root_markers = { "Cargo.toml" },
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
					},
				},
			})

			-- Lua
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc" },
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- C/C++
			vim.lsp.config("clangd", {
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
				capabilities = capabilities,
			})

			-- HTML
			vim.lsp.config("html", {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				root_markers = { "package.json" },
				capabilities = capabilities,
			})

			-- CSS
			vim.lsp.config("cssls", {
				cmd = { "vscode-css-language-server", "--stdio" },
				filetypes = { "css", "scss", "less" },
				root_markers = { "package.json" },
				capabilities = capabilities,
			})

			-- JSON
			vim.lsp.config("jsonls", {
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				root_markers = { "package.json" },
				capabilities = capabilities,
			})

			-- YAML
			vim.lsp.config("yamlls", {
				cmd = { "yaml-language-server", "--stdio" },
				filetypes = { "yaml", "yaml.docker-compose" },
				root_markers = { ".git" },
				capabilities = capabilities,
			})

			-- Enable LSP servers
			vim.lsp.enable({ "ts_ls", "rust_analyzer", "lua_ls", "clangd", "html", "cssls", "jsonls", "yamlls" })
		end,
	},
}
