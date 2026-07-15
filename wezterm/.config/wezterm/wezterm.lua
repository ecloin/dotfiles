local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 12.0
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.enable_tab_bar = true

-- Launched from Windows, but the actual work happens in WSL Ubuntu.
config.default_domain = "WSL:Ubuntu"

return config
