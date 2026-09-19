local LINORIA = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local UserInputService = game:GetService("UserInputService")

local function fetch(url) return game:HttpGet(url) end

local Library = loadstring(fetch(LINORIA .. "Library.lua"))()
local SaveManager = loadstring(fetch(LINORIA .. "addons/SaveManager.lua"))()

local VERSION = "v0.4"
local CONFIG_NAME = "autosave"

Library.FontColor = Color3.fromHex("ffffff")
Library.MainColor = Color3.fromHex("0b0b0b")
Library.AccentColor = Color3.fromHex("ffffff")
Library.BackgroundColor = Color3.fromHex("000000")
Library.OutlineColor = Color3.fromHex("2b2b2b")

Library.ShowCustomCursor = false
UserInputService.MouseIconEnabled = true

local Window = Library:CreateWindow({
    Title = "Vanta",
    Center = true,
    AutoShow = true,
    Resizable = true,
})

local Vanta = {
    Library = Library,
    Window = Window,
    Toggles = Toggles,
    Options = Options,
    NewTab = function(name)
        return Window:AddTab(name)
    end,
}

function Vanta.FinalizeSettings()
    local SettingsTab = Window:AddTab("Settings")
    local MiscBox = SettingsTab:AddLeftGroupbox("Misc")

    MiscBox:AddToggle("CustomCursor", {
        Text = "Custom Cursor",
        Default = false,
        Callback = function(value)
            Library.ShowCustomCursor = value
            UserInputService.MouseIconEnabled = not value
        end,
    })

    MiscBox:AddLabel("Vanta " .. VERSION)
    MiscBox:AddButton("Unload", function()
        pcall(function() SaveManager:Save(CONFIG_NAME) end)
        Library:Unload()
    end)

    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("Vanta/" .. tostring(game.PlaceId))
    pcall(function() SaveManager:Load(CONFIG_NAME) end)

    task.spawn(function()
        while task.wait(10) do
            pcall(function() SaveManager:Save(CONFIG_NAME) end)
        end
    end)
end

return Vanta
