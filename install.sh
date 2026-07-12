#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(wezterm tmux nvim claude)

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

echo "Done. Restart your shell / reload tmux and neovim configs."
