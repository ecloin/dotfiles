#Requires AutoHotkey v2.0
#SingleInstance Force

; Leader key: Right Alt, held + a letter. See ../MAPPING.md for the full
; convention and why some binds (dictation, mute) live in the target
; app's own settings instead of here.

ToggleApp(procName, exe, args := "") {
    if WinExist("ahk_exe " procName) {
        if WinActive("ahk_exe " procName)
            WinMinimize("ahk_exe " procName)
        else
            WinActivate("ahk_exe " procName)
        return
    }
    try {
        if (args != "")
            Run('"' exe '" ' args)
        else
            Run(exe)
    } catch as e {
        MsgBox("Couldn't launch " procName ":`n" e.Message)
    }
}

; --- Window switching (apps below have no built-in global summon hotkey) ---
RAlt & o::ToggleApp("Obsidian.exe", "C:\Users\" A_UserName "\AppData\Local\Programs\Obsidian\Obsidian.exe")
RAlt & c::ToggleApp("Discord.exe", "C:\Users\" A_UserName "\AppData\Local\Discord\Update.exe", "--processStart Discord.exe")
RAlt & w::ToggleApp("OpenWhispr.exe", "C:\Users\" A_UserName "\AppData\Local\Programs\OpenWhispr\OpenWhispr.exe")

; RAlt+D (dictation) and RAlt+M (mute) are intentionally NOT bound here —
; set natively inside OpenWhispr / Discord so their own global hotkey
; hooks still see the keypress. This script only intercepts the letters
; it explicitly binds, so those combos pass through untouched.

; --- Script utility ---
RAlt & r::Reload

; --- Add more apps here, following the same pattern ---
; RAlt & x::ToggleApp("SomeApp.exe", "C:\path\to\SomeApp.exe")
