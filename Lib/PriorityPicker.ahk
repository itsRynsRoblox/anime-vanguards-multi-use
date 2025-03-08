global PriorityCardSelector := Gui("+AlwaysOnTop")
PriorityCardSelector.SetFont("s10 bold", "Segoe UI")
PriorityCardSelector.BackColor := "0c000a"
PriorityCardSelector.MarginX := 20
PriorityCardSelector.MarginY := 20
PriorityCardSelector.Title := "Card Priority"

PriorityOrder := PriorityCardSelector.Add("GroupBox", "x30 y25 w180 h380 cWhite", "Modifier Priority Order")

options := ["Regen", "Thrice", "Exploding", "Fast", "Champion", "Immunity", "Revitalize", "Drowsy", "Strong", "Shielded", "Dodge", "Quake"]

numDropDowns := 19
yStart := 50
ySpacing := 28

global dropDowns := []

For index, card in options {
    if (index > numDropDowns)
        Break
    yPos := yStart + ((index - 1) * ySpacing)
    PriorityCardSelector.Add("Text", Format("x38 y{} w30 h17 +0x200 cWhite", yPos), index)
    dropDown := PriorityCardSelector.Add("DropDownList", Format("x60 y{} w135 Choose{}", yPos, index), options)
    dropDowns.Push(dropDown)

    AttachDropDownEvent(dropDown, index)
}

OpenPriorityPicker() {
    PriorityCardSelector.Show()
}

global priorityOrder := ["Regen", "Thrice", "Exploding", "Fast", "Champion", "Immunity", "Revitalize", "Drowsy", "Strong", "Shielded", "Dodge", "Quake"]

priority := []

AttachDropDownEvent(dropDown, index) {
    dropDown.OnEvent("Change", (*) => OnDropDownChange(dropDown, index))
}

RemoveEmptyStrings(array) {
    for index, value in array {
        if (value = "") {
            array.RemoveAt(index)
        }
    }
}

OnDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        priorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Priority {} set to {}", index, ctrl.Text))
        }
        RemoveEmptyStrings(priorityOrder)
        SaveCardLocal
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}