scriptName NoKidsMCM extends SKI_ConfigBase
{SkyUI Mod Configuration Menu for "No Kids"}

int CurrentReplacementOptionIndex = 0
Form property CurrentChildReplacementBaseForm auto

string[] ChildReplacementOptionNames
int[]    ChildReplacementOptionFormIDs

int oid_ChildCounter
int oid_SearchInput
int oid_ReplacementMenu

string[] CurrentSearchResultNames
int[]    CurrentSearchResultOptions
bool     IsDispayingSearchResults

event OnConfigInit()
    ModName = "No Kids"
    CurrentChildReplacementBaseForm = Game.GetForm(0xA91A0)
    ChildReplacementOptionNames = new string[6]
    ChildReplacementOptionNames[0] = "Chicken"
    ChildReplacementOptionNames[1] = "Dog"
    ChildReplacementOptionNames[2] = "Mudcrab"
    ChildReplacementOptionNames[3] = "Hod"
    ChildReplacementOptionNames[4] = "(Random)"
    ChildReplacementOptionNames[5] = "(None)"
    ChildReplacementOptionFormIDs = new int[5]
    ChildReplacementOptionFormIDs[0] = 0xA91A0
    ChildReplacementOptionFormIDs[1] = 0x23A92
    ChildReplacementOptionFormIDs[2] = 0xE4010
    ChildReplacementOptionFormIDs[3] = 0x1347D
    ChildReplacementOptionFormIDs[4] = 0x0
    ChildReplacementOptionFormIDs[5] = 0x0
endEvent

event OnPageReset(string _)
    SetCursorFillMode(TOP_TO_BOTTOM)
    LeftColumn()
    SetCursorPosition(1)
    RightColumn()
endEvent

function LeftColumn()
    AddHeaderOption("Tracked Children")
    oid_ChildCounter = AddTextOption("Count of tracked children", NoKids.GetTrackedChildCount())
    oid_SearchInput = AddInputOption("Search for child by name", "SEARCH")
    if IsDispayingSearchResults
        IsDispayingSearchResults = false
        ShowSearchResults()
    endIf
endFunction

function RightColumn()
    AddHeaderOption("Choose Child Replacement")
    oid_ReplacementMenu = AddMenuOption("Select what to replace childen with", ChildReplacementOptionNames[CurrentReplacementOptionIndex])
endFunction

function ShowSearchResults()
    CurrentSearchResultOptions = Utility.CreateIntArray(CurrentSearchResultNames.Length)
    if CurrentSearchResultNames
        AddEmptyOption()
        AddHeaderOption("Search Results:")
        int i = 0
        while i < CurrentSearchResultNames.Length
            string kidName = CurrentSearchResultNames[i]
            CurrentSearchResultOptions[i] = AddToggleOption(kidName, NoKids.IsChildEnabled(kidName))
            i += 1
        endWhile
    endIf
endFunction

event OnOptionMenuOpen(int _)
    SetMenuDialogOptions(ChildReplacementOptionNames)
endEvent

event OnOptionMenuAccept(int _, int index)
    if index == -1
        return
    endIf
    CurrentReplacementOptionIndex = index
    string name = ChildReplacementOptionNames[index]
    int formId
    if name == "(Random)"
        int randomIndex = Utility.RandomInt(0, 3)
        formId = ChildReplacementOptionFormIDs[randomIndex]
    else
        formId = ChildReplacementOptionFormIDs[index]
    endIf
    SetMenuOptionValue(oid_ReplacementMenu, name)
    if formId
        CurrentChildReplacementBaseForm = Game.GetForm(formId)
    else
        CurrentChildReplacementBaseForm = None
    endIf
endEvent

event OnOptionInputAccept(int _, string text)
    CurrentSearchResultNames = NoKids.SearchChildrenByName(text)
    if ! CurrentSearchResultNames
        Debug.MessageBox("No tracked childen found matching name:\n" + text)
    endIf
    IsDispayingSearchResults = true
    ForcePageReset()
endEvent

event OnOptionSelect(int optionId)
    int childNameIndex = CurrentSearchResultOptions.Find(optionId)
    string kidName = CurrentSearchResultNames[childNameIndex]
    bool enabled = NoKids.ToggleChildEnabled(kidName)
    SetToggleOptionValue(optionId, enabled)
endEvent
