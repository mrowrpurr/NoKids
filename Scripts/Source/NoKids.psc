scriptName NoKids extends Quest
{Main script for NoKids

Manages the configuration, versioning, and child storage.}

bool property ModEnabled auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mod Installation and Load Game Handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float property CurrentlyInstalledModVersion auto

event OnInit()
    CurrentlyInstalledModVersion = GetCurrentVersion()
    LoadConfiguration()
endEvent

event PlayerLoadGame()
    ; Here in case we need to capture the load game event
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mod Versioning
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float function GetCurrentVersion() global
    return 1.0
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property CONFIG_FILENAME_DATA_PATH            = "Data/NoKids/Config.json"           autoReadonly
string property CONFIG_FILENAME_FULL_PATH            = "../../../NoKids/Config.json"       autoReadonly
string property CONFIG_KEY_MOD_ENABLED               = "nokids_mod_enabled"                autoReadonly
string property CONFIG_KEY_REPLACEMENT_FORM          = "nokids_replacement_form"           autoReadonly
string property CONFIG_KEY_REPLACEMENT_COUNT         = "nokids_replacement_count"          autoReadonly
string property CONFIG_KEY_REPLACEMENT_OPTIONS       = "nokids_replacement_options"        autoReadonly
string property CONFIG_KEY_REPLACEMENT_RANDOM        = "nokids_replacement_random"         autoReadonly
string property CONFIG_KEY_REPLACEMENT_NOTIFICATIONS = "nokids_replacement_notifications"  autoReadonly

string property STORAGE_KEY_CHILD_FORM = "nokids_references" autoReadonly
string property STORAGE_KEY_CHILD_NAME = "nokids_names"      autoReadonly

bool     property ReplacementIsRandom      auto
Form     property ReplacementForm          auto
int      property ReplacementFormCount     auto
bool     property ReplacementNotifications auto
Form[]   property ReplacementOptionForms   auto
string[] property ReplacementOptionNames   auto

function LoadConfiguration()
    SetDefaults()
    if MiscUtil.FileExists(CONFIG_FILENAME_DATA_PATH)
        ModEnabled               = JsonUtil.GetStringValue(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_MOD_ENABLED) == "true"
        ReplacementForm          = JsonUtil.GetFormValue(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_REPLACEMENT_FORM)
        ReplacementFormCount     = JsonUtil.GetIntValue(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_REPLACEMENT_COUNT)
        ReplacementNotifications = JsonUtil.GetStringValue(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_REPLACEMENT_NOTIFICATIONS) == "true"
        ReplacementOptionForms   = JsonUtil.FormListToArray(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_REPLACEMENT_OPTIONS)
        ReplacementIsRandom      = JsonUtil.GetStringValue(CONFIG_FILENAME_FULL_PATH, CONFIG_KEY_REPLACEMENT_RANDOM) == "true"
        ResetFormNames()
        if ReplacementIsRandom
            ReplacementForm = None
        endIf
    endIf
endFunction

function SetDefaults()
    ReplacementForm          = Game.GetForm(0xA91A0) ; Chicken
    ReplacementFormCount     = 60
    ReplacementNotifications = true
    ReplacementIsRandom      = false

    if ReplacementIsRandom
        ReplacementForm = None
    endIf
endFunction

function ResetFormNames()
    ReplacementOptionNames = Utility.CreateStringArray(ReplacementOptionForms.Length)
    int i = 0
    while i < ReplacementOptionForms.Length
        ReplacementOptionNames[i] = ReplacementOptionForms[i].GetName()
        i += 1
    endWhile
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Replacement Forms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Form function GetReplacementForm()
    if ReplacementIsRandom
        int randomIndex = Utility.RandomInt(0, ReplacementOptionForms.Length - 1)
        return ReplacementOptionForms[randomIndex]
    else
        return ReplacementForm
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reference Tracking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function TrackChild(Actor child)
    string name = child.GetActorBase().GetName()
    StorageUtil.FormListAdd(None, STORAGE_KEY_CHILD_FORM, child)
    StorageUtil.StringListAdd(None, STORAGE_KEY_CHILD_NAME, name)
endFunction

int function GetTrackedChildCount()
    return StorageUtil.FormListCount(None, STORAGE_KEY_CHILD_FORM)
endFunction

string[] function SearchChildrenByName(string query)
    string[] kidNames = StorageUtil.StringListToArray(None, STORAGE_KEY_CHILD_NAME)
    string[] matchingNames

    int i = 0
    while i < kidNames.Length
        string name = kidNames[i]
        if StringUtil.Find(name, query) > -1
            if matchingNames
                matchingNames = Utility.ResizeStringArray(matchingNames, matchingNames.Length)
                matchingNames[matchingNames.Length - 1] = name
            else
                matchingNames = new string[1]
                matchingNames[0] = name
            endIf
        endIf
        i += 1
    endWhile

    return matchingNames
endFunction

bool function IsChildEnabled(string name)
    int childIndex = StorageUtil.StringListFind(None, STORAGE_KEY_CHILD_NAME, name)
    ObjectReference child = StorageUtil.FormListGet(None, STORAGE_KEY_CHILD_FORM, childIndex) as ObjectReference
    return child.IsEnabled()
endFunction

bool function IsChildTracked(Actor child)
    return StorageUtil.FormListFind(None, STORAGE_KEY_CHILD_FORM, child) > -1
endFunction

; Returns enabled state
bool function ToggleChildEnabled(string name)
    int childIndex = StorageUtil.StringListFind(None, STORAGE_KEY_CHILD_NAME, name)
    ObjectReference child = StorageUtil.FormListGet(None, STORAGE_KEY_CHILD_FORM, childIndex) as ObjectReference
    if child.IsEnabled()
        child.Disable()
        return false
    else
        child.Enable()
        return true
    endIf
endFunction
