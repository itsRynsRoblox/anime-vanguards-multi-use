#Include %A_ScriptDir%\Lib\gui.ahk
#Include %A_ScriptDir%\Main.ahk
#Include %A_ScriptDir%\Lib\PriorityPicker.ahk

SaveCardConfig(*) {
    SaveCardLocal
    return
}

LoadCardConfig(*) {
    LoadCardLocal
    return
}

SaveCardConfigToFile(filePath) {
    global PlacementPatternDropdown
    directory := "Settings"

    if !DirExist(directory) {
        DirCreate(directory)
    }
    if !FileExist(filePath) {
        FileAppend("", filePath)
    }

    File := FileOpen(filePath, "w")
    if !File {
        AddToLog("Failed to save the card configuration.")
        return
    }

    File.WriteLine("[CardPriority]")
    for index, dropDown in dropDowns
    {
        File.WriteLine(Format("Card{}={}", index+1, dropDown.Text))
    }

    File.Close()
    if (debugMessages) {
        AddToLog("Card configuration saved successfully to " filePath ".`n")
    }
}

LoadCardConfigFromFile(filePath) {
    global dropDowns

    if !FileExist(filePath) {
        AddToLog("No card configuration file found. Creating new local configuration.")
	SaveCardLocal
    } else {
        ; Open file for reading
        file := FileOpen(filePath, "r", "UTF-8")
        if !file {
            AddToLog("Failed to load the configuration.")
            return
        }

        section := ""
        ; Read settings from the file
        while !file.AtEOF {
            line := file.ReadLine()

            ; Detect section headers
            if RegExMatch(line, "^\[(.*)\]$", &match) {
                section := match.1
                continue
            }

            ; Process the lines based on the section
            if (section = "CardPriority") {
                if RegExMatch(line, "Card(\d+)=(\w+)", &match) {
                    slot := match.1
                    value := match.2

                    priorityOrder[slot - 1] := value

                    dropDown := dropDowns[slot - 1]

                    if (dropDown) {
                        dropDown.Text := value
                    }
		    
                }
            }
        }
        file.Close()
        if (debugMessages) {
            AddToLog("Card configuration loaded successfully.")
        }
    }
}


SaveCardLocal(*) {
    SaveCardConfigToFile("Settings\CardPriority.txt")
}

LoadCardLocal(*) {
    LoadCardConfigFromFile("Settings\CardPriority.txt")
}