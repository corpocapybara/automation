#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Wait for Discord window
if !WinWait("ahk_exe Discord.exe", , 10)
    ExitApp

WinActivate("ahk_exe Discord.exe")
Sleep 500

Send "^+q"
Sleep 300

ExitApp
