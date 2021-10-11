scriptName NoKids_KidDetectionScript extends ActiveMagicEffect  

NoKids property API auto

event OnEffectStart(Actor target, Actor caster)
    if ! NoKids.IsChildTracked(target)
        NoKids.TrackChild(target)

        target.Disable()

        Form replacement = API.ReplacementForm
        if replacement
            target.PlaceAtMe(replacement, API.ReplacementFormCount)
        endIf
    endIf
endEvent
