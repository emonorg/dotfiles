-- TypeScript LSP Switcher
-- Allows switching between ts_ls and tsgo for TypeScript/JavaScript files

local M = {}

-- Available TypeScript LSP configurations
local lsp_configs = {
	tsgo = {
		name = "tsgo",
		display_name = "tsgo (TypeScript 7 Native)",
		cmd = { "tsgo", "--lsp", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
		description = "Native TypeScript 7 port - faster performance",
	},
	ts_ls = {
		name = "ts_ls",
		display_name = "ts_ls (TypeScript Language Server)",
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
		description = "Standard TypeScript language server",
	},
}

-- Get current active TypeScript LSP
local function get_active_ts_lsp()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.name == "tsgo" or client.name == "ts_ls" then
			return client.name
		end
	end
	return nil
end

-- Stop all TypeScript LSP clients
local function stop_ts_lsp_clients()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.name == "tsgo" or client.name == "ts_ls" then
			vim.lsp.stop_client(client.id, true)
		end
	end
end

-- Check if a command exists
local function command_exists(cmd)
	return vim.fn.executable(cmd) == 1
end

-- Configure and start the selected LSP
local function start_lsp(lsp_name)
	local config = lsp_configs[lsp_name]
	if not config then
		vim.notify("Unknown LSP: " .. lsp_name, vim.log.levels.ERROR)
		return
	end

	-- Check if the LSP command is available
	if not command_exists(config.cmd[1]) then
		vim.notify(
			config.display_name .. " is not available. Command not found: " .. config.cmd[1],
			vim.log.levels.ERROR
		)
		return
	end

	-- Get capabilities from nvim-cmp
	local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	local capabilities = ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

	-- Configure the LSP
	vim.lsp.config(config.name, {
		cmd = config.cmd,
		filetypes = config.filetypes,
		root_markers = config.root_markers,
		capabilities = capabilities,
	})

	-- Enable the LSP
	vim.lsp.enable(config.name)

	-- Save preference
	vim.g.ts_lsp_preference = lsp_name

	vim.notify("Switched to " .. config.display_name, vim.log.levels.INFO)
end

-- Switch to a different LSP
local function switch_to(lsp_name)
	-- Stop current TypeScript LSP clients
	stop_ts_lsp_clients()

	-- Wait a bit for clients to stop
	vim.defer_fn(function()
		-- Start the new LSP
		start_lsp(lsp_name)

		-- Reload TypeScript buffers to attach the new LSP
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
				if vim.tbl_contains({ "typescript", "typescriptreact", "javascript", "javascriptreact" }, ft) then
					vim.cmd("silent! e")
				end
			end
		end
	end, 100)
end

-- Show interactive menu to select LSP
function M.select_lsp()
	local current = get_active_ts_lsp()
	local items = {}

	for key, config in pairs(lsp_configs) do
		-- Only show LSPs that are actually available
		if command_exists(config.cmd[1]) then
			local is_current = (current == key)
			local prefix = is_current and "[Active] " or "        "
			table.insert(items, {
				text = prefix .. config.display_name,
				description = config.description,
				key = key,
			})
		end
	end

	if #items == 0 then
		vim.notify("No TypeScript LSP servers are available. Install tsgo or typescript-language-server.", vim.log.levels.ERROR)
		return
	end

	if #items == 1 then
		vim.notify("Only one TypeScript LSP is available: " .. items[1].text, vim.log.levels.INFO)
		return
	end

	vim.ui.select(items, {
		prompt = "Select TypeScript LSP:",
		format_item = function(item)
			return item.text .. " - " .. item.description
		end,
	}, function(choice)
		if choice and choice.key ~= current then
			switch_to(choice.key)
		end
	end)
end

-- Verify LSP availability
function M.check_availability()
	local results = {}
	for key, config in pairs(lsp_configs) do
		local cmd = config.cmd[1]
		results[key] = {
			name = config.display_name,
			available = command_exists(cmd),
			command = cmd,
		}
	end

	-- Display results
	local lines = { "TypeScript LSP Availability Check:", "" }
	for key, result in pairs(results) do
		local status = result.available and "[Available]" or "[Not Found]"
		table.insert(lines, string.format("%s %s (%s)", status, result.name, result.command))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
	return results
end

-- Initialize with saved preference or default
function M.init()
	local preference = vim.g.ts_lsp_preference or "tsgo"

	-- Check if preferred LSP is available
	local config = lsp_configs[preference]
	if config and command_exists(config.cmd[1]) then
		start_lsp(preference)
	else
		-- Fall back to the other one
		local fallback = preference == "tsgo" and "ts_ls" or "tsgo"
		if lsp_configs[fallback] and command_exists(lsp_configs[fallback].cmd[1]) then
			vim.notify(
				preference .. " not available, falling back to " .. lsp_configs[fallback].display_name,
				vim.log.levels.WARN
			)
			start_lsp(fallback)
		else
			vim.notify("No TypeScript LSP available", vim.log.levels.ERROR)
		end
	end
end

return M
