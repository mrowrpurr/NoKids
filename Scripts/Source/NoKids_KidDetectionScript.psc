scriptName NoKids_KidDetectionScript extends ActiveMagicEffect  

NoKidsMCM property Config auto

event OnEffectStart(Actor target, Actor caster)
    if ! NoKids.IsChildTracked(target)
        NoKids.TrackChild(target)

        target.Disable()

        Form replacement = Config.CurrentChildReplacementBaseForm
        if replacement
            target.PlaceAtMe(replacement, 60)
        endIf
    endIf
endEvent
