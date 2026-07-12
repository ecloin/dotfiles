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
    winget.exe install --id AutoHotkey.AutoHotkey --exact --silent \
      --accept-package-agreements --accept-source-agreements
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
    \$sc.WorkingDirectory = '$(dirname "$(wslpath -w "$ahk_exe")")'
    \$sc.Save()
  " >/dev/null

  echo "Starting Keybinds.ahk for this session..."
  cmd.exe /c start "" "$(wslpath -w "$ahk_exe")" "$ahk_script" >/dev/null 2>&1 || true

  echo "AutoHotkey keybinds active (RAlt+O/C/W to switch apps, RAlt+R to reload after edits)."
  echo "See keybinds/MAPPING.md for the full convention, including binds to set natively in Discord/OpenWhispr."
}

install_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  echo "GNU Stow not found, installing..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y stow
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y stow
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm stow
  elif command -v brew >/dev/null 2>&1; then
    brew install stow
  else
    echo "No supported package manager found; install GNU Stow manually and re-run." >&2
    exit 1
  fi
}

install_stow

cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  echo "Stowing $pkg..."
  stow --restow --target="$HOME" -v "$pkg"
done

setup_windows_keybinds

echo "Done. Restart your shell / reload tmux and neovim configs."
