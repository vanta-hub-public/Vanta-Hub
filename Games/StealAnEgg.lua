return {
    Init = function(Vanta)
        local Library = Vanta.Library
        local Toggles = Vanta.Toggles
        local Options = Vanta.Options
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local function safePath(...)
            local current = workspace
            for _, name in ipairs({...}) do
                if not current then return nil end
                current = current:FindFirstChild(name)
            end
            return current
        end

        local function getPos(obj)
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj.Position end
            if obj:IsA("Model") then
                local cf = obj:GetBoundingBox()
                return cf.Position
            end
            if obj.PrimaryPart then return obj.PrimaryPart.Position end
            return obj:GetPivot().Position
        end

        local function findNearest(container, fromPos)
            local nearest, nearestDist
            if container then
                for _, obj in ipairs(container:GetChildren()) do
                    local pos = getPos(obj)
                    if pos then
                        local dist = (pos - fromPos).Magnitude
                        if not nearestDist or dist < nearestDist then
                            nearest, nearestDist = obj, dist
                        end
                    end
                end
            end
            return nearest
        end

        local function walkTo(humanoid, obj)
            local pos = getPos(obj)
            if not pos then return end
            humanoid:MoveTo(pos)
            humanoid.MoveToFinished:Wait()
        end

        local MainTab = Vanta.NewTab("Main")
        local FarmGroup = MainTab:AddLeftGroupbox("Farm")

        local originalDurations = {}
        local promptConnection

        local function applyInstantPrompt(prompt)
            if originalDurations[prompt] == nil then
                originalDurations[prompt] = prompt.HoldDuration
            end
            prompt.HoldDuration = 0
        end

        FarmGroup:AddToggle("InstantPrompt", {
            Text = "Instant Proximity Prompt",
            Default = false,
            Callback = function(value)
                if value then
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            applyInstantPrompt(prompt)
                        end
                    end
                    promptConnection = workspace.DescendantAdded:Connect(function(obj)
                        if obj:IsA("ProximityPrompt") then
                            applyInstantPrompt(obj)
                        end
                    end)
                else
                    if promptConnection then
                        promptConnection:Disconnect()
                        promptConnection = nil
                    end
                    for prompt, duration in pairs(originalDurations) do
                        prompt.HoldDuration = duration
                    end
                    originalDurations = {}
                end
            end,
        })

        local guardAreas = safePath("World", "Areas", "GuardAreas")
        local areaNames = {}
        if guardAreas then
            for _, area in ipairs(guardAreas:GetChildren()) do
                table.insert(areaNames, area.Name)
            end
        end
        if #areaNames == 0 then areaNames = { "None" } end

        FarmGroup:AddDropdown("StealArea", {
            Values = areaNames,
            Default = 1,
            Multi = false,
            Text = "Area",
        })

        FarmGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal",
            Default = false,
        })

        Toggles.AutoSteal:OnChanged(function()
            if not Toggles.AutoSteal.Value then return end
            Toggles.InstantPrompt:SetValue(true)

            task.spawn(function()
                while Toggles.AutoSteal.Value do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                    if hrp and humanoid then
                        local areaModel = guardAreas and guardAreas:FindFirstChild(Options.StealArea.Value)
                        local boundsTarget = areaModel and areaModel:FindFirstChild("Bounds", true)
                        walkTo(humanoid, boundsTarget)

                        local slotsFolder = workspace:FindFirstChild("AreaEggSlotsClient")
                        local nearestSlot = findNearest(slotsFolder, hrp.Position)
                        walkTo(humanoid, nearestSlot)

                        local prompt = nearestSlot and nearestSlot:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function()
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.2)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end

                        local basesFolder = safePath("World", "Build", "MainMap", "Bases")
                        local baseTarget = basesFolder and basesFolder:GetChildren()[10]
                        walkTo(humanoid, baseTarget)
                    end

                    task.wait(1)
                end
            end)
        end)
    end,
}
