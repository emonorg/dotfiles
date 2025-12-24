-- Simple Neovim Configuration

-- ============================================================================
-- Leader key (MUST be set before any keymaps)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Plugin Manager (lazy.nvim)
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
local colorscheme = dofile(vim.fn.stdpath("config") .. "/plugins/colorscheme.lua")
local lsp = dofile(vim.fn.stdpath("config") .. "/plugins/lsp.lua")
local cmp = dofile(vim.fn.stdpath("config") .. "/plugins/cmp.lua")
local autopairs = dofile(vim.fn.stdpath("config") .. "/plugins/autopairs.lua")
local telescope = dofile(vim.fn.stdpath("config") .. "/plugins/telescope.lua")
local bufferline = dofile(vim.fn.stdpath("config") .. "/plugins/bufferline.lua")
local treesitter = dofile(vim.fn.stdpath("config") .. "/plugins/treesitter.lua")
local lualine = dofile(vim.fn.stdpath("config") .. "/plugins/lualine.lua")
local fidget = dofile(vim.fn.stdpath("config") .. "/plugins/fidget.lua")
local conform = dofile(vim.fn.stdpath("config") .. "/plugins/conform.lua")
require("lazy").setup({
	colorscheme,
	lsp[1], -- mason.nvim
	lsp[2], -- mason-lspconfig.nvim
	lsp[3], -- nvim-lspconfig
	fidget, -- LSP progress notifications
	cmp[1], -- nvim-cmp
	autopairs, -- nvim-autopairs
	telescope, -- telescope.nvim
	bufferline, -- bufferline.nvim
	treesitter, -- nvim-treesitter
	lualine, -- statusline
	conform, -- formatting with conditional prettier
})

-- ============================================================================
-- Basic Options
-- ============================================================================

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = "110"
vim.opt.textwidth = 110

-- Editor behavior
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Split windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- ============================================================================
-- Load Keymaps
-- ============================================================================
dofile(vim.fn.stdpath("config") .. "/keymaps.lua")

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Format on save using conform.nvim (will use Prettier if config exists, otherwise LSP)
local conform = require("conform")
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    conform.format({
      bufnr = args.buf,
      lsp_fallback = true,
      timeout_ms = 3000,
      async = false,
    })
  end,
})

-- ============================================================================
-- Netrw (Built-in file explorer) Settings
-- ============================================================================

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

-- ============================================================================
-- TypeScript LSP Switcher Commands
-- ============================================================================

-- Command to switch TypeScript LSP
vim.api.nvim_create_user_command("TSLspSwitch", function()
	require("ts-lsp-switcher").select_lsp()
end, { desc = "Switch between TypeScript LSP implementations" })

-- Command to check LSP availability
vim.api.nvim_create_user_command("TSLspCheck", function()
	require("ts-lsp-switcher").check_availability()
end, { desc = "Check TypeScript LSP availability" })
