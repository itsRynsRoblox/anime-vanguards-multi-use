#Requires AutoHotkey v2.0

global CurrentPortal := ""  ; Global variable to store the portal name

CheckPortalRewards() {
    Loop {
        if (ok := FindText(&X, &Y, 290, 213, 515, 231, 0, 0, SelectOneReward)) {
            AddToLog("Rewards Found - Checking for Portals")
            Sleep (1500)
            return CheckPortals(PlanetNamekPortal)
        } else {
            return false
        }
    }
}

TryNamekPortals(inGame := false) {
    AddToLog("Searching for Namek Portals...")
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [255, 325, 395]

    for y in yOffsets {
        for x in xOffsets {
            MouseMove(x, y, 1)
            Sleep 500
            MouseMove(x + 5, y, 1)
            Sleep 500
            if (ok := PixelSearch(&foundX, &foundY, 260, 280, 825, 510, GetPortalColor(), 1)) {
                if (ok := FindText(&X, &Y, 260, 280, 825, 510, 0, 0, PlanetNamekPortal)) {
                    AddToLog("Found Namek Portal, attempting to start...")
                    FixClick(x - 75, y - 100)
                    Sleep 500
                    if (!inGame) {
                        FixClick(x, y - 60)
                        Sleep(500)
                        FixClick(366, 300)  ; Click On Create
                        Sleep (1500)
                        FixClick(366, 300) ; Exit Message
                        Sleep (1500)
                        FixClick(552, 469) ; Start Portal
                        Sleep (1500)
                        FixClick(551, 435) ; Start lower tier portal
                        Sleep (1500)
                        return
                    } else {
                        FixClick(345, 314) ; Click Yes
                        Sleep (1500)
                        return RestartStage()
                    }
                }
            }
        }
    }

    Reconnect()
    AddToLog("No portal for Namek, searching for Shibuya")
    TryShibuyaPortals(inGame)
}

TryShibuyaPortals(inGame := false) {
    AddToLog("Searching for Shibuya Portals...")
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [255, 325, 395]

    for y in yOffsets {
        for x in xOffsets {
            MouseMove(x, y, 1)
            Sleep 500
            MouseMove(x + 5, y, 1)
            Sleep 500
            if (ok := PixelSearch(&foundX, &foundY, 260, 280, 825, 510, GetPortalColor(), 1)) {
                if (ok := FindText(&X, &Y, 260, 280, 825, 510, 0, 0, ShibuyaPortal)) {
                    AddToLog("Found Shibuya Portal, attempting to start...")
                    FixClick(x - 75, y - 100)
                    Sleep 500
                    if (!inGame) {
                        FixClick(x, y - 60)
                        Sleep(500)
                        FixClick(366, 300)  ; Click On Create
                        Sleep (1500)
                        FixClick(366, 300) ; Exit Message
                        Sleep (1500)
                        FixClick(552, 469) ; Start Portal
                        Sleep (1500)
                        FixClick(551, 435) ; Start lower tier portal
                        Sleep (1500)
                        return
                    } else {
                        FixClick(345, 314) ; Click Yes
                        Sleep (1500)
                        return RestartStage()
                    }
                }
            }
        }
    }

    Reconnect()
    AddToLog("No portal for Shibuya found, searching for Namek")
    TryNamekPortals(inGame)
}

TrySandPortals(inGame := false) {
    AddToLog("Searching for Sand Village Portals...")
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [255, 325, 395]

    for y in yOffsets {
        for x in xOffsets {
            MouseMove(x, y, 1)
            Sleep 500
            MouseMove(x + 5, y, 1)
            Sleep 500
            if (ok := PixelSearch(&foundX, &foundY, 260, 280, 825, 510, GetPortalColor(), 1)) {
                if (ok := FindText(&X, &Y, 260, 280, 825, 510, 0, 0, sandPortal)) {
                    AddToLog("Found Sand Portal, attempting to start...")
                    FixClick(x - 75, y - 100)
                    Sleep 500
                    if (!inGame) {
                        FixClick(x, y - 50)
                        Sleep(500)
                        FixClick(366, 300)  ; Click On Create
                        Sleep (1500)
                        FixClick(366, 300) ; Exit Message
                        Sleep (1500)
                        FixClick(552, 469) ; Start Portal
                        Sleep (1500)
                        FixClick(551, 435) ; Start lower tier portal
                        Sleep (1500)
                        return
                    } else {
                        FixClick(345, 314) ; Click Yes
                        Sleep (1500)
                        return RestartStage()
                    }
                }
            }
        }
    }

    Reconnect()
    AddToLog("No portal for Shibuya found, searching for Namek")
    TryNamekPortals(inGame)
}

GetPortalColor() {
    If (PortalDropdown.Text = "Winter Portal") {
        return 0x6B8787
    }
    If (PortalDropdown.Text = "Love Portal") {
        return 0xECBDF7
    }
}

CheckPortals(portalSet) {
    namekPortals := [
        {x: 296, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}},
        {x: 404, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}},
        {x: 506, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}}
    ]
    
    shibuyaPortals := [
        {x: 300, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}},
        {x: 410, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}},
        {x: 510, y: 284, search: {x1: 334, y1: 292, x2: 708, y2: 459}}
    ]
    
    portals := (portalSet = PlanetNamekPortal) ? namekPortals : shibuyaPortals
    
    for i, portal in portals {
        MouseMove(portal.x, portal.y, 1)
        Sleep 500
        MouseMove(portal.x - 4, portal.y, 1)
        Sleep 500
        
        if (ok := FindText(&X, &Y, portal.search.x1, portal.search.y1, portal.search.x2, portal.search.y2, 0, 0, portalSet)) {
            AddToLog("Attemping to claim portal...")
            FixClick(portal.x, 338) ; Select Portal
            Sleep 1000
            FixClick(345, 315) ; Confirm Portal
            Sleep 500
            FixClick(400, 300) ; Cancel Success
            Sleep 500
            SendInput("x") 
            Sleep(500)
            return MonitorStage()
        }
    }
    
    ; Swap portal sets if no portal is found
    if (portalSet = PlanetNamek) {
        CheckPortals(ShibuyaAftermathPortalLobby)
    } else {
        CheckPortals(PlanetNamek)
    }
}
