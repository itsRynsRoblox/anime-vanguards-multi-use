#Requires AutoHotkey v2.0

global CurrentPortal := ""  ; Global variable to store the portal name

CheckPortalRewards() {
    Loop {
        if (ok := FindText(&X, &Y, 310, 225, 550, 250, 0, 0, SelectOneReward)) {
            AddToLog("Rewards Found - Checking for Portals")
            Sleep 15000
            CheckPortals(CurrentPortal)
        } else {
            Reconnect()
        }
    }
}

TryNamekPortals() {
    AddToLog("Searching for Namak Portals...")
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [255, 325, 395]

    for y in yOffsets {
        for x in xOffsets {
            MouseMove(x, y, 1)
            Sleep 500
            MouseMove(x + 5, y, 1)
            Sleep 500

            if (ok := FindText(&X, &Y, 260, 280, 825, 510, 0, 0, PlanetNamekPortal)) {
                AddToLog("Found Namak Portal...")
                FixClick(x - 75, y - 100)
                Sleep 500
                FixClick(x, y - 60)
                Sleep(500)
                FixClick(366, 300)  ; Click On Create
                Sleep (1500)
                FixClick(366, 300) ; Exit Message
                Sleep (1500)
                FixClick(552, 469) ; Start Portal
                Sleep (1500)
                return
            }
        }
    }

    Reconnect()
    AddToLog("No portal in Namek, going to Shibuya")
}

TryShibuyaPortals() {
    xOffsets := [200, 280, 360, 440, 520, 600]
    yOffsets := [255, 325, 395]

    for y in yOffsets {
        for x in xOffsets {
            MouseMove(x, y, 1)
            Sleep 500
            MouseMove(x + 5, y, 1)
            Sleep 500

            if (ok := FindText(&X, &Y, 260, 280, 825, 510, 0, 0, PlanetNamekPortal)) {
                FixClick(x - 75, y - 100)
                Sleep 500
                FixClick(x, y - 60)
                return
            }
        }
    }

    Reconnect()
    AddToLog("No portal in Namek, going to Shibuya")
}

CheckPortals(portalSet) {
    namekPortals := [
        {x: 296, y: 284, search: {x1: 334, y1: 292, x2: 500, y2: 380}},
        {x: 404, y: 284, search: {x1: 500, y1: 292, x2: 600, y2: 420}},
        {x: 506, y: 284, search: {x1: 600, y1: 292, x2: 708, y2: 459}}
    ]
    
    shibuyaPortals := [
        {x: 300, y: 284, search: {x1: 320, y1: 280, x2: 480, y2: 370}},
        {x: 410, y: 284, search: {x1: 480, y1: 280, x2: 590, y2: 420}},
        {x: 510, y: 284, search: {x1: 590, y1: 280, x2: 700, y2: 450}}
    ]
    
    portals := (portalSet = PlanetNamek) ? namekPortals : shibuyaPortals
    
    for i, portal in portals {
        MouseMove(portal.x, portal.y, 1)
        Sleep 500
        MouseMove(portal.x - 4, portal.y, 1)
        Sleep 500
        
        if (ok := FindText(&X, &Y, portal.search.x1, portal.search.y1, portal.search.x2, portal.search.y2, 0, 0, portalSet)) {
            FixClick(portal.x, 338) ; Select Portal
            Sleep 1000
            FixClick(345, 315) ; Confirm Portal
            Sleep 500
            FixClick(400, 300) ; Cancel Success
            Sleep 500
            return MonitorStage()
        }
    }
    
    ; Swap portal sets if no portal is found
    if (portalSet = PlanetNamek) {
        CheckPortals(ShibuyaAftermath)
    } else {
        CheckPortals(PlanetNamek)
    }
}
