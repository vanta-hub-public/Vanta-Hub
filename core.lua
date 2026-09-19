local LINORIA = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local function fetch(url) return game:HttpGet(url) end

local Library = loadstring(fetch(LINORIA .. "Library.lua"))()
local ThemeManager = loadstring(fetch(LINORIA .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(fetch(LINORIA .. "addons/SaveManager.lua"))()

local VERSION = "v0.1"

Library.ShowCustomCursor = false

ThemeManager.BuiltInThemes["Vanta (Black & White)"] = {
    1,
    {
        FontColor = "ffffff",
        MainColor = "0b0b0b",
        AccentColor = "ffffff",
        BackgroundColor = "000000",
        OutlineColor = "2b2b2b",
    },
}

local Window = Library:CreateWindow({
    Title = "Vanta",
    Center = true,
    AutoShow = true,
    Resizable = true,
})

local SettingsTab = Window:AddTab("Settings")
local ThemeBox = SettingsTab:AddLeftGroupbox("Theme")
local MiscBox = SettingsTab:AddRightGroupbox("Misc")

ThemeManager:SetLibrary(Library)
ThemeManager:CreateThemeManager(ThemeBox)
ThemeManager:ApplyTheme("Vanta (Black & White)")

MiscBox:AddToggle("CustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(value)
        Library.ShowCustomCursor = value
    end,
})

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Vanta/settings")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

MiscBox:AddLabel("Vanta " .. VERSION)
MiscBox:AddButton("Unload", function()
    Library:Unload()
end)

return {
    Library = Library,
    Window = Window,
    ThemeManager = ThemeManager,
    SaveManager = SaveManager,
    NewTab = function(name)
        return Window:AddTab(name)
    end,
}
