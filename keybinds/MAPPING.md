# Keybind convention

Leader key: **Right Alt**, held + a letter. Right Alt is rarely bound by
anything else, and remappers can generally treat left vs. right Alt
independently, so it's a safe leader that won't collide with existing
shortcuts. (Caps Lock is remapped to Esc for vim motions, so it's not
available as a leader.)

Two kinds of binds live under this convention:

1. **Window switching** — apps with no built-in global "show/hide" hotkey.
   Implemented per-OS in this directory (currently `windows/Keybinds.ahk`
   via AutoHotkey v2). Toggle behavior: launch if not running, focus if
   running-but-not-active, minimize if already active.

2. **App actions** — apps that already ship their own global hotkey engine.
   Bound *inside that app's own settings*, not by the OS-level script, so
   the app's own hook still sees the keypress unmodified. This matters:
   the OS-level script only intercepts letters it explicitly binds, so an
   unbound `RAlt + <letter>` passes through untouched.

| Bind      | Action                       | Mechanism                        |
|-----------|-------------------------------|-----------------------------------|
| RAlt + O  | Show/hide Obsidian             | AHK (window switch)              |
| RAlt + C  | Show/hide Discord               | AHK (window switch)              |
| RAlt + W  | Show/hide OpenWhispr window     | AHK (window switch)              |
| RAlt + D  | Start/stop dictation            | OpenWhispr's own hotkey setting  |
| RAlt + M  | Toggle Discord mute             | Discord's own keybind setting    |
| RAlt + R  | Reload the AHK script           | AHK                              |

## Setting the native binds

**Discord** — Settings → Voice & Video → Keybinds → add "Toggle Mute" →
record `Alt + M`. Discord doesn't distinguish left/right Alt, so it'll
show as plain `Alt+M`; that's fine, nothing else uses that combo.

**OpenWhispr** — open its settings and look for a "Hotkey" / "Shortcut"
field for triggering dictation; set it to `Alt + D` (or whatever combo it
lets you record — some apps restrict which combos are recordable).

## Adding a new app

1. Find its `.exe` path and process name (Task Manager → Details → the
   `Name` column matches `ahk_exe`).
2. No built-in global hotkey: add a line to `windows/Keybinds.ahk`
   following the `ToggleApp(...)` pattern, pick an unused letter, add it
   to the table above.
3. Has its own global hotkey: set it natively to `Alt + <letter>` and
   just document it here — no AHK change needed.

## Other OSes

Not set up yet — add when actually needed, following the same leader and
letter conventions:
- Linux (X11): `sxhkd` → `linux/sxhkdrc`
- Linux (Hyprland/Wayland): compositor's native bind config
- macOS: `skhd` or Hammerspoon → `macos/skhdrc` / `macos/init.lua`
