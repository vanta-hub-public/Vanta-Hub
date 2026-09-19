--------------------------------------------------------------------
-- Loaded automatically when the current game's PlaceId isn't in
-- Loader.lua's GAME_MODULES table yet.
--------------------------------------------------------------------
return {
    Init = function(Vanta)
        local Tab = Vanta.NewTab("Unsupported Game")
        local Box = Tab:AddLeftGroupbox("Heads up")

        Box:AddLabel("No Vanta module exists for this game yet.")
        Box:AddLabel(("PlaceId: %d"):format(game.PlaceId))
        Box:AddLabel("Add one under Games/ and register it in Loader.lua.")
    end,
}
