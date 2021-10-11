scriptName NoKids_LoadGameHandler extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as NoKids).PlayerLoadGame()
endEvent
