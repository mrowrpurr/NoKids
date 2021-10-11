scriptName NoKids extends Quest
{Stores the tracked children}

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
