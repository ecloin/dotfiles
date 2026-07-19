#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(wezterm tmux nvim claude)

setup_windows_keybinds() {
  if ! grep -qi microsoft /proc/version 2>/dev/null || ! command -v wslpath >/dev/null 2>&1; then
    return
  fi

  local ahk_script win_user ahk_exe startup_dir shortcut

  ahk_script="$(wslpath -w "$DOTFILES_DIR/keybinds/windows/Keybinds.ahk")"
  win_user="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"

  if [[ -z "$win_user" ]]; then
    echo "Couldn't determine Windows username; skipping AutoHotkey keybinds setup." >&2
    return
  fi

  ahk_exe="/mnt/c/Users/$win_user/AppData/Local/Programs/AutoHotkey/v2/AutoHotkey64.exe"
  if [[ ! -f "$ahk_exe" ]]; then
    echo "AutoHotkey v2 not found, installing via winget..."
    # --disable-interactivity so winget never blocks on a prompt, and a
    # timeout so a stalled interop session can't wedge the whole install.
    timeout 300 winget.exe install --id AutoHotkey.AutoHotkey --exact --silent \
      --accept-package-agreements --accept-source-agreements --disable-interactivity \
      || echo "winget install of AutoHotkey timed out or failed; install v2 manually if keybinds don't work." >&2
  fi

  if [[ ! -f "$ahk_exe" ]]; then
    echo "AutoHotkey install didn't land where expected ($ahk_exe); skipping keybinds setup." >&2
    return
  fi

  startup_dir="/mnt/c/Users/$win_user/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
  shortcut="$startup_dir/Keybinds.lnk"

  echo "Wiring up Keybinds.ahk to run at login..."
  powershell.exe -NoProfile -Command "
    \$ws = New-Object -ComObject WScript.Shell
    \$sc = \$ws.CreateShortcut('$(wslpath -w "$shortcut")')
    \$sc.TargetPath = '$(wslpath -w "$ahk_exe")'
    \$sc.Arguments = '\"$ahk_script\"'
    \$sc.WorkingDirectory = '$(wslpath -w "$(dirname "$ahk_exe")")'
    \$sc.Save()
  " >/dev/null

  echo "Starting Keybinds.ahk for this session..."
  # An AHK script is a persistent tray process that never exits. Fully detach
  # it (subshell + closed stdin) so it can't hold this call open under WSL interop.
  ( cmd.exe /c start "" "$(wslpath -w "$ahk_exe")" "$ahk_script" </dev/null >/dev/null 2>&1 & )

  echo "AutoHotkey keybinds active (RAlt+O/C/W to switch apps, RAlt+R to reload after edits)."
  echo "See keybinds/MAPPING.md for the full convention, including binds to set natively in Discord/OpenWhispr."
}

setup_windows_wezterm_config() {
  if ! grep -qi microsoft /proc/version 2>/dev/null || ! command -v wslpath >/dev/null 2>&1; then
    return
  fi

  local config_path_win

  config_path_win="$(wslpath -w "$DOTFILES_DIR/wezterm/.config/wezterm/wezterm.lua")"

  echo "Pointing native Windows WezTerm at the dotfiles config..."
  setx.exe WEZTERM_CONFIG_FILE "$config_path_win" >/dev/null

  echo "WEZTERM_CONFIG_FILE set to $config_path_win."
  echo "Quit and relaunch WezTerm (or log off/on if it doesn't pick it up) to apply."
}

install_linux_packages() {
  local pkgs=("$@")
  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y "${pkgs[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "${pkgs[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "${pkgs[@]}"
  elif command -v brew >/dev/null 2>&1; then
    brew install "${pkgs[@]}"
  else
    echo "No supported package manager found; install manually: ${pkgs[*]}" >&2
    exit 1
  fi
}

install_deps() {
  local missing=()
  command -v stow >/dev/null 2>&1 || missing+=(stow)
  command -v tmux >/dev/null 2>&1 || missing+=(tmux)
  command -v nvim >/dev/null 2>&1 || missing+=(neovim)

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Installing missing dependencies: ${missing[*]}..."
    install_linux_packages "${missing[@]}"
  fi
}

# On WSL, PATH inherits Windows entries (/mnt/c/...); if node/npx only resolve
# there, they run as Windows processes and write to the Windows filesystem
# instead of WSL's $HOME. Node is managed via nvm rather than the system package
# manager so version upgrades don't need sudo.
install_node() {
  export NVM_DIR="$HOME/.nvm"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi

  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"

  if [[ "$(command -v node 2>/dev/null)" != "$NVM_DIR"/* ]]; then
    echo "Installing latest Node.js via nvm..."
    nvm install node
  fi
}

install_cli_tools() {
  if ! command -v treehouse >/dev/null 2>&1; then
    echo "Installing treehouse..."
    curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
  fi

  if [[ ! -d "$HOME/.agents/skills/lavish" ]]; then
    echo "Installing lavish skill..."
    npx -y skills add kunchenguid/lavish-axi --skill lavish -g -y
  fi
}

setup_windows_deps() {
  if ! grep -qi microsoft /proc/version 2>/dev/null || ! command -v wslpath >/dev/null 2>&1; then
    return
  fi

  if ! cmd.exe /c "where wezterm" >/dev/null 2>&1; then
    echo "WezTerm not found on Windows, installing via winget..."
    timeout 300 winget.exe install --id wez.wezterm --exact --silent \
      --accept-package-agreements --accept-source-agreements --disable-interactivity \
      || echo "winget install of WezTerm timed out or failed; install it manually." >&2
  fi

  echo "Note: JetBrains Mono isn't in winget's font catalog on this machine (checked both the"
  echo "default and winget-font sources) - install it manually if wezterm.lua's font isn't rendering:"
  echo "  https://www.jetbrains.com/lp/mono/"
}

install_deps
install_node
install_cli_tools

cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  echo "Stowing $pkg..."
  stow --restow --target="$HOME" -v "$pkg"
done

setup_windows_deps
setup_windows_keybinds
setup_windows_wezterm_config

echo "Done. Restart your shell / reload tmux and neovim configs."
