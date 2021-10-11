scriptName NoKidsMCM extends SKI_ConfigBase
{SkyUI Mod Configuration Menu for "No Kids"}

NoKids API

int oid_ModEnabled
int oid_ChildCounter
int oid_SearchInput
int oid_ReplacementMenu
int oid_ReplacementCount
int oid_ReplacementNotification

string[] CurrentSearchResultNames
int[]    CurrentSearchResultOptions
bool     IsDispayingSearchResults

event OnConfigInit()
    API = (self as Quest) as NoKids
    ModName = "No Kids"
endEvent

event OnPageReset(string _)
    SetCursorFillMode(TOP_TO_BOTTOM)
    LeftColumn()
    SetCursorPosition(1)
    RightColumn()
endEvent

function LeftColumn()
    AddHeaderOption("Tracked Children")
    oid_ChildCounter = AddTextOption("Count of tracked children", API.GetTrackedChildCount())
    oid_SearchInput = AddInputOption("Search for child by name", "SEARCH")
    if IsDispayingSearchResults
        IsDispayingSearchResults = false
        ShowSearchResults()
    endIf
endFunction

function RightColumn()
    AddHeaderOption("Enable / Disable")
    oid_ModEnabled = AddToggleOption("Mod Enabled", API.ModEnabled)
    AddEmptyOption()

    AddHeaderOption("Child Replacement")
    oid_ReplacementNotification = AddToggleOption("Show replacement notifications", API.ReplacementNotifications)
    if API.ReplacementIsRandom
        oid_ReplacementMenu = AddMenuOption("Select what to replace childen with", "(Random)")
    elseIf API.ReplacementForm
        oid_ReplacementMenu = AddMenuOption("Select what to replace childen with", API.ReplacementForm.GetName())
    else
        oid_ReplacementMenu = AddMenuOption("Select what to replace childen with", "(None)")
    endIf
    oid_ReplacementCount = AddSliderOption("Select count of replacement", API.ReplacementFormCount)
endFunction

function ShowSearchResults()
    CurrentSearchResultOptions = Utility.CreateIntArray(CurrentSearchResultNames.Length)
    if CurrentSearchResultNames
        AddEmptyOption()
        AddHeaderOption("Search Results:")
        int i = 0
        while i < CurrentSearchResultNames.Length
            string kidName = CurrentSearchResultNames[i]
            CurrentSearchResultOptions[i] = AddToggleOption(kidName, API.IsChildEnabled(kidName))
            i += 1
        endWhile
    endIf
endFunction

string[] function GetReplacementMenuOptions()
    string[] options = Utility.CreateStringArray(API.ReplacementOptionNames.Length + 2)
    options[0] = "(None)"
    options[1] = "(Random)"
    int nameIndex = 0
    int optionIndex = 2
    while nameIndex < API.ReplacementOptionNames.Length
        options[optionIndex] = API.ReplacementOptionNames[nameIndex]
        optionIndex += 1
        nameIndex += 1
    endWhile
    return options
endFunction

event OnOptionMenuOpen(int _)
    SetMenuDialogOptions(GetReplacementMenuOptions())
endEvent

event OnOptionMenuAccept(int _, int index)
    if index == -1
        return
    elseIf index == 0 ; None
        API.ReplacementForm = None
        API.ReplacementIsRandom = false
        SetMenuOptionValue(oid_ReplacementMenu, "(None)")
    elseIf index == 1 ; Random
        API.ReplacementForm = None
        API.ReplacementIsRandom = true
        SetMenuOptionValue(oid_ReplacementMenu, "(Random)")
    else
        API.ReplacementIsRandom = false
        API.ReplacementForm = API.ReplacementOptionForms[index - 2]
        string name = API.ReplacementOptionNames[index - 2]
        SetMenuOptionValue(oid_ReplacementMenu, name)
    endIf
endEvent

event OnOptionInputAccept(int _, string text)
    CurrentSearchResultNames = API.SearchChildrenByName(text)
    if ! CurrentSearchResultNames
        Debug.MessageBox("No tracked childen found matching name:\n" + text)
    endIf
    IsDispayingSearchResults = true
    ForcePageReset()
endEvent

event OnOptionSelect(int optionId)
    if optionId == oid_ModEnabled
        API.ModEnabled = ! API.ModEnabled
        SetToggleOptionValue(optionId, API.ModEnabled)
    elseIf optionId == oid_ReplacementNotification
        API.ReplacementNotifications = ! API.ReplacementNotifications
        SetToggleOptionValue(optionId, API.ReplacementNotifications)
    else
        int childNameIndex = CurrentSearchResultOptions.Find(optionId)
        string kidName = CurrentSearchResultNames[childNameIndex]
        bool enabled = API.ToggleChildEnabled(kidName)
        SetToggleOptionValue(optionId, enabled)
    endIf
endEvent

event OnOptionSliderOpen(int optionId)
    if optionId == oid_ReplacementCount
        SetSliderDialogInterval(1)
        SetSliderDialogRange(1, 1000)
        SetSliderDialogStartValue(API.ReplacementFormCount)
        SetSliderDialogDefaultValue(API.ReplacementFormCount)
    endIf
endEvent

event OnOptionSliderAccept(int optionId, float value)
    if optionId == oid_ReplacementCount
        API.ReplacementFormCount = value as int
        SetSliderOptionValue(optionId, value)
    endIf
endEvent
