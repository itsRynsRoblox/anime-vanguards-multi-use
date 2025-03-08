#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

SavePsSettings(*) {
    AddToLog("Saving Private Server")
    
    if FileExist("Settings\PrivateServer.txt")
        FileDelete("Settings\PrivateServer.txt")
    
    FileAppend(PsLinkBox.Value, "Settings\PrivateServer.txt", "UTF-8")
}

SaveUINavSettings(*) {
    AddToLog("Saving UI Navigation Key")
    
    if FileExist("Settings\UINavigation.txt")
        FileDelete("Settings\UINavigation.txt")
    
    FileAppend(UINavBox.Value, "Settings\UINavigation.txt", "UTF-8")
}

;Opens discord Link
OpenDiscordLink() {
    Run("https://discord.gg/mistdomain")
 }
 
 ;Minimizes the UI
 minimizeUI(*){
    aaMainUI.Minimize()
 }
 
 Destroy(*){
    aaMainUI.Destroy()
    ExitApp
 }

 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
 ;Gets the current time
 getCurrentTime() {
     currentHour := A_Hour
     currentMinute := A_Min
     currentSecond := A_Sec
 
     return Format("{:d}h.{:02}m.{:02}s", currentHour, currentMinute, currentSecond)
 }



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text
    
    ; Hide all dropdowns first
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    PortalDropDown.Visible := false
    PortalMapDropdown.Visible := false
    
    if (selected = "Story") {
        if (!storyEnabled) {
            AddToLog("⚠️ Story isn't ready yet, Custom is available for now.")
            return
        }
        StoryDropdown.Visible := true
        StoryActDropdown.Visible := true
        mode := "Story"
    } else if (selected = "Raid") {
        if (!raidEnabled) {
            AddToLog("⚠️ Raid isn't ready yet, Custom is available for now.")
            return
        }
        RaidDropdown.Visible := true
        RaidActDropdown.Visible := true
        mode := "Raid"
    } else if (selected = "Legend") {
        LegendDropDown.Visible := true
        LegendActDropdown.Visible := true
        mode := "Legend"
    } else if (selected = "Portal") {
        if (!portalEnabled) {
            AddToLog("⚠️ Portal isn't ready yet.")
            return
        }
        PortalDropDown.Visible := true
        PortalMapDropdown.Visible := true
        mode := "Portal"
    } else if (ModeDropdown.Text = "Custom") {
        global savedCoords
        if (!IsSet(savedCoords) || savedCoords.Length = 0) {
            AddToLog("❌ No saved coordinates! Please capture some points first.")
            return
        }
        AddToLog("Selected Custom")
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnLegendChange(*) {
    if (LegendDropDown.Text != "") {
        LegendActDropdown.Visible := true
    } else {
        LegendActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text " - " StoryActDropdown.Text)
        ReturnLobbyBox.Visible := (StoryActDropdown.Text = "Infinity")
        NextLevelBox.Visible := (StoryActDropdown.Text != "Infinity")
    }
    ; For Raid mode, check if both Raid and RaidAct are selected
    else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "" || RaidActDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        AddToLog("Selected " RaidDropdown.Text " - " RaidActDropdown.Text)
        ReturnLobbyBox.Visible := true
    }
    ; For Portal, check if both Portal and Join Type are selected
    else if (ModeDropdown.Text = "Portal") {
    if (PortalDropdown.Text = "" || PortalMapDropdown.Text = "") {
        AddToLog("Please select both Portal and Portal Map before confirming")
        return
    }
    AddToLog("Selected " PortalDropdown.Text " - " PortalMapDropdown.Text)
    } 
    else if (ModeDropdown.Text = "Custom") {
        AddToLog("Selected " ModeDropdown.Text)
        global savedCoords
        if (!IsSet(savedCoords) || savedCoords.Length = 0) {
            AddToLog("❌ No saved coordinates! Please capture some points first.")
            return
        }
    } else {
        AddToLog("Selected " ModeDropdown.Text " mode")
        MatchMaking.Visible := false
        ReturnLobbyBox.Visible := false
    }

    AddToLog("Don't forget to enable Click to Move and UI Navigation!")

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendActDropdown.Visible := false
    LegendDropdown.Visible := false
    PortalDropdown.Visible := false
    PortalMapDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

TogglePriorityDropdowns(*) {
    global PriorityUpgrade, priority1, priority2, priority3, priority4, priority5, priority6
    shouldShow := PriorityUpgrade.Value

    priority1.Visible := shouldShow
    priority2.Visible := shouldShow
    priority3.Visible := shouldShow
    priority4.Visible := shouldShow
    priority5.Visible := shouldShow
    priority6.Visible := shouldShow

    for unit in UnitData {
        unit.PriorityText.Visible := shouldShow
    }
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

FindAndClickColor(targetColor := 0xFAFF4D, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Color found and clicked at: X" foundX " Y" foundY)
        return true

    }
}

FindAndClickImage(imagePath, searchArea := [0, 0, A_ScreenWidth, A_ScreenHeight]) {

    AddToLog(imagePath)

    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the image search
    if (ImageSearch(&foundX, &foundY, x1, y1, x2, y2, imagePath)) {
        ; Image found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Image found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

FindAndClickText(textToFind, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the text search
    if (FindText(&foundX, &foundY, x1, y1, x2, y2, textToFind)) {
        ; Text found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Text found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

CheckForBaseHealth() {
    searchArea := [254, 45, 295, 8]
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, 0x55FE7F, 2)) {
        Sleep (100)
        return true
    }

    return false
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/6DWgB9XMTV")
}

; Helper function to get dropdown index for a value
GetIndexForValue(dropDown, value) {
    try {
        loop dropDown.Items.Length {
            if (dropDown.Items[A_Index] = value)
                return A_Index
        }
    } catch {
        ; If we can't get items, return 1
    }
    
    ; Default to 1 if not found
    return 1
}

; Helper function to select dropdown item by text
ChooseDropdownItemByText(dropDown, text) {
    items := dropDown.GetCount()
    Loop items {
        if (dropDown.GetText(A_Index) = text) {
            dropDown.Choose(A_Index)
            return true
        }
    }
    return false
}
