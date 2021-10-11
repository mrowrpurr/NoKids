scriptName NoKids_KidDetectionScript extends ActiveMagicEffect  

NoKids property API auto

event OnEffectStart(Actor target, Actor caster)
    if ! API.ModEnabled
        return
    endIf

    if ! NoKids.IsChildTracked(target)
        NoKids.TrackChild(target)
        Form replacement = API.ReplacementForm

        if replacement
            if API.ReplacementNotifications
                Debug.Notification(target.GetActorBase().GetName() + " replaced with " + API.ReplacementFormCount + "x " + replacement.GetName())
            endIf
            target.Disable()
            target.PlaceAtMe(replacement, API.ReplacementFormCount)
        else
            if API.ReplacementNotifications
                Debug.Notification(target.GetActorBase().GetName() + " hidden")
            endIf
            target.Disable()
        endIf
    endIf
endEvent
