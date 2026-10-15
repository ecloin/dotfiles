-- THIS is the config WezTerm actually loads.
--
-- A persisted Windows user environment variable pins it explicitly:
--   HKCU\Environment  WEZTERM_CONFIG_FILE =
--     \\wsl.localhost\Ubuntu-24.04\home\ecloin\dotfiles\wezterm\.config\wezterm\wezterm.lua
--
-- WEZTERM_CONFIG_FILE is WezTerm's HIGHEST-precedence config source: it beats
-- $HOME/.wezterm.lua and $HOME/.config/wezterm/wezterm.lua outright. Editing
-- C:\Users\ecloin\.wezterm.lua therefore does nothing -- that mistake is what
-- left the F8 sidebar dead while F8 kept emitting a bare \x1b[19~ to the shell.
-- Edit THIS file. Verify with `wezterm show-keys` from a Windows shell.
--
-- Caveat of the pin: this path is read over \\wsl.localhost, so if WSL is not
-- running when WezTerm launches, WezTerm falls back to its built-in defaults.

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Trial 2026-10-15: rose-pine-dawn for link readability; previous: "Tokyo Night".
config.color_scheme = "rose-pine-dawn"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 12.0
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.enable_tab_bar = true

-- Tab bar in Rose Pine Dawn so the window frame matches the light theme (2026-10-15).
config.window_frame = {
  active_titlebar_bg = "#f2e9e1",
  inactive_titlebar_bg = "#f2e9e1",
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = "#dfdad9",
    active_tab = { bg_color = "#faf4ed", fg_color = "#575279" },
    inactive_tab = { bg_color = "#f2e9e1", fg_color = "#797593" },
    inactive_tab_hover = { bg_color = "#dfdad9", fg_color = "#575279" },
    new_tab = { bg_color = "#f2e9e1", fg_color = "#797593" },
    new_tab_hover = { bg_color = "#dfdad9", fg_color = "#575279" },
  },
}

-- Render cost: added 2026-08-17 after wezterm-gui measured at 39.5% of one core
-- while completely IDLE (8s sample, nothing streaming; 942s cumulative CPU, the
-- highest of any process on the box). This machine is on Intel UHD 770
-- integrated graphics, and nothing here had ever set a rendering option, so it
-- was running every expensive default at once. The blinking cursor is the worst
-- of them: it forces a full repaint forever, whether or not anything changed.
-- If the idle number is still high, try front_end = "Software" -- on text there
-- is no visible quality difference.
config.front_end = "OpenGL"
config.max_fps = 30
config.animation_fps = 1
config.cursor_blink_rate = 0
config.default_cursor_style = "SteadyBlock"

config.keys = {
	-- Ctrl+Left/Right move by word (readline's meta-b / meta-f).
	{ key = "LeftArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bb") },
	{ key = "RightArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bf") },

	-- Bind plain Ctrl+V to a bracketed text paste. Otherwise raw ^V passes
	-- through to Claude Code, which treats it as an image-paste request
	-- ("no image found") and breaks Wispr Flow's simulated Ctrl+V paste.
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },

	-- Ctrl-Shift-R force-reloads this config. WezTerm already auto-reloads on
	-- save, but this gives an explicit, immediate reload on demand.
	-- ReloadConfiguration is silent by default, so we wrap it in a callback that
	-- pops a toast first -- that toast is proof the keybinding fired, which also
	-- makes it a cheap check that THIS file is the one being loaded.
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:toast_notification("WezTerm", "Config reloaded", nil, 4000)
			window:perform_action(wezterm.action.ReloadConfiguration, pane)
		end),
	},

	-- F8 fleet sidebar: REMOVED 2026-08-11. The toggle worked, but the sidebar
	-- itself was not the right shape - its watch loop re-printed the header on
	-- every refresh instead of redrawing, so it scrolled forever. The captain
	-- tabled the feature pending a design session (firstmate backlog item
	-- "fleet-sidebar-redesign", which records the defects and the working
	-- toggle implementation). Restoring it is a config addition, not a rebuild.
}

-- Mouse behavior:
--   * Do NOT auto-copy to the system clipboard when you highlight text.
--     Selecting only fills the (Windows-inert) primary selection, so your
--     clipboard is left untouched until you explicitly copy with
--     Ctrl-C / Ctrl-Shift-C.
--   * Ctrl-Click opens the hyperlink under the mouse in your default browser.
-- Let CTRL "bypass" an app's mouse capture. Full-screen TUIs (Claude Code,
-- nvim) and multiplexers grab mouse clicks before WezTerm sees them; holding
-- this modifier tells WezTerm to handle the click itself, so Ctrl-Click can
-- open a link even from inside those apps. (Default is SHIFT, which never
-- matched the Ctrl-Click open-link binding below.)
config.bypass_mouse_reporting_modifiers = "CTRL"

config.mouse_bindings = {
	-- Releasing the left button: if you dragged, complete the selection to the
	-- PRIMARY selection only (never the system clipboard -- no copy-on-select);
	-- if you just clicked on a link, open it instead.
	--
	-- This single NONE-mods rule also covers mouse-capturing apps: WezTerm
	-- strips the bypass modifier (Ctrl, set above) before matching, so Ctrl+drag
	-- selects and Ctrl+click opens a link in those apps, matching this same
	-- rule. The default Down/Drag bindings that begin and extend the selection
	-- are left intact (custom bindings merge with the defaults), so highlighting
	-- works everywhere.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("PrimarySelection"),
	},
}

-- Make URLs (and OSC 8 hyperlinks) clickable using the built-in rule set.
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Launched from Windows, but the actual work happens in WSL Ubuntu.
--
-- WezTerm auto-generates a 'WSL:Ubuntu-24.04' domain, but that auto domain
-- inherits its working directory from wherever the Windows wezterm.exe process
-- started (typically /mnt/c/Users/ecloin), so new panes/windows -- and anything
-- launched inside them -- open on the Windows path instead of the WSL home.
-- Declaring the domain explicitly here (the name MUST match the auto-generated
-- one to override it) lets us pin default_cwd to the WSL home directory.
-- default_cwd is a path *inside* WSL; use the absolute /home/ecloin rather than
-- '~', which is not expanded.
config.wsl_domains = {
	{
		name = "WSL:Ubuntu-24.04",
		distribution = "Ubuntu-24.04",
		default_cwd = "/home/ecloin",
	},
}
config.default_domain = "WSL:Ubuntu-24.04"

-- Windows-side shells, so Windows Terminal is no longer needed alongside this.
-- WSL stays the default domain (Ctrl-Shift-T); these spawn in the "local"
-- domain, i.e. native Windows processes. Right-click the "+" tab button or press
-- Ctrl-Shift-O for the picker; Ctrl-Shift-G opens Git Bash directly. Git Bash
-- starts in CopernicusGit, matching the old Windows Terminal "Git Bash" profile.
local git_bash = {
	label = "Git Bash (CopernicusGit)",
	args = { "C:/Program Files/Git/bin/bash.exe", "--login", "-i" },
	cwd = "C:/Users/ecloin/Repo/CopernicusGit",
	domain = { DomainName = "local" },
}

config.launch_menu = {
	git_bash,
	{ label = "PowerShell 7", args = { "pwsh.exe", "-NoLogo" }, cwd = "C:/Users/ecloin", domain = { DomainName = "local" } },
	{ label = "Windows PowerShell", args = { "powershell.exe", "-NoLogo" }, cwd = "C:/Users/ecloin", domain = { DomainName = "local" } },
	{ label = "Command Prompt", args = { "cmd.exe" }, cwd = "C:/Users/ecloin", domain = { DomainName = "local" } },
	{ label = "Firstmate (herdr)", args = { "bash", "-lc", "exec herdr" }, domain = { DomainName = "WSL:Ubuntu-24.04" } },
}

table.insert(config.keys, { key = "g", mods = "CTRL|SHIFT", action = wezterm.action.SpawnCommandInNewTab(git_bash) })
table.insert(config.keys, {
	key = "o",
	mods = "CTRL|SHIFT",
	action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS" }),
})

return config
