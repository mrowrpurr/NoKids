scriptName NoKids_KidDetectionScript extends ActiveMagicEffect  

NoKids property API auto

event OnEffectStart(Actor target, Actor caster)
    if ! API.ModEnabled
        return
    endIf

    if ! API.IsChildTracked(target)
        API.TrackChild(target)

        Form replacement = API.GetReplacementForm()

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
