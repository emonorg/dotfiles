local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14.0

-- Color scheme
config.color_scheme = 'Gruvbox Dark (Gogh)'

-- Window configuration
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE"

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- Scrollback
config.scrollback_lines = 10000

return config
