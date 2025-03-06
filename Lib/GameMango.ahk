#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

LoadKeybindSettings()  ; Load saved keybinds
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => MonitorStage())
;Hotkey(F4Key, (*) => TogglePause())


StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}

PlacingUnits(untilSuccessful := true) {
    global successfulCoordinates
    successfulCoordinates := []
    placedCounts := Map()  

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        AddToLog("No units enabled - skipping to monitoring")
        return MonitorStage()
    }

    placementPoints := PlacementPatternDropdown.Text = "Custom" ? UseCustomPoints()
                   : PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() 
                   : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() 
                   : PlacementPatternDropdown.Text = "Spiral" ? GenerateSpiralPoints() 
                   : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() 
                   : GenerateRandomPoints()

    ; Go through each slot
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value

        ; Get number of placements wanted for this slot
        placements := "placement" slotNum
        placements := %placements%
        placements := Integer(placements.Text)

        ; Initialize count if not exists
        if !placedCounts.Has(slotNum)
            placedCounts[slotNum] := 0

        ; If enabled, place all units for this slot
        if (enabled && placements > 0) {
            AddToLog("Placing Unit " slotNum " (0/" placements ")")
            
            for point in placementPoints {
                ; Skip if this coordinate was already used successfully
                alreadyUsed := false
                for coord in successfulCoordinates {
                    if (coord.x = point.x && coord.y = point.y) {
                        alreadyUsed := true
                        break
                    }
                }
                if (alreadyUsed)
                    continue

                ; If untilSuccessful is false, try once and move on
                if (!untilSuccessful) {
                    if PlaceUnit(point.x, point.y, slotNum) {
                        successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                        placedCounts[slotNum] += 1
                        AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                        CheckAbility()
                        FixClick(700, 560) ; Move Click
                        if (UpgradeDuringPlacementBox.Value) {
                            AttemptUpgrade()
                        }
                    }
                    if (UpgradeDuringPlacementBox.Value) {
                        AttemptUpgrade()
                    }
                    continue
                }

                ; If untilSuccessful is true, keep trying the same point until it works
                while (placedCounts[slotNum] < placements) {
                    if PlaceUnit(point.x, point.y, slotNum) {
                        successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                        placedCounts[slotNum] += 1
                        AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                        CheckAbility()
                        FixClick(700, 560) ; Move Click
                        if (UpgradeDuringPlacementBox.Value) {
                            AttemptUpgrade()
                        }
                        break ; Move to the next placement spot
                    }

                    if (UpgradeDuringPlacementBox.Value) {
                        AttemptUpgrade()
                    }

                    if CheckForRewards()
                        return MonitorStage()

                    Reconnect()
                    CheckEndAndRoute()
                    Sleep(500) ; Prevents spamming clicks too fast
                }
            }
        }
    }

    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}

AttemptUpgrade() {
    global successfulCoordinates, PriorityUpgrade
    global priority1, priority2, priority3, priority4, priority5, priority6

    if (successfulCoordinates.Length = 0) {
        return ; No units placed yet
    }

    AddToLog("Attempting to upgrade placed units...")

    if (PriorityUpgrade.Value) {
        if (debugMessages) {
            AddToLog("Using priority-based upgrading")
        }
        
        ; Loop through priority levels (1-6) and upgrade all matching units
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            upgradedThisRound := false

            for index, coord in successfulCoordinates.Clone() { ; Clone to allow removal
                ; Get the priority value for this unit's slot
                priority := "priority" coord.slot
                priority := %priority%

                if (priority.Text = priorityNum) {
                    UpgradeUnit(coord.x, coord.y)

                    if CheckForRewards() {
                        AddToLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        return MonitorStage()
                    }

                    if MaxUpgrade() {
                        AddToLog("Max upgrade reached for Unit " coord.slot)
                        successfulCoordinates.RemoveAt(index)
                        FixClick(325, 185) ; Close upgrade menu
                        continue
                    }

                    Sleep(200)
                    CheckAbility()
                    FixClick(700, 560) ; Move Click
                    Reconnect()
                    CheckEndAndRoute()

                    upgradedThisRound := true
                }
            }

            if upgradedThisRound {
                Sleep(300) ; Add a slight delay between batches
            }
        }
    } else {
        ; Normal (non-priority) upgrading - upgrade all available units
        for index, coord in successfulCoordinates.Clone() {
            UpgradeUnit(coord.x, coord.y)

            if CheckForRewards() {
                AddToLog("Stage ended during upgrades, proceeding to results")
                successfulCoordinates := []
                return MonitorStage()
            }

            if MaxUpgrade() {
                AddToLog("Max upgrade reached for Unit " coord.slot)
                successfulCoordinates.RemoveAt(index)
                FixClick(325, 185) ; Close upgrade menu
                continue
            }

            Sleep(200)
            CheckAbility()
            FixClick(700, 560) ; Move Click
            Reconnect()
            CheckEndAndRoute()
        }
    }
}

CheckForRewards() {
    ; Check for rewards text
    if (ok := FindText(&X, &Y, 245, 341, 320, 357, 0, 0, Rewards)) {
        return true
    }
    return false
}


UpgradeUnits() {
    global successfulCoordinates, PriorityUpgrade, priority1, priority2, priority3, priority4, priority5, priority6

    totalUnits := Map()    
    upgradedCount := Map()  
    
    ; Initialize counters
    for coord in successfulCoordinates {
        if (!totalUnits.Has(coord.slot)) {
            totalUnits[coord.slot] := 0
            upgradedCount[coord.slot] := 0
        }
        totalUnits[coord.slot]++
    }

    AddToLog("Initiating Unit Upgrades...")

    if (PriorityUpgrade.Value) {
        AddToLog("Using priority upgrade system")
        
        ; Go through each priority level (1-6)
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            ; Find which slot has this priority number
            for slot in [1, 2, 3, 4, 5, 6] {
                priority := "priority" slot
                priority := %priority%
                if (priority.Text = priorityNum) {
                    ; Skip if no units in this slot
                    hasUnitsInSlot := false
                    for coord in successfulCoordinates {
                        if (coord.slot = slot) {
                            hasUnitsInSlot := true
                            break
                        }
                    }
                    
                    if (!hasUnitsInSlot) {
                        continue
                    }

                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    
                    ; Keep upgrading current slot until all its units are maxed
                    while true {
                        slotDone := true
                        
                        for index, coord in successfulCoordinates {
                            if (coord.slot = slot) {
                                slotDone := false
                                UpgradeUnit(coord.x, coord.y)

                                if CheckForRewards() {
                                    AddToLog("Stage ended during upgrades, proceeding to results")
                                    successfulCoordinates := []
                                    MonitorStage()
                                    return
                                }

                                if MaxUpgrade() {
                                    upgradedCount[coord.slot]++
                                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                                    successfulCoordinates.RemoveAt(index)
                                    FixClick(325, 185) ;Close upg menu
                                    break
                                }

                                Sleep(200)
                                CheckAbility()
                                FixClick(700, 560) ; Move Click
                                Reconnect()
                                CheckEndAndRoute()
                            }
                        }
                        
                        if (slotDone || successfulCoordinates.Length = 0) {
                            AddToLog("Finished upgrades for priority " priorityNum)
                            break
                        }
                    }
                }
            }
        }
        
        AddToLog("Priority upgrading completed")
        return MonitorStage()
    } else {
        ; Normal upgrade (no priority)
        while true {
            if (successfulCoordinates.Length == 0) {
                AddToLog("All units maxed, proceeding to monitor stage")
                return MonitorStage()
            }

            for index, coord in successfulCoordinates {
                UpgradeUnit(coord.x, coord.y)

                if CheckForRewards() {
                    AddToLog("Stage ended during upgrades, proceeding to results")
                    successfulCoordinates := []
                    MonitorStage()
                    return
                }

                if MaxUpgrade() {
                    upgradedCount[coord.slot]++
                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                    successfulCoordinates.RemoveAt(index)
                    FixClick(325, 185) ;Close upg menu
                    continue
                }

                Sleep(200)
                CheckAbility()
                FixClick(700, 560) ; Move Click
                Reconnect()
                CheckEndAndRoute()
            }
        }
    }
}

ChallengeMode() {    
    AddToLog("Starting Challenge Mode")
    ChallengeMovement()
    
    while !(ok:=FindText(&X, &Y, 27, 267, 132, 289, 0, 0, CreateMatch)) {
        ChallengeMovement()
    }

    ; Handle play mode selection
    PlayHere(false)
    RestartStage(false)
}

CustomMode() {
    AddToLog("Starting Custom Mode")
    RestartStageCustom()
}

StoryMode() {
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    StoryMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 27, 267, 132, 289, 0, 0, CreateMatch)) {
        StoryMovement()
    }

    AddToLog("Starting " currentStoryMap " - " currentStoryAct)

    if (UINavToggle.Value) {
        StartStory(currentStoryMap, currentStoryAct)
    } else {
        StartStoryNoUI(currentStoryMap, currentStoryAct)
    }

    ; Handle play mode selection
    PlayHere(true)
    RestartStage(false)
}

RaidMode() {
    global RaidDropdown, RaidActDropdown
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)
    RaidMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 27, 267, 132, 289, 0, 0, CreateMatch)) {
        RaidMovement()
    }

    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    if (UINavToggle.Value) {
        StartRaid(currentRaidMap, currentRaidAct)
    } else {
        StartRaidNoUI(currentRaidMap, currentRaidAct)
    }
    ; Handle play mode selection
    PlayHere(true)
    RestartStage(false)
}

MonitorEndScreen() {
    global mode, StoryDropdown, StoryActDropdown, ReturnLobbyBox, MatchMaking

    Loop {
        Sleep(3000)  
        
        FixClick(700, 560) ; Move Click
        FixClick(700, 560) ; Move Click

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 223, 339, 402, 389, 0, 0, EndScreen)) {
            AddToLog("Found Lobby Text - Current Mode: " mode)
            Sleep(2000)

            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (StoryActDropdown.Text != "Infinity") {
                    if (NextLevelBox.Value && lastResult = "win") {
                        AddToLog("Next level")
                        ClickUntilGone(0, 0, 205, 187, 418, 259, VictoryText, 150, 200)
                    } else {
                        AddToLog("Replay level")
                        ClickUntilGone(0, 0, 205, 187, 418, 259, FailedText, -4, 200)
                    }
                } else {
                    AddToLog("Story Infinity replay")
                    ClickUntilGone(0, 0, 205, 187, 418, 259, FailedText, -4, 200)
                }
                return RestartStage(true)
            }
            else if (mode = "Raid") {
                AddToLog("Handling Raid end")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby")
                    ClickUntilGone(0, 0, 125, 443, 680, 474, ReturnToLobby, 0, -35)
                    return CheckLobby()
                } else {
                    AddToLog("Replay raid")
                    ClickUntilGone(0, 0, 125, 443, 680, 474, ReturnToLobby, -150, -35)
                    return RestartStage(true)
                }
            }
            else {
                AddToLog("Handling end case")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby enabled")
                    ClickUntilGone(0, 0, 125, 443, 680, 474, ReturnToLobby, 0, -35)
                    return CheckLobby()
                } else {
                    AddToLog("Replaying")
                    ClickUntilGone(0, 0, 125, 443, 680, 474, ReturnToLobby, -150, -35)
                    return RestartStageCustom()
                }
            }
        }
        Reconnect()
    }
}


MonitorStage() {
    global Wins, loss, mode, StoryActDropdown

    lastClickTime := A_TickCount
    
    Loop {
        Sleep(1000)
        
        if (mode = "Story" && StoryActDropdown.Text = "Infinity") {
            timeElapsed := A_TickCount - lastClickTime
            if (timeElapsed >= 15000) {  ; 15 seconds
                FixClick(300, 400)  ; Move click
                lastClickTime := A_TickCount
            }
        }

        AddToLog("Checking win/loss status")
        stageEndTime := A_TickCount
        stageLength := FormatStageTime(stageEndTime - stageStartTime)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 253, 209, 380, 237, 0, 0, VictoryText)) {
            AddToLog("Victory detected - Stage Length: " stageLength)
            Wins += 1
            SendWebhookWithTime(true, stageLength)
            return MonitorEndScreen()
        }
        else if (ok := FindText(&X, &Y, 205, 195, 363, 222, 0, 0, DefeatText)) {
            AddToLog("Defeat detected - Stage Length: " stageLength)
            loss += 1
            SendWebhookWithTime(false, stageLength)
            return MonitorEndScreen()
        }

        Reconnect()
    }
}

StoryMovement() {
    Reconnect()
    FixClick(33, 315) ; click play
    Sleep 2500
    FixClick(365, 337) ; click teleport
    Sleep 1000
	FixClick(365, 337) ; click teleport
    Sleep 1000
	FixClick(365, 337) ; click teleport
    Sleep 2000


    SendInput ("{s up}")  
    Sleep 100  
    SendInput ("{s down}")
    Sleep 4500
    SendInput ("{s up}")
    KeyWait "s" ; Wait for "s" to be fully processed


    SendInput("{d up}") ; Ensure key is released
    Sleep 100
    SendInput ("{d down}")
    Sleep 4500
    SendInput ("{d up}")
    KeyWait "d" ; Wait for "d" to be fully processed
}

ChallengeMovement() {
    ; Click Teleport
    FixClick(75, 250)
    sleep (1000)

    ; Click Play/Portals
    FixClick(280, 280)
    sleep (1000)

    ; Click search
    FixClick(300, 178)
    Sleep(1500)
        
    ; Type portal name
    Send "Challenge"
    Sleep(1500)

    ; Click Portal
    FixClick(196, 234)
    Sleep 1000

    ; Click Play
    FixClick(240, 265)
    sleep (1000)
}

RaidMovement() {
    ; Click Teleport
    FixClick(75, 250)
    sleep (1000)

    ; Click Play/Portals
    FixClick(280, 280)
    sleep (1000)

    ; Click search
    FixClick(300, 178)
    Sleep(1500)
        
    ; Type portal name
    Send "Raid"
    Sleep(1500)

    ; Click Portal
    FixClick(196, 234)
    Sleep 1000

    ; Click Play
    FixClick(240, 265)
    sleep (1000)
}

StartStory(map, StoryActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    leftArrows := 7 ; Go Over To Story
    Loop leftArrows {
        SendInput("{Left}")
        Sleep(200)
    }

    downArrows := GetStoryDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    SendInput("{Right}") ; Go to act selection
    Sleep(1000)
    SendInput("{Right}")
    Sleep(1000)
    
    actArrows := GetStoryActDownArrows(StoryActDropdown) ; Act selection down arrows
    if (mode = "Story" && StoryActDropdown = "Infinity") {
        FixClick(284,433)
        Sleep 200
    }
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartStoryNoUI(map, StoryActDropdown) {
    FixClick(640, 70) ; Close Leaderboard
    Sleep(500)
    FixClick(80, 250) ; Create Match
    Sleep(100)
    if (mode = "Story" && StoryActDropdown = "Infinity") {
        FixClick(284,433)
        Sleep 200
    }
    storyClickCoords := GetStoryClickCoords(map) ; Coords for Story Map
    FixClick(storyClickCoords.x, storyClickCoords.y) ; Choose Story
    Sleep 500
    actClickCoords := GetStoryActClickCoords(StoryActDropdown) ; Coords for Story Act

    validActs := ["Act 5", "Act 6", "Infinity", "Paragon"]
    for act in validActs {
        if (StoryActDropdown = act) {
            FixClick(300, 240)
            Sleep(1000)
                ; Zoom back out smoothly
            Loop 20 {
                Send "{WheelDown}"
                Sleep 50
            }
            break
        }
    }
    FixClick(actClickCoords.x, actClickCoords.y) ; Choose Story Act
    if (StoryActDropdown = "Infinity") {
        FixClick(actClickCoords.x, actClickCoords.y) ; Choose Story Act again
    }
    Sleep 500
}

StartRaidNoUI(map, RaidActDropdown) {
    FixClick(640, 70) ; Close Leaderboard
    Sleep(500)
    raidClickCoords := GetRaidClickCoords(map) ; Coords for Raid Map
    FixClick(raidClickCoords.x, raidClickCoords.y) ; Choose Raid
    Sleep 500
    actClickCoords := GetRaidActClickCoords(RaidActDropdown) ; Coords for Raid
    FixClick(actClickCoords.x, actClickCoords.y) ; Choose Raid Act
    Sleep 500
}

StartChallenge() {
    FixClick(640, 70)
    Sleep(500)
}

StartRaid(map, RaidActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    leftArrows := 7 ; Go Over To Story
    Loop leftArrows {
        SendInput("{Left}")
        Sleep(200)
    }

    downArrows := GetRaidDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    SendInput("{Right}") ; Go to act selection
    Sleep(1000)
    SendInput("{Right}")
    Sleep(1000)
    
    actArrows := GetRaidActDownArrows=(RaidActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

PlayHere(clickConfirm := true) {
    if (clickConfirm) {
        FixClick(555, 446) ; Click Confirm
        Sleep (1000)
    }
    FixClick(90, 434) ; Click Start
    Sleep (300)
}

GetStoryDownArrows(map) {
    switch map {
        case "Planet Namak": return 0
        case "Sand Village": return 1
        case "Double Dungeon": return 2
        case "Shibuya Station": return 3
        case "Underground Church": return 4
        case "Spirit Society": return 5
    }
}

GetStoryActDownArrows(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return 1
        case "Act 2": return 2
        case "Act 3": return 3
        case "Act 4": return 4
        case "Act 5": return 5
        case "Act 6": return 6
        case "Infinity": return 7
        case "Paragon": return 8
    }
}

GetStoryClickCoords(map) {
    switch map {
        case "Planet Namak": return { x: 150, y: 190 }
        case "Sand Village": return { x: 150, y: 240 }
        case "Double Dungeon": return { x: 150, y: 290 }
        case "Shibuya Station": return { x: 150, y: 340 }
        case "Underground Church": return { x: 150, y: 390 }
        case "Spirit Society": return { x: 150, y: 420 }
    }
}

GetStoryActClickCoords(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return { x: 300, y: 240 }
        case "Act 2": return { x: 300, y: 295 }
        case "Act 3": return { x: 300, y: 350 }
        case "Act 4": return { x: 300, y: 405 }
        case "Act 5": return { x: 300, y: 240 }
        case "Act 6": return { x: 300, y: 295 }
        case "Infinity": return { x: 300, y: 350 }
        case "Paragon": return { x: 300, y: 405 }
    }
}

GetRaidClickCoords(map) {
    switch map {
        case "Spider Forest": return { x: 150, y: 190 }
        case "Edge of The World": return { x: 150, y: 240 }
    }
}

GetRaidActClickCoords(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return { x: 300, y: 240 }
        case "Act 2": return { x: 300, y: 295 }
        case "Act 3": return { x: 300, y: 350 }
        case "Act 4": return { x: 300, y: 405 }
        case "Act 5": return { x: 300, y: 240 }
    }
}

GetRaidDownArrows(map) {
    switch map {
        case "Spider Forest": return 0
        case "Edge of The World": return 1
    }
}

GetRaidActDownArrows(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return 0
        case "Act 2": return 1
        case "Act 3": return 2
        case "Act 4": return 3
        case "Act 5": return 4
    }
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100
    FixClick(400, 300)
    Sleep 100
    ; Zoom in smoothly
    Loop 12 {
        Send "{WheelUp}"
        Sleep 50
    }

    ; Look down
    Click
    MouseMove(400, 400)  ; Move mouse down to angle camera down
    
    ; Zoom back out smoothly
    Loop 20 {
        Send "{WheelDown}"
        Sleep 50
    }
    
    ; Move mouse back to center
    MouseMove(400, 300)
}

TpSpawn() {
    FixClick(22, 576) ;click settings
    Sleep 500
    FixClick(517, 210) ; Click Teleport To Spawn
    Sleep 500
    FixClick(22, 576) ;click settings to close
    Sleep 500
}

CloseChat() {
    if (ok := FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup(replay := false) {
    if (!replay) {
        SendInput("{Tab}") ; Closes Player leaderboard
        Sleep 300
        FixClick(564, 72) ; Closes Player leaderboard
        Sleep 300
        CloseChat()
        Sleep 1500
    }

    Sleep 1500
    if (!replay) {
        Zoom()
        Sleep 1500
        TpSpawn()
        Sleep (1500)
    }
    CheckForVoteScreen()
    Sleep 300
}

FixCamera() {

}

DetectMap() {
    AddToLog("Determining Movement Necessity on Map...")
    startTime := A_TickCount
    
    Loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
                AddToLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddToLog("Could not detect map after 5 minutes - proceeding without movement")
            return "no map found"
        }

        if (ModeDropdown.Text = "Story") {
            AddToLog("Map detected: " StoryDropdown.Text)
            return StoryDropdown.Text
        }

        if (ModeDropdown.Text = "Raid") {
            AddToLog("Map detected: " RaidDropdown.Text)
            return RaidDropdown.Text
        }

        mapPatterns := Map(
            "Planet Namak", PlanetNamek,
            "Shibuya", Shibuya

        )

        for mapName, pattern in mapPatterns { ;Shibuya : 294, 250, 331, 265
            if (ok := FindText(&X, &Y, 294, 250, 331, 265, 0, 0, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }

        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
        case "Planet Namak":
            MoveForPlanetNamek()   
    }
}

MoveForPlanetNamek() {
    Fixclick(586, 545, "Right")
    Sleep (6000)
}

RestartStage(seamless := false) {
    currentMap := DetectMap()
    
    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    if (!seamless) {
        BasicSetup(false)
        if (currentMap != "no map found") {
            HandleMapMovement(currentMap)
        }
    } else {
        BasicSetup(true)
        AddToLog("Game supports seamless replay, skipping most of setup")
    }

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits()
    
    ; Monitor stage progress
    MonitorStage()
}

RestartStageCustom() {
    ; Wait for loading
    CheckLoaded()
    
    ; Wait for game to actually start
    StartedGame()

    FixClick(400, 300) ; Click Card If Needed
    Sleep(500)

    CheckForVoteScreen()
    
    ; Begin unit placement and management
    PlacingUnits(true)
        
    ; Monitor stage progress
    MonitorStage()
}

Reconnect() {   
    ; Check for Disconnected Screen using FindText
    if (ok := FindText(&X, &Y, 330, 218, 474, 247, 0, 0, Disconnect)) {
        AddToLog("Lost Connection! Attempting To Reconnect To Private Server...")

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

        ; Reconnect to Ps
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddToLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=8304191830")  ; Public server if no PS file or empty
        }

        Sleep(300000)
        
        ; Restore window if it exists
        if WinExist(rblxID) {
            forceRobloxSize() 
            Sleep(1000)
        }
        
        ; Keep checking until we're back in
        loop {
            AddToLog("Reconnecting to Roblox...")
            Sleep(5000)
            
            ; Check if we're back in lobby
            if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode() ; Return to raids
            }
            else {
                ; If not in lobby, try reconnecting again
                Reconnect()
            }
        }
    }
}

PlaceUnit(x, y, slot := 1) {
    SendInput(slot)
    Sleep 50
    FixClick(x, y)
    Sleep 50
    SendInput("q")
    Sleep 500
    if UnitPlaced() {
        Sleep 15
        return true
    }
    return false
}

ClickUnit(x, y) {
    FixClick(x, y)
    Sleep 50
    return UnitPlaced()
}

MaxUpgrade() {
    Sleep 500
    ; Check for max text
    if (ok := FindText(&X, &Y, 146, 249, 252, 272, 0, 0, MaxText)) {
        return true
    }
    return false
}

UnitPlaced() {
    if (WaitForUpgradeText(PlacementSpeed())) { ; Wait up to 4.5 seconds for the upgrade text to appear
        AddToLog("Unit Placed Successfully")
        FixClick(325, 185) ; Close upgrade menu
        return true
    }
    return false
}

WaitForUpgradeText(timeout := 4500) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (FindText(&X, &Y, 147, 248, 228, 273, 0, 0, UpgradeText)) {
            return true
        }
        Sleep 100  ; Check every 100ms
    }
    return false  ; Timed out, upgrade text was not found
}

CheckAbility() {
    global AutoAbilityBox  ; Reference your checkbox
    
    ; Only check ability if checkbox is checked
    if (AutoAbilityBox.Value) {
        if (ok := FindText(&X, &Y, 294, 250, 331, 265, 0, 0, AbilityOff)) {
            FixClick(307, 222)  ; Turn ability on
            AddToLog("Auto Ability Enabled")
        }
    }
}

UpgradeUnit(x, y) {
    FixClick(x, y - 3)
    SendInput ("{T}")
    SendInput ("{T}")
    SendInput ("{T}")
}

CheckLobby() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
    AddToLog("Returned to lobby, restarting selected mode")
    return StartSelectedMode()
}

CheckLoaded() {
    loop {
        Sleep(1000)
    
        ; Check for stage info
        if (ok := FindText(&X, &Y, 707, 398, 778, 419, 0, 0, StageInfo)) {
            AddToLog("Successfully Loaded In")
            Sleep(1000)
            break
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    FixClick(400,340)
    FixClick(400,390)
    if (ModeDropdown.Text = "Story") {
        StoryMode()
    }
    else if (ModeDropdown.Text = "Custom") {
        CustomMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        RaidMode()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

CheckForVoteScreen() {
    if (ok:=FindText(&X, &Y, 365, 114, 443, 132, 0, 0, VoteScreen)) {
          AddToLog("Found Vote Screen")
          FixClick(365, 125)
          FixClick(365, 125)
          FixClick(365, 125)
          return true
    }
    return false
}

UseCustomPoints() {
    AddToLog("Using Custom")
    global savedCoords  ; Access the global saved coordinates
    points := []

    ; Directly use savedCoords without generating new points
    for coord in savedCoords {
        points.Push({x: coord.x, y: coord.y})
    }

    return points
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary
    
    ; Generate 40 random points
    Loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)
        
        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x)**2 + (y - existingPoint.y)**2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }
        
        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({x: x, y: y})
    }
    
    ; Always add center point last (so it's used last)
    points.Push({x: centerX, y: centerY})
    
    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points row by row
    Loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)
        
        ; Generate each point in the current row
        Loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

GenerateUpandDownPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points column by column (left to right)
    Loop squaresPerSide {
        currentColumn := A_Index
        x := startX + ((currentColumn - 1) * gridSize)
        
        ; Generate each point in the current column
        Loop squaresPerSide {
            y := startY + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

; circle coordinates
GenerateCirclePoints() {
    points := []
    
    ; Define each circle's radius
    radius1 := 45    ; First circle 
    radius2 := 90    ; Second circle 
    radius3 := 135   ; Third circle 
    radius4 := 180   ; Fourth circle 
    
    ; Angles for 8 evenly spaced points (in degrees)
    angles := [0, 45, 90, 135, 180, 225, 270, 315]
    
    ; First circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius1 * Cos(radians)
        y := centerY + radius1 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; second circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius2 * Cos(radians)
        y := centerY + radius2 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; third circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius3 * Cos(radians)
        y := centerY + radius3 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ;  fourth circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius4 * Cos(radians)
        y := centerY + radius4 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    return points
}

; Spiral coordinates (restricted to a rectangle)
GenerateSpiralPoints(rectX := 4, rectY := 123, rectWidth := 795, rectHeight := 433) {
    points := []
    
    ; Calculate center of the rectangle
    centerX := rectX + rectWidth // 2
    centerY := rectY + rectHeight // 2
    
    ; Angle increment per step (in degrees)
    angleStep := 30
    ; Distance increment per step (tighter spacing)
    radiusStep := 10
    ; Initial radius
    radius := 20
    
    ; Maximum radius allowed (smallest distance from center to edge)
    maxRadiusX := (rectWidth // 2) - 1
    maxRadiusY := (rectHeight // 2) - 1
    maxRadius := Min(maxRadiusX, maxRadiusY)

    ; Generate spiral points until reaching max boundary
    Loop {
        ; Stop if the radius exceeds the max boundary
        if (radius > maxRadius)
            break
        
        angle := A_Index * angleStep
        radians := angle * 3.14159 / 180
        x := centerX + radius * Cos(radians)
        y := centerY + radius * Sin(radians)
        
        ; Check if point is inside the rectangle
        if (x < rectX || x > rectX + rectWidth || y < rectY || y > rectY + rectHeight)
            break ; Stop if a point goes out of bounds
        
        points.Push({ x: Round(x), y: Round(y) })
        
        ; Increase radius for next point
        radius += radiusStep
    }
    
    return points
}

CheckEndAndRoute() {
    if (ok := FindText(&X, &Y, 125, 443, 680, 474, 0, 0, ReturnToLobby)) {
        AddToLog("Found end screen")
        return MonitorEndScreen()
    }
    return false
}

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

PlacementSpeed() {
    speeds := [1000, 1500, 2000, 2500, 3000, 4000]  ; Array of sleep values
    speedIndex := PlaceSpeed.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}