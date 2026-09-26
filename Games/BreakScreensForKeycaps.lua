return {
    Init = function(Vanta)
        local Library = Vanta.Library
        local Toggles = Vanta.Toggles
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer

        local function safePath(...)
            local current = workspace
            for _, name in ipairs({...}) do
                if not current then return nil end
                current = current:FindFirstChild(name)
            end
            return current
        end

        local function getCFrame(obj)
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj.CFrame end
            if obj.PrimaryPart then return obj.PrimaryPart.CFrame end
            return obj:GetPivot()
        end

        local function getPos(obj)
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj.Position end
            if obj.PrimaryPart then return obj.PrimaryPart.Position end
            return obj:GetPivot().Position
        end

        local function resolvePart(obj)
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj end
            if obj.PrimaryPart then return obj.PrimaryPart end
            return obj:FindFirstChildWhichIsA("BasePart", true)
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

        local function walkToNoclip(character, humanoid, hrp, targetPos)
            local connection
            connection = RunService.Stepped:Connect(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            humanoid:MoveTo(targetPos)
            humanoid.MoveToFinished:Wait()

            connection:Disconnect()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

        local MainTab = Vanta.NewTab("Main")
        local FarmGroup = MainTab:AddLeftGroupbox("Farm")

        FarmGroup:AddToggle("AutoFarm", {
            Text = "Auto Farm",
            Default = false,
        })

        Toggles.AutoFarm:OnChanged(function()
            if not Toggles.AutoFarm.Value then return end

            task.spawn(function()
                while Toggles.AutoFarm.Value do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                    if hrp and humanoid then
                        local screenFolder = safePath("Lobby", "Main", "Screen", "Screen")
                        if screenFolder then
                            for i = 1, 38 do
                                if not Toggles.AutoFarm.Value then break end
                                local screenCFrame = getCFrame(screenFolder:FindFirstChild("Screen" .. i))
                                if screenCFrame then
                                    hrp.CFrame = screenCFrame
                                end
                                task.wait(0.25)
                            end

                            local lastCFrame = getCFrame(screenFolder:FindFirstChild("Screen38"))
                            if lastCFrame then
                                hrp.CFrame = lastCFrame
                            end

                            local secretPos = getPos(safePath("Regions", "Secret"))
                            if secretPos then
                                walkToNoclip(char, humanoid, hrp, secretPos)
                            end
                        end

                        local keycapsFolder = workspace:FindFirstChild("KeycapPickups")
                        walkTo(humanoid, findNearest(keycapsFolder, hrp.Position))

                        pcall(function()
                            local vim = game:GetService("VirtualInputManager")
                            vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end)

                        local touchPart = resolvePart(safePath("Lobby", "EndRun", "TouchInterest"))
                        if touchPart and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, touchPart, 0)
                                task.wait(0.1)
                                firetouchinterest(hrp, touchPart, 1)
                            end)
                        end

                        walkTo(humanoid, findNearest(keycapsFolder, hrp.Position))
                    end

                    task.wait(1)
                end
            end)
        end)
    end,
}
