-- ~/.wezterm.lua
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Boot straight into WSL. Must match `wsl -l -q` exactly.
config.default_domain = 'WSL:Ubuntu'

-- Font -------------------------------------------------------------------
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
  'Symbols Nerd Font Mono',
}
config.font_size = 11.0
config.line_height = 1.05
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Appearance -------------------------------------------------------------
config.color_scheme = 'Catppuccin Mocha'
config.window_decorations = 'TITLE|RESIZE'
config.window_padding = { left = 6, right = 6, top = 6, bottom = 0 }
config.default_cursor_style = 'BlinkingBar'
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false

-- Zellij owns tabs, panes and scrollback. Don't run two tab bars.
config.enable_tab_bar = false
config.scrollback_lines = 5000

-- Terminal capabilities --------------------------------------------------
-- Kitty keyboard protocol: lets Shift+Enter, Ctrl+Enter etc. survive the
-- trip through Zellij into Claude Code. Zellij speaks this protocol too.
config.enable_kitty_keyboard = true
config.enable_kitty_graphics = true

-- Performance ------------------------------------------------------------
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 120
config.animation_fps = 1
config.audible_bell = 'Disabled'

-- Keys -------------------------------------------------------------------
config.keys = {
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
  -- Fallback if Shift+Enter ever stops reaching Claude Code. Sends the
  -- Alt+Enter sequence, which Claude Code also treats as a newline.
  -- { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
}

return config