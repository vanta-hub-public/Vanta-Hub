return {
    Init = function(Vanta)
        local Tab = Vanta.NewTab("Main")
        local Box = Tab:AddLeftGroupbox("Movement")

        Box:AddSlider("WalkSpeed", {
            Text = "Walk Speed",
            Default = 16,
            Min = 16,
            Max = 200,
            Rounding = 0,
            Callback = function(value)
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = value
                end
            end,
        })
    end,
}
