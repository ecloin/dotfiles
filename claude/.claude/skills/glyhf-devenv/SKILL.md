---
name: glyhf-devenv
description: glyhf's personal terminal and dev-environment preferences — WezTerm, herdr (terminal multiplexer, replaced tmux), Neovim, shell conventions, and workflow habits. Load when configuring, discussing, or troubleshooting glyhf's terminal setup, dotfiles, keybindings, or CLI workflow.
---

# glyhf's Dev Environment Preferences

Living reference for how glyhf likes their terminal environment configured. This
file is the canonical copy, versioned in `~/dotfiles/claude/.claude/skills/glyhf-devenv/SKILL.md`
and symlinked into `~/.claude/skills/glyhf-devenv/SKILL.md` (via `stow claude`, see
`~/dotfiles/install.sh`). Update it whenever a preference is settled during config work —
it should stay in sync with the actual configs under `~/dotfiles`.

## Philosophy
- (TBD — fill in as decisions are made: minimal vs. batteries-included, keyboard-first, etc.)

## WezTerm
- Config: `~/dotfiles/wezterm/.config/wezterm/wezterm.lua`
- Runs as a native Windows GUI app even when launched from/into WSL, so it
  reads config from `%USERPROFILE%`, not from WSL's `~/.config`. `install.sh`
  bridges this by setting the Windows env var `WEZTERM_CONFIG_FILE` (via
  `setx.exe`) to the WSL UNC path of this file — no manual Windows-side setup,
  no copied/duplicated config.
- `config.default_domain = "WSL:Ubuntu"` — every new window/tab opens directly
  into WSL Ubuntu instead of a local Windows shell.
- (TBD: keybindings, tab/pane behavior)

## herdr (terminal multiplexer)
- Replaced tmux as of 2026-07-19 (commit `f1b44b7`) — agent-aware multiplexer,
  installed via `curl -fsSL https://herdr.dev/install.sh | sh`.
- Config: `~/dotfiles/herdr/.config/herdr/config.toml`, stowed to `~/.config/herdr`.
- Current prefix: `ctrl+a` (changed from default `ctrl+b`, same reasoning as the
  old tmux setup — matches nvim's `space` leader in *pattern* only, not literal
  key: the multiplexer must consume the prefix before nvim ever sees it, so a
  shared literal key would break whichever tool's mapping loses the race).
  Caps-lock-remap-as-prefix was considered as a more ergonomic alternative to
  a ctrl-chord but explicitly deferred for now.
- (TBD: pane/window navigation, plugin manager equivalent, status bar)

## Neovim
- Config: `~/dotfiles/nvim/.config/nvim/`
- Leader key: space
- (TBD: plugin manager, LSP setup, colorscheme)

## Shell
- (TBD: bash vs zsh, prompt, aliases)

## Cross-tool conventions
- (TBD: shared keybinding philosophy across tmux/nvim/wezterm)

## Open questions
- (running list of decisions not yet made)
