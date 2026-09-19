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

        local Tab = Vanta.NewTab("World 1")
        local MainGroup = Tab:AddLeftGroupbox("Automations")
        local FarmGroup = Tab:AddRightGroupbox("Farm Settings")

        MainGroup:AddToggle("AutoTap", {
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

        MainGroup:AddToggle("AutoRebirth", {
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

        FarmGroup:AddToggle("AutoFarmRebirths", {
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

                    local angelBase = workspace:FindFirstChild("TrainingArea")
                        and workspace.TrainingArea:FindFirstChild("Angel")
                        and workspace.TrainingArea.Angel:FindFirstChild("Base")

                    if angelBase then
                        local targetCFrame = getModelCFrame(angelBase)
                        if targetCFrame then
                            newHumanoid:MoveTo(targetCFrame.Position)
                        end
                    end

                    task.wait(30)
                end
            end)
        end)

        FarmGroup:AddDivider()

        local checkpointList = {}
        for i = 1, 24 do
            table.insert(checkpointList, "Checkpoint" .. i)
        end

        FarmGroup:AddDropdown("SelectedCheckpoint", {
            Values = checkpointList,
            Default = 1,
            Multi = false,
            Text = "Target Checkpoint",
        })

        FarmGroup:AddToggle("AutoFarmWins", {
            Text = "Auto Farm Wins",
            Default = false,
        })

        Toggles.AutoFarmWins:OnChanged(function()
            if not Toggles.AutoFarmWins.Value then return end

            task.spawn(function()
                while Toggles.AutoFarmWins.Value do
                    local selectedName = Options.SelectedCheckpoint.Value
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
                            until #enemiesFolder:GetChildren() == 0 or not Toggles.AutoFarmWins.Value
                        end

                        if not Toggles.AutoFarmWins.Value then break end

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
