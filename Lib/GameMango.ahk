#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

LoadKeybindSettings()  ; Load saved keybinds
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())


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

PlacingUnits() {
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

    placementPoints := PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() : PlacementPatternDropdown.Text = "Spiral" ? GenerateSpiralPoints() : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()
    
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
            ; Place all units for this slot
            while (placedCounts[slotNum] < placements) {
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
                
                    if PlaceUnit(point.x, point.y, slotNum) {
                        successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                        placedCounts[slotNum] += 1
                        AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                        CheckAbility()
                        FixClick(560, 560) ; Move Click
                        break
                    }
                    
                    if CheckForResults()
                        return MonitorStage()
                    Reconnect()
                    CheckEndAndRoute()
                }
                Sleep(500)
            }
        }
    }
    
    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}

CheckForResults() {
    ; Check for results text
    if (ok := FindText(&X, &Y, 276, 340, 359, 363, 0, 0, Results)) {
        FixClick(325, 185)
        FixClick(560, 560)
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

                                if CheckForResults() {
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
                                FixClick(560, 560) ; Move Click
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

                if CheckForResults() {
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
                FixClick(560, 560) ; Move Click
                Reconnect()
                CheckEndAndRoute()
            }
        }
    }
}

ChallengeMode() {    
    AddToLog("Starting Challenge Mode")
    ChallengeMovement()
    
    while !(ok := FindText(&X, &Y, 46, 224, 145, 254, 0, 0, ChallengePortal)) {
        ChallengeMovement()
    }

    ; Handle play mode selection
    PlayHere(false)
    RestartStage(false)
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
    while !(ok:=FindText(&X, &Y, 322, 212, 445, 246, 0, 0, SelectAct)) {
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
    while !(ok := FindText(&X, &Y, 322, 212, 445, 246, 0, 0, SelectAct)) {
        RaidMovement()
    }

    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    if (UINavToggle.Value) {
        StartRaid(currentRaidMap, currentRaidAct)
    } else {
        StartRaidNoUI(currentRaidMap, currentRaidAct)
    }
    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        PlayHere(true)
    }

    RestartStage(false)
}

MonitorEndScreen() {
    global mode, StoryDropdown, StoryActDropdown, ReturnLobbyBox, MatchMaking

    Loop {
        Sleep(3000)  
        
        FixClick(560, 560)
        FixClick(560, 560)

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 476, 442, 595, 473, 0, 0, ReturnToLobbyText)) {
            AddToLog("Found Lobby Text - Current Mode: " mode)
            Sleep(2000)

            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (StoryActDropdown.Text != "Infinity") {
                    if (NextLevelBox.Value && lastResult = "win") {
                        AddToLog("Next level")
                        ClickUntilGone(0, 0, 253, 209, 380, 237, VictoryText, 150, 200)
                    } else {
                        AddToLog("Replay level")
                        ClickUntilGone(0, 0, 260, 206, 372, 240, DefeatText, -4, 200)
                    }
                } else {
                    AddToLog("Story Infinity replay")
                    ClickUntilGone(0, 0, 260, 206, 372, 240, DefeatText, 50, 200)
                }
                return RestartStage(true)
            }
            else if (mode = "Raid") {
                AddToLog("Handling Raid end")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby")
                    ClickUntilGone(0, 0, 476, 442, 595, 473, ReturnToLobbyText, 0, -35)
                    return CheckLobby()
                } else {
                    AddToLog("Replay raid")
                    ClickUntilGone(0, 0, 476, 442, 595, 473, ReturnToLobbyText, -150, -35)
                    return RestartStage(true)
                }
            }
            else {
                AddToLog("Handling end case")
                if (ReturnLobbyBox.Value) {
                    AddToLog("Return to lobby enabled")
                    ClickUntilGone(0, 0, 476, 442, 595, 473, ReturnToLobbyText, 0, -35)
                    return CheckLobby()
                } else {
                    AddToLog("Replaying")
                    ClickUntilGone(0, 0, 476, 442, 595, 473, ReturnToLobbyText, -150, -35)
                    return RestartStage(true)
                }
            }
        }

        
        if (ok:=FindText(&X, &Y, 412, 441, 538, 475, 0, 0, ChallengeReturnToLobbyText)) {
            AddToLog("Return to lobby for challenge")
            ClickUntilGone(0, 0, 412, 441, 538, 475, ChallengeReturnToLobbyText, 0, -35)
            return CheckLobby()

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

        ; Click through drops until results screen appears
        if !CheckForBaseHealth() {
            ClickThroughDrops()
            continue
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
        else if (ok := FindText(&X, &Y, 260, 206, 372, 240, 0, 0, DefeatText)) {
            AddToLog("Defeat detected - Stage Length: " stageLength)
            loss += 1
            SendWebhookWithTime(false, stageLength)
            return MonitorEndScreen()
        }

        Reconnect()
    }
}

ClickThroughDrops() {
    AddToLog("Clicking through item drops...")
    Loop 10 {
        FixClick(400, 495)
        Sleep(500)
        if CheckForResults() {
            return
        }
    }
}

StoryMovement() {
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
    Send "Story"
    Sleep(1500)

    ; Click Portal
    FixClick(196, 234)
    Sleep 1000

    ; Click Play
    FixClick(240, 265)
    sleep (1000)
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

ValentineMovement() {
    FixClick(75, 250) ; Click Teleport
    sleep (1000)
    FixClick(520, 270) ; Click Play/Portals
    sleep (1000)
    SendInput ("{s down}")
    Sleep(3000)
    SendInput ("{s up}")
    Sleep 200
    KeyWait "S"
    Sleep 200
    SendInput ("{d down}")
    Sleep(2500)
    SendInput ("{d up}")
    Sleep 200
    KeyWait "D"
    Sleep 200
    SendInput ("{E}")
    Sleep 1500
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
    if (mode = "Story" && StoryActDropdown = "Infinity") {
        FixClick(284,433)
        Sleep 200
    }
    storyClickCoords := GetStoryClickCoords(map) ; Coords for Story Map
    FixClick(storyClickCoords.x, storyClickCoords.y) ; Choose Story
    Sleep 500
    actClickCoords := GetStoryActClickCoords(StoryActDropdown) ; Coords for Story Act
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

StartEvent() {
    ; Handle play mode selection
    if (MatchMaking.Value) {
        FindMatch()
    } else {
        FixClick(220, 440) ; Click Solo
    }
}

PlayHere(clickConfirm := true) {
    if (clickConfirm) {
        FixClick(385, 429) ; Click Confirm
        Sleep (1000)
    }
    FixClick(60, 410) ; Click Start
    Sleep (300)
}

FindMatch() {
    startTime := A_TickCount

    Loop {
        if (A_TickCount - startTime > 50000) {
            AddToLog("Matchmaking timeout, restarting mode")
            FixClick(355, 440)  ; Click Matchmaking to cancel
            Sleep(300)
            FixClick(500, 440)  ; Close Interface
            return StartSelectedMode()
        }
        FixClick(355, 440)  ; Click Matchmaking
        Sleep(300)
        return true
    }
}

GetStoryDownArrows(map) {
    switch map {
        case "Large Village": return 0
        case "Hollow Land": return 1
        case "Monster City": return 2
        case "Academy Demon": return 3
    }
}

GetStoryClickCoords(map) {
    switch map {
        case "Large Village": return { x: 235, y: 240 }
        case "Hollow Land": return { x: 235, y: 295 }
        case "Monster City": return { x: 235, y: 350 }
        case "Academy Demon": return { x: 235, y: 400 }
    }
}

GetStoryActClickCoords(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return { x: 380, y: 230 }
        case "Act 2": return { x: 380, y: 260 }
        case "Act 3": return { x: 380, y: 290 }
        case "Act 4": return { x: 380, y: 320 }
        case "Act 5": return { x: 380, y: 350 }
        case "Act 6": return { x: 380, y: 380 }
        case "Infinity": return { x: 380, y: 405 }
    }
}

GetRaidClickCoords(map) {
    switch map {
        case "Lawless City": return { x: 235, y: 240 }
        case "Temple": return { x: 235, y: 295 }
        case "Orc Castle": return { x: 235, y: 350 }
    }
}

GetRaidActClickCoords(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return { x: 380, y: 230 }
    }
}

GetStoryActDownArrows(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return 0
        case "Act 2": return 1
        case "Act 3": return 2
        case "Act 4": return 3
        case "Act 5": return 4
        case "Act 6": return 5
        case "Infinity": return 6
    }
}

GetRaidDownArrows(map) {
    switch map {
        case "Lawless City": return 0
        case "Temple": return 1
        case "Orc Castle": return 2
    }
}

GetRaidActDownArrows(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return 0
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
    FixClick(26, 570) ;click settings
    Sleep 300
    FixClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 150
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    if (ok := FindText(&X, &Y, 215, 160, 596, 480, 0, 0, Spawn)) {
        AddToLog("Found Teleport to Spawn button")
        FixClick(X + 100, Y - 30)
    } else {
        AddToLog("Could not find Teleport button")
    }
    Sleep 300
    FixClick(583, 147)
    Sleep 300

    ;

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

    ; Wait for the loading screen to disappear instead of a fixed sleep
    WaitForLoadingScreen()

    CheckForFastWaves()
    Sleep 1500
    if (!replay) {
        Zoom()
        Sleep 1500
    }
    CheckForVoteScreen()
    Sleep 300
}

WaitForLoadingScreen() {
    startTime := A_TickCount
    maxWait := 10000 ; Maximum wait time (10 seconds) to prevent infinite loop

    while (IsLoadingScreenVisible()) {
        Sleep 100 ; Check every 100ms
        if (A_TickCount - startTime > maxWait)
            break
    }
}

IsLoadingScreenVisible() {
    ; Replace this with an actual check for the loading screen
    ; Example: checking for a specific pixel color, image, or UI element
    return FindText(&X, &Y, 6, 586, 205, 620, 0, 0 LoadingScreen) ; Adjust as needed
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

        if (ModeDropdown.Text = "Raid") {
            AddToLog("Map detected: " RaidDropdown.Text)
            return RaidDropdown.Text
        }

        if (ModeDropdown.Text = "Valentine's Event") {
            AddToLog("Map detected: " ModeDropdown.Text)
            return ModeDropdown.Text
        }

        mapPatterns := Map(
            "Large Village", LargeVillage,
            "Hollow Land", HollowLand,
            "Monster City", MonsterCity,
            "Academy Demon", AcademyDemon

        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 14, 494, 329, 552, 0, 0, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }

        ; Check for Modifier Cards
        if (ok := FindText(&X, &Y, 681, 381, 778, 434, 0, 0, ModifierCard)) {
            AddToLog("No Map Found or Movement Unnecessary")
            return "no map found"
        }

        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
        case "Large Village":
            MoveForLargeVillage()
        case "Hollow Land":
            MoveForHollowLand()   
        case "Monster City":
            MoveForMonsterCity()
        case "Academy Demon":
            MoveForAcademyDemon()       
        case "Lawless City":
            MoveForLawlessCity()    
        case "Temple":
            MoveForTemple()
        case "Orc Castle":
            MoveForOrcCastle()    
    }
}

MoveForLargeVillage() {
    Fixclick(586, 545, "Right")
    Sleep (6000)
}

MoveForHollowLand() {

}

MoveForOrcCastle() {
    FixClick(400, 7, "Right")
    Sleep (5500)
}

MoveForMonsterCity() {
    Fixclick(515, 366, "Right")
    Sleep (3500)
}

MoveForAcademyDemon() {
    FixClick(452, 414, "Right")
    Sleep (3500)
}

MoveForLawlessCity() {
    Fixclick(507, 194, "Right")
    Sleep (6000)
}

MoveForTemple() {
    FixClick(747, 456, "Right")
    Sleep 3400
    FixClick(550, 300, "Right")
    Sleep 3000
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
    FixClick(x, y)
    Sleep 50
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
    if (ok := FindText(&X, &Y, 120, 247, 236, 269, 0, 0, MaxText)) {
        return true
    }
    return false
}

UnitPlaced() {
    if (WaitForUpgradeText(4500)) { ; Wait up to 4.5 seconds for the upgrade text to appear
        AddToLog("Unit Placed Successfully")
        FixClick(325, 185) ; Close upgrade menu
        return true
    }
    return false
}

WaitForUpgradeText(timeout := 4500) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (FindText(&X, &Y, 118, 246, 241, 273, 0, 0, UpgradeText)) {
            return true
        }
        Sleep 100  ; Check every 100ms
    }
    return false  ; Timed out, upgrade text was not found
}

CheckAbility() {
    /*global AutoAbilityBox  ; Reference your checkbox
    
    ; Only check ability if checkbox is checked
    if (AutoAbilityBox.Value) {
        if (ok := FindText(&X, &Y, 342, 253, 401, 281, 0, 0, AutoOff)) {
            FixClick(373, 237)  ; Turn ability on
            AddToLog("Auto Ability Enabled")
        }
    }*/
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
    
        ; Check for enemies alive
        if (ok := FindText(&X, &Y, 734, 384, 794, 417, 0, 0, ModifierCard)) {
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
    else if (ModeDropdown.Text = "Challenge") {
        ChallengeMode()
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
    if (ok:=FindText(&X, &Y, 358, 107, 449, 130, 0, 0, VoteScreen)) {
          AddToLog("Found Vote Screen")
          FixClick(365, 133)
          FixClick(365, 133)
          FixClick(365, 133)
          return true
    }
    return false
}

CheckForFastWaves() {
    if (ok:=FindText(&X, &Y, 187, 184, 641, 441, 0, 0, FastWave)) {
        Sleep 200
        FindText().Click(X, Y, "L")
        Sleep 200
        FindText().Click(X, Y-20, "L")
        Sleep 200
        FindText().Click(X, Y+20, "L")
        Sleep 200
        return true
    }
    return false
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
    if (ok := FindText(&X, &Y, 476, 442, 595, 473, 0, 0, ReturnToLobbyText)) {
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
        sleep speeds[speedIndex]  ; Use the value directly from the array
}