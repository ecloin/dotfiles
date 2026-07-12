---
name: glyhf-devenv
description: glyhf's personal terminal and dev-environment preferences — WezTerm, tmux, Neovim, shell conventions, and workflow habits. Load when configuring, discussing, or troubleshooting glyhf's terminal setup, dotfiles, keybindings, or CLI workflow.
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
- (TBD: font, theme, keybindings, tab/pane behavior)

## tmux
- Config: `~/dotfiles/tmux/.tmux.conf`
- Current prefix: `C-a` (changed from default `C-b`)
- (TBD: pane/window navigation, plugin manager (TPM?), status bar)

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
