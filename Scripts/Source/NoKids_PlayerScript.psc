scriptName NoKids_PlayerScript extends ReferenceAlias  

string FILENAME = "../../../NoKids/Config.json"

event OnInit()
    ; JsonUtil.SetStringValue(FILENAME, "Enabled", "true")
    ; JsonUtil.SetFormValue(FILENAME, "Replacement", Game.GetForm(0x4D6E7))
    ; JsonUtil.SetIntValue(FILENAME, "ReplacementCount", 30)
    ; JsonUtil.Save(FILENAME)
endEvent
