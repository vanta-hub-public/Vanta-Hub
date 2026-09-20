return {
    Init = function(Vanta)
        local Library = Vanta.Library
        local Toggles = Vanta.Toggles
        local Options = Vanta.Options
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local LocalPlayer = Players.LocalPlayer

        local TapEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tap")
        local RebirthEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RequestRebirth")

        local function getModelCFrame(model)
            if not model then return nil end
            if model:IsA("BasePart") then return model.CFrame end
            if model.PrimaryPart then return model.PrimaryPart.CFrame end
            return model:GetPivot()
        end

        local function teleportToCFrame(cframe)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cframe
            end
        end

        local function safePath(...)
            local current = workspace
            for _, name in ipairs({...}) do
                if not current then return nil end
                current = current:FindFirstChild(name)
            end
            return current
        end

        local World1Treadmills = {
            Basic = function()
                local base = safePath("TrainingArea", "Basic", "Base")
                return base and base:FindFirstChild("Part")
            end,
            Skeleton = function()
                local base = safePath("TrainingArea", "Sekeleton", "Base")
                return base and base:FindFirstChild("Part")
            end,
            Gold = function()
                local base = safePath("TrainingArea", "Gold", "Base")
                return base and base:GetChildren()[5]
            end,
            Diamond = function()
                local base = safePath("TrainingArea", "Diamond", "Base")
                return base and base:GetChildren()[5]
            end,
            Magma = function()
                local base = safePath("TrainingArea", "Magma", "Base")
                return base and base:GetChildren()[2]
            end,
            Toxic = function()
                local base = safePath("TrainingArea", "Toxic", "Base")
                return base and base:GetChildren()[7]
            end,
            Angel = function()
                local base = safePath("TrainingArea", "Angel", "Base")
                return base and base:FindFirstChild("Part")
            end,
        }

        local World2Treadmills = {
            Base = function()
                local base = safePath("World2", "TrainingAreas", "Basic", "Base")
                return base and base:GetChildren()[3]
            end,
            Skeleton = function()
                local base = safePath("World2", "TrainingAreas", "Sekeleton", "Base")
                return base and base:GetChildren()[2]
            end,
            Gold = function()
                local base = safePath("World2", "TrainingAreas", "Gold", "Base")
                return base and base:GetChildren()[4]
            end,
            Diamond = function()
                local base = safePath("World2", "TrainingAreas", "Diamond", "Base")
                return base and base:GetChildren()[2]
            end,
            Magma = function()
                local base = safePath("World2", "TrainingAreas", "Magma", "Base")
                return base and base:GetChildren()[8]
            end,
            Toxic = function()
                local base = safePath("World2", "TrainingAreas", "Toxic", "Base")
                return base and base:GetChildren()[4]
            end,
        }

        local AllWorldsTab = Vanta.NewTab("All Worlds")
        local AutomationsGroup = AllWorldsTab:AddLeftGroupbox("Automations")

        AutomationsGroup:AddToggle("AutoTap", {
            Text = "Auto Tap",
            Default = false,
        })

        Toggles.AutoTap:OnChanged(function()
            if Toggles.AutoTap.Value then
                task.spawn(function()
                    while Toggles.AutoTap.Value do
                        TapEvent:FireServer()
                        task.wait(0.1)
                    end
                end)
            end
        end)

        AutomationsGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
        })

        Toggles.AutoRebirth:OnChanged(function()
            if Toggles.AutoRebirth.Value then
                task.spawn(function()
                    while Toggles.AutoRebirth.Value do
                        RebirthEvent:InvokeServer()
                        task.wait(1)
                    end
                end)
            end
        end)

        local World1Tab = Vanta.NewTab("World 1")
        local World1Farms = World1Tab:AddLeftGroupbox("Farms")

        World1Farms:AddDropdown("World1Treadmill", {
            Values = { "Basic", "Skeleton", "Gold", "Diamond", "Magma", "Toxic", "Angel" },
            Default = 1,
            Multi = false,
            Text = "Target Treadmill",
        })

        World1Farms:AddToggle("AutoFarmRebirths", {
            Text = "Auto Farm Rebirths",
            Default = false,
        })

        Toggles.AutoFarmRebirths:OnChanged(function()
            local enabled = Toggles.AutoFarmRebirths.Value
            Toggles.AutoTap:SetValue(enabled)
            Toggles.AutoRebirth:SetValue(enabled)

            if not enabled then return end

            task.spawn(function()
                while Toggles.AutoFarmRebirths.Value do
                    local char = LocalPlayer.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end

                    local newChar = LocalPlayer.CharacterAdded:Wait()
                    local newHumanoid = newChar:WaitForChild("Humanoid")

                    if not Toggles.AutoFarmRebirths.Value then break end

                    local getTarget = World1Treadmills[Options.World1Treadmill.Value]
                    local target = getTarget and getTarget()

                    if target then
                        local targetCFrame = getModelCFrame(target)
                        if targetCFrame then
                            newHumanoid:MoveTo(targetCFrame.Position)
                        end
                    end

                    task.wait(30)
                end
            end)
        end)

        local world1Checkpoints = {}
        for i = 1, 24 do
            table.insert(world1Checkpoints, "Checkpoint" .. i)
        end

        World1Farms:AddDropdown("World1Checkpoint", {
            Values = world1Checkpoints,
            Default = 1,
            Multi = false,
            Text = "Target Checkpoint",
        })

        World1Farms:AddToggle("World1AutoFarmWins", {
            Text = "Auto Farm Wins",
            Default = false,
        })

        Toggles.World1AutoFarmWins:OnChanged(function()
            if not Toggles.World1AutoFarmWins.Value then return end

            task.spawn(function()
                while Toggles.World1AutoFarmWins.Value do
                    local selectedName = Options.World1Checkpoint.Value
                    local checkpointsFolder = workspace:FindFirstChild("Checkpoints")
                    local selectedCheckpoint = checkpointsFolder and checkpointsFolder:FindFirstChild(selectedName)

                    if selectedCheckpoint then
                        local detailModel = selectedCheckpoint:FindFirstChild("Detail")
                        if detailModel then
                            local detailCFrame = getModelCFrame(detailModel)
                            if detailCFrame then
                                teleportToCFrame(detailCFrame * CFrame.new(0, 10, -30))
                            end
                        end

                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            repeat
                                task.wait(0.5)
                            until #enemiesFolder:GetChildren() == 0 or not Toggles.World1AutoFarmWins.Value
                        end

                        if not Toggles.World1AutoFarmWins.Value then break end

                        task.wait(1)

                        local winPad = selectedCheckpoint:FindFirstChild("WinPad")
                        if winPad and LocalPlayer.Character then
                            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local winPadCFrame = getModelCFrame(winPad)
                            if humanoid and winPadCFrame then
                                humanoid:MoveTo(winPadCFrame.Position)
                                humanoid.MoveToFinished:Wait()
                            end
                        end
                    end

                    task.wait(1)
                end
            end)
        end)

        local World2Tab = Vanta.NewTab("World 2")
        local World2Farms = World2Tab:AddLeftGroupbox("Farms")

        World2Farms:AddDropdown("World2Treadmill", {
            Values = { "Base", "Skeleton", "Gold", "Diamond", "Magma", "Toxic" },
            Default = 1,
            Multi = false,
            Text = "Target Treadmill",
        })

        World2Farms:AddToggle("World2AutoFarmRebirths", {
            Text = "Auto Farm Rebirths",
            Default = false,
        })

        Toggles.World2AutoFarmRebirths:OnChanged(function()
            local enabled = Toggles.World2AutoFarmRebirths.Value
            Toggles.AutoTap:SetValue(enabled)
            Toggles.AutoRebirth:SetValue(enabled)

            if not enabled then return end

            task.spawn(function()
                while Toggles.World2AutoFarmRebirths.Value do
                    local char = LocalPlayer.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end

                    local newChar = LocalPlayer.CharacterAdded:Wait()
                    local newHumanoid = newChar:WaitForChild("Humanoid")

                    if not Toggles.World2AutoFarmRebirths.Value then break end

                    local getTarget = World2Treadmills[Options.World2Treadmill.Value]
                    local target = getTarget and getTarget()

                    if target then
                        local targetCFrame = getModelCFrame(target)
                        if targetCFrame then
                            newHumanoid:MoveTo(targetCFrame.Position)
                        end
                    end

                    task.wait(30)
                end
            end)
        end)

        local world2Checkpoints = {}
        for i = 25, 39 do
            table.insert(world2Checkpoints, "Checkpoint" .. i)
        end

        World2Farms:AddDropdown("World2Checkpoint", {
            Values = world2Checkpoints,
            Default = 1,
            Multi = false,
            Text = "Target Checkpoint",
        })

        World2Farms:AddToggle("World2AutoFarmWins", {
            Text = "Auto Farm Wins",
            Default = false,
        })

        Toggles.World2AutoFarmWins:OnChanged(function()
            if not Toggles.World2AutoFarmWins.Value then return end

            task.spawn(function()
                while Toggles.World2AutoFarmWins.Value do
                    local selectedName = Options.World2Checkpoint.Value
                    local checkpointsFolder = workspace:FindFirstChild("World2")
                        and workspace.World2:FindFirstChild("Zones")
                        and workspace.World2.Zones:FindFirstChild("Checkpoints")
                    local selectedCheckpoint = checkpointsFolder and checkpointsFolder:FindFirstChild(selectedName)

                    if selectedCheckpoint then
                        local detailModel = selectedCheckpoint:FindFirstChild("Detail")
                        if detailModel then
                            local detailCFrame = getModelCFrame(detailModel)
                            if detailCFrame then
                                teleportToCFrame(detailCFrame * CFrame.new(0, 10, -30))
                            end
                        end

                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            repeat
                                task.wait(0.5)
                            until #enemiesFolder:GetChildren() == 0 or not Toggles.World2AutoFarmWins.Value
                        end

                        if not Toggles.World2AutoFarmWins.Value then break end

                        task.wait(1)

                        local winPad = selectedCheckpoint:FindFirstChild("WinPad")
                        if winPad and LocalPlayer.Character then
                            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local winPadCFrame = getModelCFrame(winPad)
                            if humanoid and winPadCFrame then
                                humanoid:MoveTo(winPadCFrame.Position)
                                humanoid.MoveToFinished:Wait()
                            end
                        end
                    end

                    task.wait(1)
                end
            end)
        end)
    end,
}
