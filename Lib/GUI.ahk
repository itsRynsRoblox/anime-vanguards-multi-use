#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
#Include Functions.ahk

;Update Checker
global repoOwner := "itsRynsRoblox"
global repoName := "anime-vanguards-multi-use"
global currentVersion := "1.2.4"
; Basic Application Info
global aaTitle := "Ryn's Anime Vanguards Macro "
global version := "v" . currentVersion
global rblxID := "ahk_exe RobloxPlayerBeta.exe"
;Coordinate and Positioning Variables
global targetWidth := 816
global targetHeight := 638
global offsetX := -5
global offsetY := 1
global WM_SIZING := 0x0214
global WM_SIZE := 0x0005
global centerX := 408
global centerY := 320
global successfulCoordinates := []
global maxedCoordinates := []
;State Variables
global enabledUnits := Map()  
global placementValues := Map()
;Hotkeys
global F1Key := "F1"
global F2Key := "F2"
global F3Key := "F3"
global F4Key := "F4"
;Statistics Tracking
global Wins := 0
global loss := 0
global mode := ""
global StartTime := A_TickCount
global currentTime := GetCurrentTime()
;Cards
global CardPriority1 := ""
global CardPriority2 := ""
global CardPriority3 := ""
global CardPriority4 := ""
global settingsPri1 := ""
global settingsPri2 := ""
global settingsPri3 := ""
global settingsPri4 := ""
global cardSettingsGUI := ""
;Custom Unit Placement
global waitingForClick := false
global savedCoords := []  ; Initialize an empty array to hold the coordinates
;Gui creation
global uiBorders := []
global uiBackgrounds := []
global uiTheme := []
global UnitData := []
global aaMainUI := Gui("+AlwaysOnTop -Caption")
global lastlog := ""
global aaMainUIHwnd := aaMainUI.Hwnd
;Theme colors
uiTheme.Push("0xffffff")  ; Header color
uiTheme.Push("0c000a")  ; Background color
uiTheme.Push("0xffffff")    ; Border color
uiTheme.Push("0c000a")  ; Accent color
uiTheme.Push("0x3d3c36")   ; Trans color
uiTheme.Push("000000")    ; Textbox color
uiTheme.Push("00ffb3") ; HighLight
;Logs/Save settings
global settingsGuiOpen := false
global SettingsGUI := ""
global cardSettingsGuiOpen := false
global CardSettingsGUI := ""
global currentOutputFile := A_ScriptDir "\Logs\LogFile.txt"
global WebhookURLFile := "Settings\WebhookURL.txt"
global DiscordUserIDFile := "Settings\DiscordUSERID.txt"
global SendActivityLogsFile := "Settings\SendActivityLogs.txt"
;Custom Pictures
GithubImage := "Images\github-logo.png"
DiscordImage := "Images\another_discord.png"

if !DirExist(A_ScriptDir "\Logs") {
    DirCreate(A_ScriptDir "\Logs")
}
if !DirExist(A_ScriptDir "\Settings") {
    DirCreate(A_ScriptDir "\Settings")
}

setupOutputFile()

;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
aaMainUI.BackColor := uiTheme[2]
global Webhookdiverter := aaMainUI.Add("Edit", "x0 y0 w1 h1 +Hidden", "") ; diversion
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1364 h1 +Background" uiTheme[3]))  ;Top line
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1 h697 +Background" uiTheme[3]))   ;Left line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h630 +Background" uiTheme[3])) ;Right line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h697 +Background" uiTheme[3])) ;Second Right line
uiBackgrounds.Push(aaMainUI.Add("Text", "x3 y3 w1360 h27 +Background" uiTheme[2])) ;Title Top
uiBorders.Push(aaMainUI.Add("Text", "x0 y30 w1363 h1 +Background" uiTheme[3])) ;Title bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y443 w560 h1 +Background" uiTheme[3])) ;Placement bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y527 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(aaMainUI.Add("Text", "x802 y30 w1 h667 +Background" uiTheme[3])) ;Roblox Right
uiBorders.Push(aaMainUI.Add("Text", "x0 y697 w1364 h1 +Background" uiTheme[3], "")) ;Roblox second bottom

global robloxHolder := aaMainUI.Add("Text", "x3 y33 w797 h597 +Background" uiTheme[5], "") ;Roblox window box
global exitButton := aaMainUI.Add("Picture", "x1330 y1 w32 h32 +BackgroundTrans", Exitbutton) ;Exit image
exitButton.OnEvent("Click", (*) => Destroy()) ;Exit button
global minimizeButton := aaMainUI.Add("Picture", "x1300 y3 w27 h27 +Background" uiTheme[2], Minimize) ;Minimize gui
minimizeButton.OnEvent("Click", (*) => minimizeUI()) ;Minimize gui
aaMainUI.SetFont("Bold s16 c" uiTheme[1], "Verdana") ;Font
global windowTitle := aaMainUI.Add("Text", "x10 y3 w1200 h29 +BackgroundTrans", aaTitle "" . "" version) ;Title

aaMainUI.Add("Text", "x805 y501 w558 h25 +Center +BackgroundTrans", "Process") ;Process header
uiBorders.Push(aaMainUI.Add("Text", "x803 y499 w560 h1 +Background" uiTheme[3])) ;Process Top
aaMainUI.SetFont("norm s11 c" uiTheme[1]) ;Font
global process1 := aaMainUI.Add("Text", "x810 y536 w538 h18 +BackgroundTrans c" uiTheme[7], "➤ Original Creator: Ryn") ;Processes
global process2 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") ;Processes 
global process3 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process4 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process5 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process6 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process7 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
WinSetTransColor(uiTheme[5], aaMainUI) ;Roblox window box

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
ShowSettingsGUI(*) {
    global settingsGuiOpen, SettingsGUI
    
    ; Check if settings window already exists
    if (SettingsGUI && WinExist("ahk_id " . SettingsGUI.Hwnd)) {
        WinActivate("ahk_id " . SettingsGUI.Hwnd)
        return
    }
    
    if (settingsGuiOpen) {
        return
    }
    
    settingsGuiOpen := true
    SettingsGUI := Gui("-MinimizeBox +Owner" aaMainUIHwnd)  
    SettingsGui.Title := "Settings"
    SettingsGUI.OnEvent("Close", OnSettingsGuiClose)
    SettingsGUI.BackColor := uiTheme[2]
    
    ; Window border
    SettingsGUI.Add("Text", "x0 y0 w1 h600 +Background" uiTheme[3])     ; Left
    SettingsGUI.Add("Text", "x599 y0 w1 h600 +Background" uiTheme[3])   ; Right
    SettingsGUI.Add("Text", "x0 y399 w600 h1 +Background" uiTheme[3])   ; Bottom
    
    ; Right side sections
    SettingsGUI.SetFont("s10", "Verdana")
    SettingsGUI.Add("GroupBox", "x310 y5 w280 h160 c" uiTheme[1], "Discord Webhook")  ; Box
    
    SettingsGUI.SetFont("s9", "Verdana")
    SettingsGUI.Add("Text", "x320 y30 c" uiTheme[1], "Webhook URL")     ; Webhook Text
    global WebhookURLBox := SettingsGUI.Add("Edit", "x320 y50 w260 h20 c" uiTheme[6])  ; Store webhook
    SettingsGUI.Add("Text", "x320 y83 c" uiTheme[1], "Discord ID (optional)")  ; Discord Id Text
    global DiscordUserIDBox := SettingsGUI.Add("Edit", "x320 y103 w260 h20 c" uiTheme[6])  ; Store Discord ID
    global SendActivityLogsBox := SettingsGUI.Add("Checkbox", "x320 y135 c" uiTheme[1], "Send Process")  ; Enable Activity

    ; HotKeys
    SettingsGUI.Add("GroupBox", "x10 y90 w160 h160 c" uiTheme[1], "Keybinds")
    SettingsGUI.Add("Text", "x20 y110 c" uiTheme[1], "Position Roblox:")
    global F1Box := SettingsGUI.Add("Edit", "x125 y110 w30 h20 c" uiTheme[6], F1Key)
    SettingsGUI.Add("Text", "x20 y140 c" uiTheme[1], "Start Macro:")
    global F2Box := SettingsGUI.Add("Edit", "x100 y140 w30 h20 c" uiTheme[6], F2Key)
    SettingsGUI.Add("Text", "x20 y170 c" uiTheme[1], "Stop Macro:")
    global F3Box := SettingsGUI.Add("Edit", "x100 y170 w30 h20 c" uiTheme[6], F3Key)
    SettingsGUI.Add("Text", "x20 y200 c" uiTheme[1], "Pause Macro:")
    global F4Box := SettingsGUI.Add("Edit", "x110 y200 w30 h20 c" uiTheme[6], F4Key)

    ; Private Server section
    SettingsGUI.Add("GroupBox", "x310 y280 w280 h100 c" uiTheme[1], "PS Link")  ; Box
    SettingsGUI.Add("Text", "x320 y300 c" uiTheme[1], "Private Server Link (optional)")  ; Ps text
    global PsLinkBox := SettingsGUI.Add("Edit", "x320 y320 w260 h20 c" uiTheme[6])  ;  ecit box

    SettingsGUI.Add("GroupBox", "x10 y10 w115 h70 c" uiTheme[1], "UI Navigation")
    SettingsGUI.Add("Text", "x20 y30 c" uiTheme[1], "Navigation Key")
    global UINavBox := SettingsGUI.Add("Edit", "x20 y50 w20 h20 c" uiTheme[6], "\")

    SettingsGUI.Add("GroupBox", "x160 y10 w115 h70 c" uiTheme[1], "Card Priority")
    PriorityPickerButton := SettingsGUI.Add("Button", "x170 y50 w95 h20", "Edit")
    PriorityPickerButton.OnEvent("Click", (*) => OpenPriorityPicker())


    ; Save buttons
    webhookSaveBtn := SettingsGUI.Add("Button", "x460 y135 w120 h25", "Save Webhook")
    webhookSaveBtn.OnEvent("Click", (*) => SaveWebhookSettings())

    keybindSaveBtn := SettingsGUI.Add("Button", "x20 y220 w50 h20", "Save")
    keybindSaveBtn.OnEvent("Click", SaveKeybindSettings)

    PsSaveBtn := SettingsGUI.Add("Button", "x460 y345 w120 h25", "Save PsLink")
    PsSaveBtn.OnEvent("Click", (*) => SavePsSettings())

    UINavSaveBtn := SettingsGUI.Add("Button", "x50 y50 w60 h20", "Save")
    UINavSaveBtn.OnEvent("Click", (*) => SaveUINavSettings())

    ; Loadsettings
    if FileExist(WebhookURLFile)
        WebhookURLBox.Value := FileRead(WebhookURLFile, "UTF-8")
    if FileExist(DiscordUserIDFile)
        DiscordUserIDBox.Value := FileRead(DiscordUserIDFile, "UTF-8")
    if FileExist(SendActivityLogsFile)
        SendActivityLogsBox.Value := (FileRead(SendActivityLogsFile, "UTF-8") = "1")   
    if FileExist("Settings\PrivateServer.txt")
        PsLinkBox.Value := FileRead("Settings\PrivateServer.txt", "UTF-8")
    if FileExist("Settings\UINavigation.txt")
        UINavBox.Value := FileRead("Settings\UINavigation.txt", "UTF-8")

    ; Show the settings window
    SettingsGUI.Show("w600 h400")
    Webhookdiverter.Focus()
}

;--------------CARDS;--------------CARDS;--------------CARDS;--------------CARDS;--------------CARDS

ShowCardSettingsGUI(*) {
    global CardSettingsGUI, cardSettingsGuiOpen
    global settingsPri1, settingsPri2, settingsPri3, settingsPri4
    
    ; Check if settings window already exists
    if (CardSettingsGUI && WinExist("ahk_id " . CardSettingsGUI.Hwnd)) {
        WinActivate("ahk_id " . CardSettingsGUI.Hwnd)
        return
    }
    
    if (cardSettingsGuiOpen) {
        return
    }
    
    cardSettingsGuiOpen := true
    CardSettingsGUI := Gui("-MinimizeBox +Owner" aaMainUIHwnd)
    CardSettingsGUI.Title := "Legend Card Settings"
    CardSettingsGUI.OnEvent("Close", OnCardSettingsClose)
    CardSettingsGUI.BackColor := uiTheme[2]
    
    ; Add border styling
    CardSettingsGUI.Add("Text", "x0 y0 w1 h220 +Background" uiTheme[3])     ; Left
    CardSettingsGUI.Add("Text", "x389 y0 w1 h220 +Background" uiTheme[3])   ; Right
    CardSettingsGUI.Add("Text", "x0 y219 w390 h1 +Background" uiTheme[3])   ; Bottom
    
    ; Add title and explanation
    CardSettingsGUI.SetFont("s12 Bold c" uiTheme[1], "Verdana")
    CardSettingsGUI.Add("Text", "x20 y10 w350 c" uiTheme[1], "Legend Card Priority Settings")
    
    CardSettingsGUI.SetFont("s9 c" uiTheme[1], "Verdana")
    CardSettingsGUI.Add("Text", "x20 y40 w350 c" uiTheme[1], "Select starter cards in order of preference.")
    CardSettingsGUI.Add("Text", "x20 y60 w350 c" uiTheme[1], "Macro will pick the highest priority card available.")
    
    ; Card priority selections
    CardSettingsGUI.Add("GroupBox", "x20 y85 w330 h120 c" uiTheme[1], "Card Priority Order")
    
    ; Create dropdown lists 
    CardSettingsGUI.Add("Text", "x40 y110 w30 h20 c" uiTheme[1], "1st:")
    settingsPri1 := CardSettingsGUI.Add("DropDownList", "x70 y107 w100 h180", ["Thrice", "Champion", "Revitalize", "Exploding", "Quake", "Immunity"])
    
    CardSettingsGUI.Add("Text", "x205 y110 w30 h20 c" uiTheme[1], "2nd:")
    settingsPri2 := CardSettingsGUI.Add("DropDownList", "x235 y107 w100 h180", ["Thrice", "Champion", "Revitalize", "Exploding", "Quake", "Immunity"])
    
    CardSettingsGUI.Add("Text", "x40 y145 w30 h20 c" uiTheme[1], "3rd:")
    settingsPri3 := CardSettingsGUI.Add("DropDownList", "x70 y142 w100 h180", ["Thrice", "Champion", "Revitalize", "Exploding", "Quake", "Immunity"])
    
    CardSettingsGUI.Add("Text", "x205 y145 w30 h20 c" uiTheme[1], "4th:")
    settingsPri4 := CardSettingsGUI.Add("DropDownList", "x235 y142 w100 h180", ["Thrice", "Champion", "Revitalize", "Exploding", "Quake", "Immunity"])
    
    ; Load saved priorities from file
    savedPriorities := ["Thrice", "Champion", "Revitalize", "Exploding"]  ; Default values
    
    if FileExist("Settings\CardPriorities.txt") {
        fileContent := FileRead("Settings\CardPriorities.txt", "UTF-8")
        lines := StrSplit(fileContent, "`n")
        
        if (lines.Length >= 1 && lines[1] != "")
            savedPriorities[1] := lines[1]
        if (lines.Length >= 2 && lines[2] != "")
            savedPriorities[2] := lines[2]
        if (lines.Length >= 3 && lines[3] != "")
            savedPriorities[3] := lines[3]
        if (lines.Length >= 4 && lines[4] != "")
            savedPriorities[4] := lines[4]
    }
    
    ; Set the values in the dropdowns
    try {
        settingsPri1.Text := savedPriorities[1]
        settingsPri2.Text := savedPriorities[2]
        settingsPri3.Text := savedPriorities[3]
        settingsPri4.Text := savedPriorities[4]
    } catch {
        AddToLog("Warning: Failed to set dropdown values from saved priorities")
        
        ; Fallback to Choose
        settingsPri1.Choose(GetIndexForValue(settingsPri1, savedPriorities[1]))
        settingsPri2.Choose(GetIndexForValue(settingsPri2, savedPriorities[2]))
        settingsPri3.Choose(GetIndexForValue(settingsPri3, savedPriorities[3]))
        settingsPri4.Choose(GetIndexForValue(settingsPri4, savedPriorities[4]))
    }
    
    ; Save button with dedicated function - smaller size
    SaveBtn := CardSettingsGUI.Add("Button", "x150 y175 w90 h25", "Save")
    SaveBtn.OnEvent("Click", SaveCardPriorities)
    
    ; Show the GUI - smaller size
    CardSettingsGUI.Show("w390 h240")
}

aaMainUI.SetFont("s10 c" uiTheme[1])

OpenGuide(*) {
    GuideGUI := Gui("+AlwaysOnTop")
    GuideGUI.SetFont("s10 bold", "Segoe UI")
    GuideGUI.Title := "Anime Vanguards Guide"

    GuideGUI.BackColor := "0c000a"
    GuideGUI.MarginX := 20
    GuideGUI.MarginY := 20

    ; Add Guide content
    GuideGUI.SetFont("s16 bold", "Segoe UI")

    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "- Roblox Settings -")
    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\Clicktomove.png")
    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\graphics1.png")

    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "- Anime Vanguard Settings -")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Auto Skip Waves: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Show Max Range On Placement: Off")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Show Multipliers On Hover: Off")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Select Units On Placement: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Low Detail: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Disable Visual Effects: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Disable Damage Indicators: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Disable Enemy Tag: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Disable Camera Shake: On")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "UI Scale: 1.0")
    

    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "- Custom Mode + Placement -")
    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Load into your desired map, setup unit placements, and start the macro")
    GuideGUI.Show("w800")
}

aaMainUI.SetFont("s12 Bold c" uiTheme[1])
global settingsBtn := aaMainUI.Add("Button", "x1160 y0 w90 h30", "Settings")
settingsBtn.OnEvent("Click", ShowSettingsGUI)
global guideBtn := aaMainUI.Add("Button", "x1060 y0 w90 h30", "Guide")
guideBtn.OnEvent("Click", OpenGuide)

placementSaveBtn := aaMainUI.Add("Button", "x807 y471 w80 h20", "Save")
placementSaveBtn.OnEvent("Click", SaveSettings)
aaMainUI.SetFont("s9")
global MatchMaking := aaMainUI.Add("Checkbox", "x1143 y476 cffffff Checked", "Matchmaking")
global NextLevelBox := aaMainUI.Add("Checkbox", "x900 y451 cffffff Checked", "Next Level")
global ReturnLobbyBox := aaMainUI.Add("Checkbox", "x1015 y451 cffffff Checked", "Return To Lobby")
global UpgradeDuringPlacementBox := aaMainUI.Add("Checkbox", "x1150 y476 cffffff Checked", "Upgrade During Placement") ; x1150 y451
global UINavToggle := aaMainUI.Add("CheckBox", "x900 y476 cffffff Checked", "UI Navigation")
global AutoAbilityBox := aaMainUI.Add("CheckBox", "x1040 y476 cffffff Checked", "Auto Ability")
global PriorityUpgrade := aaMainUI.Add("CheckBox", "x900 y476 cffffff", "Priority Upgrade")
PlacementPatternText := aaMainUI.Add("Text", "x1032 y390 w115 h20", "Placement Type")
global PlacementPatternDropdown := aaMainUI.Add("DropDownList", "x1035 y410 w100 h180 Choose2 +Center", ["Circle", "Custom", "Grid", "Random"])
PlaceSpeedText := aaMainUI.Add("Text", "x1193 y390 w115 h20", "Placement Speed")
global PlaceSpeed := aaMainUI.Add("DropDownList", "x1205 y410 w100 h180 Choose1 +Center", ["Super Fast (1s)", "Fast (1.5s)", "Default (2s)", "Slow (2.5s)", "Very Slow (3s)", "Toaster (4s)"])
;PlaceSpeed.OnEvent('Change', (*) => changePlacementSpeed())

PlacementSelectionText := aaMainUI.Add("Text", "x857 y390 w130 h20", "Placement Settings")
PlacementSelection := aaMainUI.Add("DropDownList", "x865 y410 w100 h180 Choose1 +Center", ["Normal"])
placementSaveText := aaMainUI.Add("Text", "x807 y451 w80 h20", "Save Config")

Hotkeytext := aaMainUI.Add("Text", "x807 y35 w530 h30", "To change keybinds click top right settings, Below are default hotkey settings ")
Hotkeytext2 := aaMainUI.Add("Text", "x807 y50 w530 h30", "F1:Reposition roblox window|F2:Start Macro|F3:Stop Macro|F4:Pause Macro")
GithubButton := aaMainUI.Add("Picture", "x30 y640 w40 h40 +BackgroundTrans cffffff", GithubImage)
DiscordButton := aaMainUI.Add("Picture", "x112 y645 w60 h34 +BackgroundTrans cffffff", DiscordImage)

customPlacementText := aaMainUI.Add("Text", "x200 y642 w120 h20 +Left", "Set Placements")
customPlacementButton := aaMainUI.Add("Button", "x210 y662 w80 h20", "Set")
customPlacementButton.OnEvent("Click", (*) => StartCoordCapture())

customPlacementClearText := aaMainUI.Add("Text", "x345 y642 w120 h20 +Left", "Clear Placements")
customPlacementClearButton := aaMainUI.Add("Button", "x360 y662 w80 h20", "Clear")
customPlacementClearButton.OnEvent("Click", (*) => DeleteSavedCoords())

fixCameraText := aaMainUI.Add("Text", "x520 y642 w120 h20 +Left", "Fix Setup")
fixCameraButton := aaMainUI.Add("Button", "x510 y662 w80 h20", "Setup")
fixCameraButton.OnEvent("Click", (*) => BasicSetup())

CardSettingsText := aaMainUI.Add("Text", "x682 y642 w100 h20 +Left", "Card Priority")
global CardSettingsBtn := aaMainUI.Add("Button", "x685 y662 w80 h20", "Edit Cards")
CardSettingsBtn.OnEvent("Click", (*) => OpenPriorityPicker())

GithubButton.OnEvent("Click", (*) => OpenGithub())
DiscordButton.OnEvent("Click", (*) => OpenDiscord())

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT
global modeSelectionGroup := aaMainUI.Add("GroupBox", "x808 y38 w500 h45 Background" uiTheme[2], "Mode Select")
aaMainUI.SetFont("s10 c" uiTheme[6])
global ModeDropdown := aaMainUI.Add("DropDownList", "x818 y53 w140 h180 Choose0 +Center", ["Story", "Legend", "Portal","Raid", "Custom"])
global StoryDropdown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Planet Namek", "Sand Village", "Double Dungeon", "Shibuya Station", "Underground Church", "Spirit Society"])
global StoryActDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinity"])
global LegendDropDown := aaMainUI.Add("DropDownlist", "x968 y53 w150 h180 Choose0 +Center", ["Sand Village", "Double Dungeon", "Shibuya Aftermath", "Golden Castle", "Kuinshi Palace"])
global LegendActDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3"])
global RaidDropdown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Spider Forest", "Track Of World"])
global RaidActDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5"])
global PortalDropdown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Winter Portal"])
global PortalMapDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Namek", "Shibuya"])
global ConfirmButton := aaMainUI.Add("Button", "x1218 y53 w80 h25", "Confirm")

UINavToggle.Visible := false
StoryDropdown.Visible := false
StoryActDropdown.Visible := false
LegendDropDown.Visible := false
LegendActDropdown.Visible := false
RaidDropdown.Visible := false
RaidActDropdown.Visible := false
PortalDropdown.Visible := false
PortalMapDropdown.Visible := false
MatchMaking.Visible := false
ReturnLobbyBox.Visible := false
NextLevelBox.Visible := false
Hotkeytext.Visible := false
Hotkeytext2.Visible := false
ModeDropdown.OnEvent("Change", OnModeChange)
StoryDropdown.OnEvent("Change", OnStoryChange)
LegendDropDown.OnEvent("Change", OnLegendChange)
RaidDropdown.OnEvent("Change", OnRaidChange)
ConfirmButton.OnEvent("Click", OnConfirmClick)
;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI
;------UNIT CONFIGURATION------UNIT CONFIGURATION------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/

AddUnitCard(aaMainUI, index, x, y) {
    unit := {}
 
    unit.Background := aaMainUI.Add("Text", Format("x{} y{} w550 h45 +Background{}", x, y, uiTheme[4]))
    unit.BorderTop := aaMainUI.Add("Text", Format("x{} y{} w550 h2 +Background{}", x, y, uiTheme[3]))
    unit.BorderBottom := aaMainUI.Add("Text", Format("x{} y{} w552 h2 +Background{}", x, y+45, uiTheme[3]))
    unit.BorderLeft := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x, y, uiTheme[3]))
    unit.BorderRight := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+550, y, uiTheme[3]))
    unit.BorderRight := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+250, y, uiTheme[3]))
    aaMainUI.SetFont("s11 Bold c" uiTheme[1])
    unit.Title := aaMainUI.Add("Text", Format("x{} y{} w60 h25 +BackgroundTrans", x+30, y+18), "Unit " index)

    unit.Title := aaMainUI.Add("Text", Format("x{} y{} w250 h25 +BackgroundTrans", x+285, y+18), "Upgrade During Placement")

    aaMainUI.SetFont("s9 c" uiTheme[1])
    unit.PlacementText := aaMainUI.Add("Text", Format("x{} y{} w70 h20 +BackgroundTrans", x+100, y+2), "Placement")
    unit.PriorityText := aaMainUI.Add("Text", Format("x{} y{} w60 h20 BackgroundTrans", x+183, y+2), "Priority")
    
    UnitData.Push(unit)
    return unit
}

;Create Unit slot
y_start := 85
y_spacing := 50
Loop 6 {
    AddUnitCard(aaMainUI, A_Index, 808, y_start + ((A_Index-1)*y_spacing))
}

enabled1 := aaMainUI.Add("CheckBox", "x818 y105 w15 h15", "")
enabled2 := aaMainUI.Add("CheckBox", "x818 y155 w15 h15", "")
enabled3 := aaMainUI.Add("CheckBox", "x818 y205 w15 h15", "")
enabled4 := aaMainUI.Add("CheckBox", "x818 y255 w15 h15", "")
enabled5 := aaMainUI.Add("CheckBox", "x818 y305 w15 h15", "")
enabled6 := aaMainUI.Add("CheckBox", "x818 y355 w15 h15", "")

upgradeEnabled1 := aaMainUI.Add("CheckBox", "x1070 y105 w15 h15", "")
upgradeEnabled2 := aaMainUI.Add("CheckBox", "x1070 y155 w15 h15", "")
upgradeEnabled3 := aaMainUI.Add("CheckBox", "x1070 y205 w15 h15", "")
upgradeEnabled4 := aaMainUI.Add("CheckBox", "x1070 y255 w15 h15", "")
upgradeEnabled5 := aaMainUI.Add("CheckBox", "x1070 y305 w15 h15", "")
upgradeEnabled6 := aaMainUI.Add("CheckBox", "x1070 y355 w15 h15", "")

aaMainUI.SetFont("s8 c" uiTheme[6])

; Mode selection dropdown
PlacementSelection.OnEvent("Change", ToggleMode)

; Placement dropdowns
Placement1 := aaMainUI.Add("DropDownList", "x908 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement2 := aaMainUI.Add("DropDownList", "x908 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement3 := aaMainUI.Add("DropDownList", "x908 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement4 := aaMainUI.Add("DropDownList", "x908 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement5 := aaMainUI.Add("DropDownList", "x908 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement6 := aaMainUI.Add("DropDownList", "x908 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

Priority1 := aaMainUI.Add("DropDownList", "x990 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority2 := aaMainUI.Add("DropDownList", "x990 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority3 := aaMainUI.Add("DropDownList", "x990 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority4 := aaMainUI.Add("DropDownList", "x990 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority5 := aaMainUI.Add("DropDownList", "x990 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority6 := aaMainUI.Add("DropDownList", "x990 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

ChallengePlacement1 := aaMainUI.Add("DropDownList", "x908 y105 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePlacement2 := aaMainUI.Add("DropDownList", "x908 y155 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePlacement3 := aaMainUI.Add("DropDownList", "x908 y205 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePlacement4 := aaMainUI.Add("DropDownList", "x908 y255 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePlacement5 := aaMainUI.Add("DropDownList", "x908 y305 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePlacement6 := aaMainUI.Add("DropDownList", "x908 y355 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])

ChallengePriority1 := aaMainUI.Add("DropDownList", "x990 y105 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePriority2 := aaMainUI.Add("DropDownList", "x990 y155 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePriority3 := aaMainUI.Add("DropDownList", "x990 y205 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePriority4 := aaMainUI.Add("DropDownList", "x990 y255 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePriority5 := aaMainUI.Add("DropDownList", "x990 y305 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])
ChallengePriority6 := aaMainUI.Add("DropDownList", "x990 y355 w60 h180 Choose1 +Center Hidden", ["1","2","3","4","5","6"])

ToggleMode(*) {
    mode := PlacementSelection.Text
    isChallenge := (mode = "Challenge")
    Loop 6 {
        Placement%A_Index%.Visible := !isChallenge
        Priority%A_Index%.Visible := !isChallenge
        ChallengePlacement%A_Index%.Visible := isChallenge
        ChallengePriority%A_Index%.Visible := isChallenge
    }
}
readInSettings()
aaMainUI.Show("w1366 h700")
WinMove(0, 0,,, "ahk_id " aaMainUIHwnd)
forceRobloxSize()  ; Initial force size and position
SetTimer(checkRobloxSize, 600000)  ; Check every 10 minutes
;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION
;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS

;Process text
AddToLog(current) { 
    global process1, process2, process3, process4, process5, process6, process7, currentOutputFile, lastlog

    ; Remove arrow from all lines first
    process7.Value := StrReplace(process6.Value, "➤ ", "")
    process6.Value := StrReplace(process5.Value, "➤ ", "")
    process5.Value := StrReplace(process4.Value, "➤ ", "")
    process4.Value := StrReplace(process3.Value, "➤ ", "")
    process3.Value := StrReplace(process2.Value, "➤ ", "")
    process2.Value := StrReplace(process1.Value, "➤ ", "")
    
    ; Add arrow only to newest process
    process1.Value := "➤ " . current
    
    elapsedTime := getElapsedTime()
    Sleep(50)
    FileAppend(current . " " . elapsedTime . "`n", currentOutputFile)

    ; Add webhook logging
    lastlog := current
    if FileExist("Settings\SendActivityLogs.txt") {
        SendActivityLogsStatus := FileRead("Settings\SendActivityLogs.txt", "UTF-8")
        if (SendActivityLogsStatus = "1") {
            WebhookLog()
        }
    }
}

;Timer
getElapsedTime() {
    global StartTime
    ElapsedTime := A_TickCount - StartTime
    Minutes := Mod(ElapsedTime // 60000, 60)  
    Seconds := Mod(ElapsedTime // 1000, 60)
    return Format("{:02}:{:02}", Minutes, Seconds)
}

;Basically the code to move roblox, below

sizeDown() {
    global rblxID
    
    if !WinExist(rblxID)
        return

    WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
    
    ; Exit fullscreen if needed
    if (OutWidth >= A_ScreenWidth && OutHeight >= A_ScreenHeight) {
        Send "{F11}"
        Sleep(100)
    }

    ; Force the window size and retry if needed
    Loop 3 {
        WinMove(X, Y, targetWidth, targetHeight, rblxID)
        Sleep(100)
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth == targetWidth && OutHeight == targetHeight)
            break
    }
}

moveRobloxWindow() {
    global aaMainUIHwnd, offsetX, offsetY, rblxID
    
    if !WinExist(rblxID) {
        AddToLog("Waiting for Roblox window...")
        return
    }

    ; First ensure correct size
    sizeDown()
    
    ; Then move relative to main UI
    WinGetPos(&x, &y, &w, &h, aaMainUIHwnd)
    WinMove(x + offsetX, y + offsetY,,, rblxID)
    WinActivate(rblxID)
}

forceRobloxSize() {
    global rblxID
    
    if !WinExist(rblxID) {
        checkCount := 0
        While !WinExist(rblxID) {
            Sleep(5000)
            if(checkCount >= 5) {
                AddToLog("Attempting to locate the Roblox window")
            } 
            checkCount += 1
            if (checkCount > 12) { ; Give up after 1 minute
                AddToLog("Could not find Roblox window")
                return
            }
        }
        AddToLog("Found Roblox window")
    }

    WinActivate(rblxID)
    sizeDown()
    moveRobloxWindow()
}
; Function to periodically check window size
checkRobloxSize() {
    global rblxID
    if WinExist(rblxID) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth != targetWidth || OutHeight != targetHeight) {
            sizeDown()
            moveRobloxWindow()
        }
    }
}
;Basically the code to move roblox, Above

OnSettingsGuiClose(*) {
    global settingsGuiOpen, SettingsGUI
    settingsGuiOpen := false
    if SettingsGUI {
        SettingsGUI.Destroy()
        SettingsGUI := ""  ; Clear the GUI reference
    }
}

checkSizeTimer() {
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, "ahk_exe RobloxPlayerBeta.exe")
        if (OutWidth != 816 || OutHeight != 638) {
            AddToLog("Fixing Roblox window size")
            moveRobloxWindow()
        }
    }
}

StartCoordCapture() {
    global waitingForClick
    waitingForClick := true
    SetTimer UpdateTooltip, 50  ; Update tooltip position every 50ms
}

UpdateTooltip() {
    global waitingForClick
    if waitingForClick {
        MouseGetPos &x, &y
        ToolTip "Click anywhere to save coordinates...", x + 10, y + 10  ; Offset tooltip slightly
    } else {
        ToolTip()  ; Hide tooltip when not waiting
        SetTimer UpdateTooltip, 0  ; Stop the timer
    }
}

~LButton::
{
    global waitingForClick, savedCoords
    if waitingForClick {
        ; Wait for the button press and get the position when the mouse button is clicked
        MouseGetPos &x, &y
        waitingForClick := false
        SetTimer UpdateTooltip, 0  ; Stop updating tooltip immediately

        if !IsSet(savedCoords)  ; Ensure savedCoords is initialized
            savedCoords := []
        savedCoords.Push({x: x, y: y - 25})  ; Store as an object

        ToolTip("Coordinates added: " x ", " y, x + 10, y + 10)  ; Show tooltip
        AddToLog("📌 Saved Coordinates → X: " x ", Y: " y)

        ; Ensure tooltip disappears properly by resetting and manually clearing it
        SetTimer ClearToolTip, -1200
    }
}

ClearToolTip() {
    ToolTip()  ; Properly clear tooltip
    Sleep 100  ; Small delay to ensure clearing happens across all systems
    ToolTip()  ; Redundant clear to catch edge cases
}

DeleteSavedCoords() {
    global savedCoords

    if (IsSet(savedCoords) && savedCoords.Length > 0) {
        savedCoords := []  ; Clear the saved coordinates list
        AddToLog("🗑️ All saved coordinates have been cleared.")
    } else {
        AddToLog("⚠️ No saved coordinates to clear.")
    }
}

; Function to handle the Close event for the card settings GUI
OnCardSettingsClose(*) {
    global cardSettingsGuiOpen, CardSettingsGUI
    
    cardSettingsGuiOpen := false
    if CardSettingsGUI {
        CardSettingsGUI.Destroy()
        CardSettingsGUI := ""
    }
}