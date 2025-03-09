#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount
global completedMovements := Map()
global detectedAngle := ""

LoadKeybindSettings()  ; Load saved keybinds
CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5::{
    MonitorStage()
}

F6::{
    DetectWorldlineMap()
}



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
    global successfulCoordinates, maxedCoordinates
    successfulCoordinates := []
    maxedCoordinates := []
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
                for coord in maxedCoordinates {
                    if (coord.x = point.x && coord.y = point.y) {
                        alreadyUsed := true
                        break
                    }
                }
                if (alreadyUsed)
                    continue

                ; If untilSuccessful is false, try once and move on
                if (!untilSuccessful) {
                    if (placedCounts[slotNum] < placements) {
                        if PlaceUnit(point.x, point.y, slotNum) {
                            successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                            placedCounts[slotNum] += 1
                            AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                            CheckForCardSelection()
                            CheckAbility()
                            FixClick(700, 560) ; Move Click
                            if (UpgradeDuringPlacementBox.Value) {
                                AttemptUpgrade()
                            }
                        }
                        CheckForCardSelection()
                    }
                }
                ; If untilSuccessful is true, keep trying the same point until it works
                else {
                    while (placedCounts[slotNum] < placements) {
                        if PlaceUnit(point.x, point.y, slotNum) {
                            successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                            placedCounts[slotNum] += 1
                            AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                            CheckForCardSelection()
                            CheckAbility()
                            FixClick(700, 560) ; Move Click
                            if (UpgradeDuringPlacementBox.Value) {
                                AttemptUpgrade()
                            }
                            break ; Move to the next placement spot
                        }

                        CheckForCardSelection()

                        if (UpgradeDuringPlacementBox.Value) {
                            AttemptUpgrade()
                        }

                        if (ModeDropdown.Text = "Portal") {
                            if CheckPortalRewards() {
                                successfulCoordinates := []
                                maxedCoordinates := []
                                return MonitorStage()
                            }
                        }

                        if CheckForRewards()
                            return MonitorStage()

                        Reconnect()
                        CheckEndAndRoute()
                        Sleep(500) ; Prevents spamming clicks too fast
                    }
                }

                if (ModeDropdown.Text = "Portal") {
                    if CheckPortalRewards() {
                        successfulCoordinates := []
                        maxedCoordinates := []
                        return MonitorStage()
                    }
                }

                if CheckForRewards()
                    return MonitorStage()
            }
        }
    }

    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}



AttemptUpgrade() {
    global successfulCoordinates, maxedCoordinates, PriorityUpgrade, debugMessages
    global priority1, priority2, priority3, priority4, priority5, priority6
    global challengepriority1, challengepriority2, challengepriority3, challengepriority4, challengepriority5, challengepriority6

    if (successfulCoordinates.Length = 0) {
        return ; No units placed yet
    }

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "upgradeEnabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        if (debugMessages) {
            AddToLog("No units enabled - skipping")
        }
        return
    }

    AddToLog("Attempting to upgrade placed units...")

    unitsToRemove := []  ; Store units that reach max level

    if (PriorityUpgrade.Value) {
        if (debugMessages) {
            AddToLog("Using priority-based upgrading")
        }

        ; Loop through priority levels (1-6) and upgrade all matching units
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            upgradedThisRound := false

            for index, coord in successfulCoordinates { 
                ; Check if upgrading is enabled for this unit's slot
                upgradeEnabled := "upgradeEnabled" coord.slot
                upgradeEnabled := %upgradeEnabled%
                if (!upgradeEnabled.Value) {
                    if (debugMessages) {
                        AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                    }
                    continue
                }

                ; Get the priority value for this unit's slot
                priority := "priority" coord.slot
                priority := %priority%

                if (priority.Text = priorityNum) {
                    if (debugMessages) {
                        AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
                    }
                    UpgradeUnit(coord.x, coord.y)

                    if (ModeDropdown.Text = "Portal") {
                        if CheckPortalRewards() {
                            successfulCoordinates := []
                            maxedCoordinates := []
                            return MonitorStage()
                        }
                    }

                    if CheckForRewards() {
                        AddToLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        maxedCoordinates := []
                        return MonitorStage()
                    }

                    if MaxUpgrade() {
                        AddToLog("Max upgrade reached for Unit " coord.slot)
                        successfulCoordinates.RemoveAt(index)
                        maxedCoordinates.Push(coord)
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
        for index, coord in successfulCoordinates {
            ; Check if upgrading is enabled for this unit's slot
            upgradeEnabled := "upgradeEnabled" coord.slot
            upgradeEnabled := %upgradeEnabled%
            if (!upgradeEnabled.Value) {
                if (debugMessages) {
                    AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                }
                continue
            }

            if (debugMessages) {
                AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
            }
            UpgradeUnit(coord.x, coord.y)
            if (ModeDropdown.Text = "Portal") {
                if CheckPortalRewards() {
                    successfulCoordinates := []
                    maxedCoordinates := []
                    return MonitorStage()
                }
            }
            if CheckForRewards() {
                AddToLog("Stage ended during upgrades, proceeding to results")
                successfulCoordinates := []
                maxedCoordinates := []
                return MonitorStage()
            }

            if MaxUpgrade() {
                AddToLog("Max upgrade reached for Unit " coord.slot)
                successfulCoordinates.RemoveAt(index)
                maxedCoordinates.Push(coord)
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
    if (debugMessages) {
        AddToLog("Upgrade attempt completed")
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

                                if (ModeDropdown.Text = "Portal") {
                                    if CheckPortalRewards() {
                                        successfulCoordinates := []
                                        return MonitorStage()
                                    }
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

                if (ModeDropdown.Text = "Portal") {
                    if CheckPortalRewards() {
                        successfulCoordinates := []
                        return MonitorStage()
                    }
                }

                if CheckForRewards() {
                    AddToLog("Stage ended during upgrades, proceeding to results")
                    successfulCoordinates := []
                    return MonitorStage()
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
    PlayHere()
    RestartStage()
}

PortalMode() {
    StartPortal()
    Sleep(2500)
    RestartStage()
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
    StartStory(currentStoryMap, currentStoryAct)

    ; Start Game
    PlayHere()
    
    RestartStage()
}

LegendMode() {
    global LegendDropdown, LegendActDropdown
    
    ; Get current map and act
    currentLegendMap := LegendDropdown.Text
    currentLegendAct := LegendActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 27, 267, 132, 289, 0, 0, CreateMatch)) {
        StoryMovement()
    }
    AddToLog("Starting " currentLegendMap " - " currentLegendAct)
    StartLegend(currentLegendMap, currentLegendAct)

    ; Start Game
    PlayHere()

    RestartStage()
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
    StartRaid(currentRaidMap, currentRaidAct)

    ; Start Game
    PlayHere()

    RestartStage()
}


WorldlineMode() {
    ; Execute the movement pattern
    AddToLog("Moving to position for Worldlines...")
    WorldlineMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 145, 155, 317, 191, 0, 0, Worldlines)) {
        WorldlineMovement()
    }

    AddToLog("Starting Worldlines...")
    StartWorldlines()
    
    RestartStage()
}

StartWorldlines() {
    FixClick(614, 437)
    Sleep (1500)
}

WorldlineMovement() {
    Reconnect()
    FixClick(33, 315) ; click play
    Sleep 2500
    FixClick(365, 337) ; click teleport
    Sleep 1000
	FixClick(365, 337) ; click teleport
    Sleep 1000
	FixClick(365, 337) ; click teleport
    Sleep 2000
    SendInput ("{w up}")  
    Sleep 100  
    SendInput ("{w down}")
    Sleep 5500
    SendInput ("{w up}")
    KeyWait "s" ; Wait for "s" to be fully processed


    SendInput("{a up}") ; Ensure key is released
    Sleep 100
    SendInput ("{a down}")
    Sleep 1200
    SendInput ("{a up}")
    KeyWait "a" ; Wait for "d" to be fully processed
    FixClick(564, 200) ; Close Areas
    Sleep (1500)
    SendInput("e")
    Sleep(1000)
}

MonitorEndScreen() {
    global mode, StoryDropdown, StoryActDropdown, ReturnLobbyBox, MatchMaking

    Loop {
        Sleep(3000) 

        FixClick(570, 580)

        if (ok := FindText(&X, &Y, 265, 240, 295, 260, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 265, 240, 295, 260, UnitExit, -4, -35)
        }

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 223, 339, 402, 389, 0, 0, EndScreen)) {
            AddToLog("Found Lobby Text - Current Mode: " mode)
            Sleep(2000)

            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (NextLevelBox.Value && lastResult = "win") {
                    AddToLog("Next level")
                    ClickNextLevel()
                } else {
                    AddToLog("Replaying level")
                    ClickReplay()
                }
                return RestartStage()
            }
            else if (mode = "Legend") {
                AddToLog("Handling Legend mode end")
                ; Always replay Legend stages
                AddToLog("Replaying legend")
                ClickReplay() ;Replay    
                return RestartStage()
            }
            else if (mode = "Raid") {
                AddToLog("Handling Raid end")
                ; Always replay Raid stages
                AddToLog("Replaying raid")
                ClickReplay() ;Replay
                return RestartStage()
            }
            else if (mode = "Worldlines") {
                AddToLog("Handling Worldlines mode end")
                ClickReturnLobby()
                /*if (NextLevelBox.Value && lastResult = "win") {
                    AddToLog("Next level")
                    ClickNextLevel()
                    Sleep(4500)
                } else {
                    AddToLog("Replaying level")
                    ClickReplay()
                }*/
                return CheckLobby()
            }
            else {
                AddToLog("Handling default case")
                ; Default to replay
                AddToLog("Replaying")
                ClickReplay() ;Replay
                return RestartStageCustom()
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

        while !(CheckForRewards()) {  
            ClickThroughDrops()
            Sleep(100)  ; Small delay to prevent high CPU usage while clicking
        }

        AddToLog("Checking win/loss status")
        stageEndTime := A_TickCount
        stageLength := FormatStageTime(stageEndTime - stageStartTime)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

            ; Check for Victory or Defeat
            if (ok := FindText(&X, &Y, 210, 190, 350, 225, 0, 0, VictoryText2) or (ok:=FindText(&X, &Y, 210, 190, 350, 225, 0, 0, VictoryText2))) {
                AddToLog("Victory detected - Stage Length: " stageLength)
                Wins += 1
                SendWebhookWithTime(true, stageLength)
                if (ModeDropdown.Text = "Portal") {
                    return HandlePortalEnd()
                } else {
                    return MonitorEndScreen()
                }
            }
            else if (ok := FindText(&X, &Y, 210, 190, 350, 225, 0, 0, DefeatText1) or (ok:=FindText(&X, &Y, 210, 190, 350, 225, 0, 0, DefeatText2))) {
                AddToLog("Defeat detected - Stage Length: " stageLength)
                loss += 1
                SendWebhookWithTime(false, stageLength)
                return MonitorEndScreen()
            }

        Reconnect()
    }
}

HandlePortalEnd() {
    selectedPortal := PortalDropdown.Text

    Loop {
        Sleep(3000)  
        
        FixClick(700, 560)

        if (ok := FindText(&X, &Y, 300, 190, 360, 250, 0, 0, UnitExit)) {
            ClickUntilGone(0, 0, 300, 190, 360, 250, UnitExit, -4, -35)
        }

        if (ok := FindText(&X, &Y, 125, 443, 680, 474, 0, 0, ReturnToLobby)) {
            AddToLog("Found Lobby Text - starting new portal")
            Sleep(2000)
            FixClick(215, 420) ;Select New Portal
            Sleep(1500)
            FixClick(205, 195) ; Click search
            Sleep(1500)
            SendInput(selectedPortal)
            Sleep(1500)
            TryNamekPortals(true)
            return RestartStage()
        }
        
        Reconnect()
        CheckEndAndRoute()
    }
}

ClickThroughDrops() {
    if (debugMessages) {
        AddToLog("Clicking through item drops...")
    }
    Loop 10 {
        FixClick(400, 495)
        Sleep(500)
        if CheckForRewards() {
            return
        }
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
    FixClick(90, 260) ; Click Area
    Sleep(1000)
    FixClick(700, 300) ; Click Raid
    Sleep(2000)
    SendInput ("{d down}")
    Sleep(400)
    SendInput ("{d up}")
    Sleep(500)
    SendInput ("{s down}")
    Sleep(8000)
    SendInput ("{s up}")
    Sleep(500)
    SendInput ("{d down}")
    Sleep(4000)
    SendInput ("{d up}")
}

StartStory(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Navigate to map selection screen
    FixClick(85, 245) ; Create Match
    Sleep(500)

    ; Get Story map 
    StoryMap := GetStoryMap(map)
    
    ; Scroll if needed
    if (StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(150, 190)
        SendInput("{WheelDown}")
        Sleep(250)
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetStoryAct(act)
    
    ; Scroll if needed for act
    if (StoryAct.scrolls > 0) {
        AddToLog("Scrolling down " StoryAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop StoryAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(StoryAct.x, StoryAct.y)
    Sleep(1000)
    
    return true
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

StartLegend(map, act) {
    
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Navigate to map selection screen
    FixClick(85, 245) ; Create Match
    Sleep(500)
    FixClick(500, 500) ; Click On Legend
    Sleep(500)

    ; Get Story map 
    LegendMap := GetLegendMap(map)
    
    ; Scroll if needed
    if (LegendMap.scrolls > 0) {
        AddToLog("Scrolling down " LegendMap.scrolls " for " map)
        MouseMove(150, 190)
        SendInput("{WheelDown}")
        Sleep(250)
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(LegendMap.x, LegendMap.y)
    Sleep(1000)
    
    ; Get act details
    LegendAct := GetLegendAct(act)
    
    ; Scroll if needed for act
    if (LegendAct.scrolls > 0) {
        AddToLog("Scrolling down " LegendAct.scrolls " for " act)
        MouseMove(300, 240)
        SendInput("{WheelDown}")
        Sleep(250)
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(LegendAct.x, LegendAct.y)
    Sleep(1000)

    return true
}

StartChallenge() {
    FixClick(640, 70)
    Sleep(500)
}

StartRaid(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Navigate to map selection screen
    FixClick(85, 245) ; Create Match
    Sleep(500)

    ; Get Story map 
    RaidMap := GetRaidMap(map)
    
    ; Scroll if needed
    if (RaidMap.scrolls > 0) {
        AddToLog("Scrolling down " RaidMap.scrolls " times for " map)
        MouseMove(150, 190)
        SendInput("{WheelDown}")
        Sleep(250)
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(RaidMap.x, RaidMap.y)
    Sleep(1000)
    
    ; Get act details
    RaidAct := GetRaidAct(act)
    
    ; Scroll if needed for act
    if (RaidAct.scrolls > 0) {
        AddToLog("Scrolling down " RaidAct.scrolls " times for " act)
        MouseMove(300, 240)
        SendInput("{WheelDown}")
        Sleep(250)
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(RaidAct.x, RaidAct.y)
    
    return true
}

PlayHere() {
    FixClick(555, 444)  ; Click Start
    Sleep (500)
    FixClick(90, 435) ; Actually Starting
    Sleep (500)
    FixClick(90, 470) ; Actually Starting
    Sleep (500)
    FixClick(400, 315) ; Cancel Button
    Sleep (500)
    FixClick(90, 435) ; Actually Starting
    Sleep (500)
    FixClick(90, 470) ; Actually Starting
}

GetStoryMap(map) {
    switch map {
        case "Planet Namek": return {x: 150, y: 190, scrolls: 0}
        case "Sand Village": return {x: 150, y: 240, scrolls: 0}
        case "Double Dungeon": return {x: 150, y: 290, scrolls: 0}
        case "Shibuya Station": return {x: 150, y: 340, scrolls: 0}
        case "Underground Church": return {x: 150, y: 390, scrolls: 0}
        case "Spirit Society": return {x: 150, y: 390, scrolls: 1}
    }
}

GetStoryAct(act) {
    switch act {
        case "Act 1": return {x: 300, y: 240, scrolls: 0}
        case "Act 2": return {x: 300, y: 290, scrolls: 0}
        case "Act 3": return {x: 300, y: 340, scrolls: 0}
        case "Act 4": return {x: 300, y: 390, scrolls: 0}
        case "Act 5": return {x: 300, y: 290, scrolls: 1}
        case "Act 6": return {x: 300, y: 340, scrolls: 1}
        case "Infinity": return {x: 300, y: 390, scrolls: 1}
        case "Paragon": return {x: 300, y: 390, scrolls: 5}
    }
}

GetLegendMap(map) {
    switch map {
        case "Sand Village": return {x: 150, y: 190, scrolls: 0}
        case "Double Dungeon": return {x: 150, y: 240, scrolls: 0}
        case "Shibuya Aftermath": return {x: 150, y: 290, scrolls: 0}
        case "Golden Castle": return {x: 150, y: 340, scrolls: 0}
        case "Kuinshi Palace": return {x: 150, y: 390, scrolls: 0}
    }
}

GetLegendAct(act) {
    switch act {
        case "Act 1": return {x: 300, y: 190, scrolls: 0}
        case "Act 2": return {x: 300, y: 240, scrolls: 0}
        case "Act 3": return {x: 300, y: 290, scrolls: 0}
    }
}

GetRaidMap(map) {
    switch map {
        case "Spider Forest": return {x: 150, y: 190, scrolls: 0}
        case "Track Of World": return {x: 150, y: 240, scrolls: 0}
    }
}

GetRaidAct(act) {
    switch act {
        case "Act 1": return {x: 300, y: 190, scrolls: 0}
        case "Act 2": return {x: 300, y: 240, scrolls: 0}
        case "Act 3": return {x: 300, y: 290, scrolls: 0}
        case "Act 4": return {x: 300, y: 340, scrolls: 0}
        case "Act 5": return {x: 300, y: 390, scrolls: 0}
    }
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

BasicSetup() {
    SendInput("{Tab}") ; Closes Player leaderboard
    Sleep (300)
    FixClick(564, 72) ; Closes Player leaderboard
    Sleep (300)
    CloseChat()
    Sleep (300)
    Zoom()
    Sleep (300)
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

        ; Check for vote screen
        if (ok := FindText(&X, &Y, 322, 110, 483, 170, 0, 0, VoteStart) or PixelGetColor(300, 15) = 0x0F9C24 or PixelGetColor(300, 15) = 0x15DE33) {
            AddToLog("Same Map or No Map Found")
            return "no map found"
        }

        mapPatterns := Map(
            "Planet Namek", PlanetNamek,
            "Sand Village", SandVillage,
            "Double Dungeon", DoubleDungeon, 
            "Shibuya Station", ShibuyaStation,
            "Underground Church", UndergroundChurch,
            "Spirit Society", SpiritSociety,
            "Blood-Red Chamber", IgrisBoss,
            "Spider Forest", SpiderForest,
            "Track Of World", TrackOfWorld,
            "Shibuya Aftermath", ShibuyaAftermath,
            "Golden Castle", GoldenCastle,
            "Kuinshi Palace", KuinshiPalace
        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 10, 505, 335, 625, 0, 0, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }
        Sleep 1000
        Reconnect()
    }
}

DetectWorldlineMap() {
    AddToLog("Looking for Map Changes....")
    startTime := A_TickCount
    maxWait := 10000 ; Maximum wait time (10 seconds) to prevent infinite loop
    Loop {
        if (A_TickCount - startTime > maxWait) {
            AddToLog("Map not detected or didn't change after 10 seconds...")
            return "No map found"
        }

        mapPatterns := Map(
            "Planet Namek", NamekWorldlines,
            "Shibuya", ShibuyaWorldlines
        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 217, 185, 628, 416, 0.20, 0.20, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }

        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    global detectedAngle
    ; Check if this map needs movement
    if (RequiresMovement(MapName)) {
        AddToLog("Executing Movement for: " MapName)
        
        switch MapName {
            case "Sand Village":
                MoveForSandVillage()
            case "Double Dungeon":
                MoveForDoubleDungeon()
            case "Spirit Society":
                MoveForGoldenCastle()
            case "Spider Forest":
                MoveForSpiderForest()
            case "Track Of World":
                MoveForTrackOfWorld()
            case "Golden Castle":
                MoveForGoldenCastle()
            case "Blood-Red Chamber":
                MoveForBloodRedChamber()
            case "Shibuya Aftermath":
                MoveForShibuyaAftermatchWinter(detectedAngle)
        }
    }
}

RequiresMovement(MapName) {
    ; Array of maps that need movement
    static mapsWithMovement := ["Sand Village", "Double Dungeon", "Spirit Society", "Spider Forest", "Golden Castle", "Track Of World", "Blood-Red Chamber", "Shibuya Aftermath"]
    
    ; Check if current map is in the array
    for map in mapsWithMovement {
        if (map = MapName)
            return true
    }
    
    return false
}

MoveForSandVillage() {
    SendInput ("{s down}")
    SendInput ("{d down}")
    Sleep (5000)
    SendInput ("{s up}")
    SendInput ("{d up}")
    Sleep (1000)
}

MoveForDoubleDungeon() {
    SendInput ("{w down}")
    Sleep (1400)
    SendInput ("{w up}")
    Sleep (1000)
}

MoveForSpiderForest() {
    SendInput ("{d down}")
    Sleep (800)
    SendInput ("{d up}")
    Sleep (1000)
    SendInput ("{s down}")
    Sleep (2300)
    SendInput ("{s up}")
    Sleep (1000)
}

MoveForGoldenCastle() {
    SendInput ("{a down}")
    Sleep (1200)
    SendInput ("{a up}")
    Sleep (1000)
}

MoveForTrackOfWorld() {
    currentRaidAct := RaidActDropdown.Text
    if (currentRaidAct = "Act 4" || currentRaidAct = "Act 5") {
        SendInput ("{d down}")
        Sleep (1700)
        SendInput ("{d up}")
        Sleep(1000)
        SendInput ("{s down}")
        Sleep(2600)
        SendInput ("{s up}")
        Sleep(1000)
        SendInput ("{a down}")
        Sleep(300)
        SendInput ("{a up}")
        Sleep(1000)
    } else {
        Sleep(1000)
    }
}

MoveForBloodRedChamber() {
    SendInput ("{s down}")
    Sleep (4300)
    SendInput ("{s up}")
    Sleep (1000)
}

MoveForShibuyaAftermatchWinter(angle := "") {
    if (angle = "1") {
        FixClick(334, 146, "Right")
        Sleep (1500)
    }
    else if (angle = "3") {
        FixClick(625, 456, "Right")
        Sleep (1500)
    }

}

RestartStage() {
    global completedMovements
    currentMap := DetectMap()

     ; Reset movement completion if this is a new map
    if (!completedMovements.Has(currentMap)) {
        completedMovements := Map()  ; Clear all previous entries
        completedMovements[currentMap] := false  ; Set current map to false
    }
    
    ; Wait for loading
    CheckLoaded()

    CheckForCardSelection()
    if (ModeDropdown.Text = "Story") {
        if (StoryActDropdown.Text = "Paragon") {
            Sleep(1000)
            CheckForCardSelection()
        }
    }

    ; Do initial setup and map-specific movement during vote timer
    BasicSetup()

    ; Wait for game to actually start to fix camera movement
    StartedGame()

    ; Fix camera angle 
    FixMapCameraAngle(currentMap)

    if (currentMap != "no map found" && !completedMovements[currentMap]) {
        HandleMapMovement(currentMap)
        completedMovements[currentMap] := true  ; Mark this map as completed
    } else {
        Sleep(1000)
    }

    ; Wait for game to actually start to start placing units
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits(PlacementPatternDropdown.Text == "Custom")
    
    ; Monitor stage progress
    MonitorStage()
}

RestartStageNew() {
    global completedMovements, lastMap
    currentMap := DetectMap()

    ; Use the last known valid map if the detection fails
    if (currentMap = "no map found" && IsSet(lastMap)) {
        currentMap := lastMap
    }

    ; Reset movement completion if this is a new map
    if (!completedMovements.Has(currentMap)) {
        completedMovements := Map()  ; Clear all previous entries
        completedMovements[currentMap] := false  ; Set current map to false
    }
    
    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    BasicSetup()

    ; Wait for game to actually start to fix camera movement
    StartedGame()

    ; Only fix camera if the map has changed
    if (currentMap != lastMap) {
        FixMapCameraAngle(currentMap)
    }

    if (currentMap != "no map found" && !completedMovements[currentMap]) {
        HandleMapMovement(currentMap)
        completedMovements[currentMap] := true  ; Mark this map as completed
    } else {
        Sleep(1000)
    }

    ; Wait for game to actually start to start placing units
    StartedGame()

    ; Only update lastMap if it's a valid map
    if (currentMap != "no map found") {
        lastMap := currentMap
    }

    ; Begin unit placement and management
    PlacingUnits(false)
    
    ; Monitor stage progress
    MonitorStage()
}

RestartStageCustom() {
    ; Wait for loading
    CheckLoaded()
    
    ; Wait for game to actually start
    StartedGame()

    Sleep (2000)
    CheckForCardSelection()
    
    ; Begin unit placement and management
    PlacingUnits(true)
        
    ; Monitor stage progress
    MonitorStage()
}

FixMapCameraAngle(mapName) {
    AddToLog("Checking camera angle for " mapName)
    
    ; Skip if no mapName or "no map found"
    if (!mapName or mapName == "no map found")
        return
    
    ; First check if the camera angle is already correct
    if (IsCorrectAngle(mapName)) {
        AddToLog("Camera angle is correct for " mapName)
        if (ModeDropdown.Text = "Portal") {
            SellCameraUnit()
        } else {
            RestartMatch()
        }
        return
    }
    
    ; Try placing one unit with random placement to fix angle
    PlaceUnitForAngle()
    AddToLog("Using spectator to fix angle")
    
    ; If not fixed with unit placement, try with spectator until fixed
    loop {
        ; Try spectator mode
        SpectatorAngleFix()
        
        ; Check for disconnect
        Reconnect()
        
        ; Check for game end
        if (CheckForRewards()) {
            AddToLog("Game ended during camera angle fix")
            return MonitorStage()
        }
        
        ; Check if angle is now fixed
        if (IsCorrectAngle(mapName)) {
            AddToLog("Camera angle fixed with spectator")
            if (ModeDropdown.Text = "Portal") {
                SellCameraUnit()
            } else {
                RestartMatch()
            }
            return
        }
    }
}

SellCameraUnit() {
    AddToLog("Selling Camera Unit...")
    SendInput("x")
    Sleep(500)
}

IsCorrectAngle(mapName) {
    global detectedAngle
    currentRaidAct := RaidActDropdown.Text
    ; Check camera angle for each map
    switch mapName {
        case "Planet Namek":
            if (ModeDropdown.Text = "Portal") {
                if (PortalDropdown.Text = "Winter Portal") {
                    return (FindText(&X, &Y, 574, 109, 745, 172, 0.20, 0.20, namekWinterAngle) or FindText(&X, &Y, 597, 192, 653, 231, 0.20, 0.20, namekWinterAngle2)) ? true : false
                }
            }
            return (FindText(&X, &Y, 610, 195, 649, 233, 0.20, 0.20, namekAngle) or  FindText(&X, &Y, 710, 465, 763, 516, 0.20, 0.20, namekAngle2)) ? true : false
            
        case "Sand Village":
            return FindText(&X, &Y, 360, 170, 425, 220, 0.20, 0.20, SandAngle) ? true : false
   
        case "Spirit Society":
            return FindText(&X, &Y, 580, 540, 625, 582, 0.20, 0.20, SpiritAngle) ? true : false
            
        case "Spider Forest":
            return FindText(&X, &Y, 500, 380, 580, 450, 0.20, 0.20, SpiderAngle) ? true : false

        case "Track Of World":
            if (currentRaidAct = "Act 4" || currentRaidAct = "Act 5") {
            return FindText(&X, &Y, 550, 145, 643, 227, 0.20, 0.20, TrackWorldAngle) ? true : false
        } else {
            return true  ; Acts 1-3 don't need angle check
        }

        case "Shibuya Aftermath":
            if (ModeDropdown.Text = "Portal" && PortalDropdown.Text = "Winter Portal") {
                if (FindText(&X, &Y, 350, 187, 397, 244, 0.20, 0.20, shibuyaWinterAngle)) {
                    detectedAngle := "1"
                    return true
                }
                if (FindText(&X, &Y, 373, 428, 424, 478, 0.20, 0.20, shibuyaWinterAngle2)) {
                    detectedAngle := "2"
                    return true
                }
                if (FindText(&X, &Y, 656, 461, 777, 585, 0.20, 0.20, shibuyaWinterAngle3)) {
                    detectedAngle := "3"
                    return true
                }
            }
            return (FindText(&X, &Y, 395, 455, 434, 494, 0.20, 0.20, ShibuyaAngle) or FindText(&X, &Y, 60, 380, 119, 415, 0.20, 0.20, ShibuyaAngle2)) ? true : false

        case "Golden Castle":
            return FindText(&X, &Y, 490, 470, 549, 534, 0.20, 0.20, GoldenAngle) ? true : false

        case "Kuinshi Palace":
            return FindText(&X, &Y, 340, 80, 414, 145, 0.20, 0.20, KuinshiAngle) ? true : false
            
        case "Double Dungeon", "Shibuya Station", "Underground Church", "Blood-Red Chamber":
            return true
            
        default:
            return true
    }
}

RestartMatch() {
    AddToLog("Restarting match")
    FixClick(21, 577) ;click settings
    Sleep (1000)
    FixClick(515, 280) ;click restart match
    Sleep (1000)
    FixClick(345, 310) ;click yes
    Sleep (1000)
    Sleep(2000)
    CheckForCardSelection()
    if (ModeDropdown.Text = "Story") {
        if (StoryActDropdown.Text = "Paragon") {
            Sleep(1000)
            CheckForCardSelection()
        }
    }
    Sleep (2000)
    FixClick(400, 300) ;click cancel
    Sleep (1000)
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

CameraUnitPlaced() {
    Sleep 2000
    ; Check for upgrade text
    if (ok := FindText(&X, &Y, 147, 248, 228, 273, 0, 0, UpgradeText)) {
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
        if (ok := FindText(&X, &Y, 742, 416, 794, 439, 0, 0, ProfileText)) {
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
        
        ; Check for vote screen
        if (ok := FindText(&X, &Y, 322, 110, 483, 170, 0, 0, VoteStart) or (ok := FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup) or (FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup2)) or PixelGetColor(300, 15) = 0x0F9C24 or PixelGetColor(300, 15) = 0x15DE33)) {
            AddToLog("Successfully Loaded In")
            Sleep(1000)
            CheckForCardSelection()
            break
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        if (ok := FindText(&X, &Y, 322, 110, 483, 170, 0, 0, VoteStart)) {
            ClickUntilGone(0, 0, 322, 110, 483, 170, VoteStart, -21, 0)
            continue  ; Keep waiting if vote screen is still there
        }
        
        ; If we don't see vote screen anymore the game has started
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    FixClick(640, 70) ; Closes Player leaderboard
    sleep (500)
    FixClick(640, 73) ; Closes Player leaderboard
    sleep (500)
    FixClick(665,143) ; Close Big Red X
    sleep (500)
    FixClick(565,200) ; Close Daily
    sleep (500)
    if (ModeDropdown.Text = "Story") {
        StoryMode()
    }
    else if (ModeDropdown.Text = "Legend") {
        LegendMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        RaidMode()
    }
    else if (ModeDropdown.Text = "Portal") {
        PortalMode()
    }
    else if (ModeDropdown.Text = "Worldlines") {
        WorldlineMode()
    }
    else if (ModeDropdown.Text = "Custom") {
        CustomMode()
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

UseCustomPoints() {
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

PlaceUnitForAngle() {
    global successfulCoordinates
    ; Try placing a unit using random points
    AddToLog("Attempting to place a unit for angle fix")
    
    ; Generate random placement points
    placementPoints := GenerateRandomPoints()
    
    ; Track placement attempts
    placementAttempts := 0
    maxAttempts := 20
    
    ; Try to place unit with slot 1
    for point in placementPoints {
        SendInput("1")
        Sleep 50
        if (ModeDropdown.Text = "Portal") {
            If (PortalMapDropdown.Text = "Planet Namak") {
                FixClick(427, 315)
            } else {
                FixClick(point.x, point.y)
            }
        } else {
            FixClick(point.x, point.y)
        }
        Sleep 50
        SendInput("q")
        Sleep 300
        
        ; Increment attempt counter
        placementAttempts++
        
        ; Check if unit was placed
        if (CameraUnitPlaced()) {
            AddToLog("Unit placed successfully for angle check")
            return true
        }

        ; Check if restart put us back in lobby or game ended
        if (CheckForRewards() || FindText(&X, &Y, 742, 416, 794, 439, 0, 0, ProfileText)) {
            AddToLog("Game ended or found lobby.")
            return false
        }

        
        ; Check if we've reached max attempts
        if (placementAttempts >= maxAttempts) {
            AddToLog("Failed to place unit after " maxAttempts " attempts. tp spawn to retry.")
            TpSpawn()
            Sleep(3000)
            return PlaceUnitForAngle()  ; Recursive call to try again after restart
        }
    }
}

SpectatorAngleFix() {
    ; First Teleport to spawn
    TpSpawn()
    Sleep(1000)

    ; Enter spectator mode
    FixClick(229, 411)
    Sleep(800)
    
    ; look left to fix angle
    FixClick(327, 511)
    Sleep(800)
    
    ; Exit spectator mode
    FixClick(400, 575)
    Sleep(2000)
}

CheckForWorldineCards() {
    AddToLog("Checking for Worldline cards...")
    
    ; Read priorities directly from file to ensure we have the latest values
    priorities := []
    if FileExist("Settings\WorldlineCardPriorities.txt") {
        fileContent := FileRead("Settings\WorldlineCardPriorities.txt", "UTF-8")
        lines := StrSplit(fileContent, "`n")
        
        ; Use saved priorities
        for line in lines {
            if (line != "")
                priorities.Push(line)
        }
    } else {
        ; If priorities aren't in the dropdowns or file, use defaults
        try {
            priorities := [CardPriority1.Text, CardPriority2.Text, CardPriority3.Text]
        } catch {
            priorities := ["Damage", "Cooldown", "Range"]
            AddToLog("Using default card priorities")
        }
    }
    
    ; Wait for the cards to appear (try for 5 seconds)
    Loop 5 {
        ; Look for "Click to vote" text at the bottom of the cards
        if (ok := FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup) or (FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup2) or (FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, AdditionalCardPopup)))) {
            AddToLog("Found Worldlines card selection screen")
            Sleep(1500)  ; Give time for cards to fully appear
            
            ; Move mouse over each card before identifying (helps with tooltips)
            MouseMove(260, 280)
            Sleep(200)
            leftCard := IdentifyCard(200, 280, 325, 300)
            
            MouseMove(400, 280)
            Sleep(200)
            middleCard := IdentifyCard(340, 280, 465, 300)
            
            MouseMove(540, 280)
            Sleep(200)
            rightCard := IdentifyCard(480, 280, 600, 300)
            
            AddToLog("Available cards: Left=" leftCard ", Middle=" middleCard ", Right=" rightCard)
            
            ; Go through priorities and select first match
            selectedCard := false
            
            for priority in priorities {
                ; Skip if priority is empty
                if (priority = "")
                    continue
                    
                ; Check if any cards match this priority
                if (leftCard = priority) {
                    FixClick(260, 280)
                    AddToLog("Selected priority card: " priority " (left)")
                    selectedCard := true
                    break
                } 
                else if (middleCard = priority) {
                    FixClick(400, 280)
                    AddToLog("Selected priority card: " priority " (middle)")
                    selectedCard := true
                    break
                }
                else if (rightCard = priority) {
                    FixClick(540, 280)
                    AddToLog("Selected priority card: " priority " (right)")
                    selectedCard := true
                    break
                }
            }
            
            ; If no priority card found, default to middle
            if (!selectedCard) {
                FixClick(400, 280)
                AddToLog("No priority card available, selected middle: " middleCard)
            }
            
            Sleep(1000)
            return true
        }
        Sleep(1000)
    }
    
    AddToLog("No starter cards found after 5 seconds, continuing...")
    return false
}

; Function to identify a card
IdentifyCard(x1, y1, x2, y2) {
    ; Use FindText to identify the card within the given region
    if (FindText(&CardX, &CardY, x1, y1, x2, y2, 0.15, 0.15, DamageCard)) {
        return "Damage"
    }
    else if (FindText(&CardX, &CardY, x1, y1, x2, y2, 0.15, 0.15, CooldownCard)) {
        return "Cooldown"
    }
    else if (FindText(&CardX, &CardY, x1, y1, x2, y2, 0.15, 0.15, RangeCard)) {
        return "Range"
    }
    
    return "Unknown"
}

StartPortal() {
    selectedPortal := PortalDropdown.Text

        ; Click items
        FixClick(30, 255)
        Sleep(1500)
        
        ; Click search
        FixClick(507, 200)
        Sleep(1500)
        
        ; Type portal name
        SendInput(selectedPortal)
        Sleep(1500)

        if (PortalMapDropdown.Text = "Namek") {
            TryNamekPortals()
        } else {
            TryShibuyaPortals()
        }

        AddToLog("Creating " selectedPortal)
}

CheckForCardSelection() {
    if (ok := FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup) or (FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, CardsPopup2) or (FindText(&X, &Y, 365, 390, 442, 404, 0.10, 0.10, AdditionalCardPopup)))) {
        AddToLog("Checking for cards....")
        if (ModeDropdown.Text = "Worldlines") {
            CheckForWorldineCards()
        }
        if (ModeDropdown.Text = "Story") {
            if (StoryActDropdown.Text = "Paragon") {
                CardSelector()
            }
        }
        if (ModeDropdown.Text = "Legend") {
            CardSelector()
        }
    }
}

ClickReturnLobby() {
    DualClickUntilGone(
        [550, 435, 685, 480, LobbyText, 0, -35, LobbyText2], ; Return to lobby
        [352, 342, 453, 367, CancelButton, -4, -35, ""]      ; Cancel Button
    )
}

; Click Replay button
ClickReplay() {
    DualClickUntilGone(
        [550, 435, 685, 480, LobbyText, -70, -35, LobbyText2], ; Replay
        [352, 342, 453, 367, CancelButton, -4, -35, ""]        ; Cancel Button
    )
}

; Click Next Level button
ClickNextLevel() {
    DualClickUntilGone(
        [550, 435, 685, 480, LobbyText, -400, -35, LobbyText2], ; Next Level
        [352, 342, 453, 367, CancelButton, -4, -35, ""]         ; Cancel Button
    )
}