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
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function NoKidsStorage() global
    int kidsStorage = JDB.solveObj(".noKids")
    if ! kidsStorage
        kidsStorage = JMap.object()
        JDB.solveObjSetter(".noKids", kidsStorage, createMissingKeys = true)
        JMap.setObj(kidsStorage, "kidsByName", JMap.object())
        JMap.setObj(kidsStorage, "kidsEnabledByName", JMap.object())
    endIf
    return kidsStorage
endFunction

int function KidsByNameMap() global
    return JMap.getObj(NoKidsStorage(), "kidsByName")
endFunction

int function KidsEnabledByNameMap() global
    return JMap.getObj(NoKidsStorage(), "kidsEnabledByName")
endFunction

function TrackChild(Actor child) global
    string name = child.GetActorBase().GetName()
    JMap.setForm(KidsByNameMap(), name, child)
    JMap.setInt(KidsEnabledByNameMap(), name, 0)
endFunction

int function GetTrackedChildCount() global
    return JMap.count(KidsByNameMap())
endFunction

string[] function SearchChildrenByName(string query) global
    string[] kidNames = JMap.allKeysPArray(KidsByNameMap())
    int matchingNames = JArray.object()

    int i = 0
    while i < kidNames.Length
        string name = kidNames[i]
        if StringUtil.Find(name, query) > -1
            JArray.addStr(matchingNames, name)
        endIf
        i += 1
    endWhile

    return JArray.asStringArray(matchingNames)
endFunction

bool function IsChildEnabled(string name) global
    return JMap.getInt(KidsEnabledByNameMap(), name) == 1
endFunction

bool function IsChildTracked(Actor child) global
    return JMap.hasKey(KidsByNameMap(), child.GetActorBase().GetName())
endFunction

; Returns enabled state
bool function ToggleChildEnabled(string name) global
    Actor kiddo = JMap.getForm(KidsByNameMap(), name) as Actor
    bool enabled = JMap.getInt(KidsEnabledByNameMap(), name) == 1
    if enabled
        ; Disable
        JMap.setInt(KidsEnabledByNameMap(), name, 0)
        kiddo.Disable()
    else
        ; Enable
        JMap.setInt(KidsEnabledByNameMap(), name, 1)
        kiddo.Enable()
    endIf
    return ! enabled
endFunction

; Hmmmmm? Will all children have unique names?
Actor function GetChildByName(string name) global
endFunction
