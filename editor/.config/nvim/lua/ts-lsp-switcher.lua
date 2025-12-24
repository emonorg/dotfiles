-- TypeScript LSP Switcher
-- Allows switching between ts_ls and tsgo for TypeScript/JavaScript files

local M = {}

-- Constants
local TS_FILETYPES = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
local TS_ROOT_MARKERS = { "package.json", "tsconfig.json", "jsconfig.json" }
local LSP_NAMES = { "tsgo", "ts_ls" }

-- Available TypeScript LSP configurations
local lsp_configs = {
	tsgo = {
		name = "tsgo",
		display_name = "tsgo (TypeScript 7 Native)",
		cmd = { "tsgo", "--lsp", "--stdio" },
		filetypes = TS_FILETYPES,
		root_markers = TS_ROOT_MARKERS,
		description = "Native TypeScript 7 port - faster performance",
	},
	ts_ls = {
		name = "ts_ls",
		display_name = "ts_ls (TypeScript Language Server)",
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = TS_FILETYPES,
		root_markers = TS_ROOT_MARKERS,
		description = "Standard TypeScript language server",
	},
}

-- Helper functions

local function command_exists(cmd)
	return vim.fn.executable(cmd) == 1
end

local function is_ts_lsp(client_name)
	return vim.tbl_contains(LSP_NAMES, client_name)
end

local function get_active_ts_lsp()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if is_ts_lsp(client.name) then
			return client.name
		end
	end
	return nil
end

local function stop_ts_lsp_clients()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if is_ts_lsp(client.name) then
			vim.lsp.stop_client(client.id, true)
		end
	end
end

local function get_capabilities()
	local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	return ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()
end

local function reload_ts_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
			if vim.tbl_contains(TS_FILETYPES, ft) then
				vim.cmd("silent! e")
			end
		end
	end
end

-- LSP management functions

local function start_lsp(lsp_name)
	local config = lsp_configs[lsp_name]
	if not config then
		vim.notify("Unknown LSP: " .. lsp_name, vim.log.levels.ERROR)
		return false
	end

	if not command_exists(config.cmd[1]) then
		vim.notify(
			string.format("%s is not available. Command not found: %s", config.display_name, config.cmd[1]),
			vim.log.levels.ERROR
		)
		return false
	end

	vim.lsp.config(config.name, {
		cmd = config.cmd,
		filetypes = config.filetypes,
		root_markers = config.root_markers,
		capabilities = get_capabilities(),
	})

	vim.lsp.enable(config.name)
	vim.g.ts_lsp_preference = lsp_name
	vim.notify("Switched to " .. config.display_name, vim.log.levels.INFO)
	return true
end

local function switch_to(lsp_name)
	stop_ts_lsp_clients()

	vim.defer_fn(function()
		if start_lsp(lsp_name) then
			reload_ts_buffers()
		end
	end, 100)
end

-- Public API

function M.select_lsp()
	local current = get_active_ts_lsp()
	local items = {}

	for key, config in pairs(lsp_configs) do
		if command_exists(config.cmd[1]) then
			local prefix = (current == key) and "[Active] " or "        "
			table.insert(items, {
				text = prefix .. config.display_name,
				description = config.description,
				key = key,
			})
		end
	end

	if #items == 0 then
		vim.notify(
			"No TypeScript LSP servers are available. Install tsgo or typescript-language-server.",
			vim.log.levels.ERROR
		)
		return
	end

	if #items == 1 then
		vim.notify("Only one TypeScript LSP is available: " .. items[1].text, vim.log.levels.INFO)
		return
	end

	vim.ui.select(items, {
		prompt = "Select TypeScript LSP:",
		format_item = function(item)
			return string.format("%s - %s", item.text, item.description)
		end,
	}, function(choice)
		if choice and choice.key ~= current then
			switch_to(choice.key)
		end
	end)
end

function M.check_availability()
	local results = {}
	for key, config in pairs(lsp_configs) do
		results[key] = {
			name = config.display_name,
			available = command_exists(config.cmd[1]),
			command = config.cmd[1],
		}
	end

	local lines = { "TypeScript LSP Availability Check:", "" }
	for _, result in pairs(results) do
		local status = result.available and "[Available]" or "[Not Found]"
		table.insert(lines, string.format("%s %s (%s)", status, result.name, result.command))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
	return results
end

function M.init()
	local preference = vim.g.ts_lsp_preference or "tsgo"
	local config = lsp_configs[preference]

	if config and command_exists(config.cmd[1]) then
		start_lsp(preference)
		return
	end

	-- Fallback to alternative LSP
	local fallback = (preference == "tsgo") and "ts_ls" or "tsgo"
	local fallback_config = lsp_configs[fallback]

	if fallback_config and command_exists(fallback_config.cmd[1]) then
		vim.notify(
			string.format("%s not available, falling back to %s", preference, fallback_config.display_name),
			vim.log.levels.WARN
		)
		start_lsp(fallback)
	else
		vim.notify("No TypeScript LSP available", vim.log.levels.ERROR)
	end
end

return M
