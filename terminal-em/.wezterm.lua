local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font('Gitlab Mono')
config.font_size = 13

-- Color scheme (matches nvim vim-code-dark / VS Code Dark+)
config.colors = {
  foreground = '#d4d4d4',
  background = '#1e1e1e',
  cursor_bg = '#aeafad',
  cursor_fg = '#1e1e1e',
  cursor_border = '#aeafad',
  selection_fg = '#d4d4d4',
  selection_bg = '#264f78',
  ansi = { '#000000', '#cd3131', '#0dbc79', '#e5e510', '#569cd6', '#c586c0', '#4ec9b0', '#e5e5e5' },
  brights = { '#666666', '#f14c4c', '#23d18b', '#f5f543', '#9cdcfe', '#d670d6', '#4ec9b0', '#ffffff' },
  tab_bar = {
    background = '#252526',
    active_tab = { bg_color = '#1e1e1e', fg_color = '#ffffff' },
    inactive_tab = { bg_color = '#2d2d2d', fg_color = '#969696' },
    inactive_tab_hover = { bg_color = '#1e1e1e', fg_color = '#d4d4d4' },
    new_tab = { bg_color = '#252526', fg_color = '#969696' },
    new_tab_hover = { bg_color = '#1e1e1e', fg_color = '#d4d4d4' },
  },
}

-- Window configuration
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE"

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- Scrollback
config.scrollback_lines = 10000

return config
