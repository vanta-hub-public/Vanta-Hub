local LINORIA = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local function fetch(url) return game:HttpGet(url) end

local Library = loadstring(fetch(LINORIA .. "Library.lua"))()
local ThemeManager = loadstring(fetch(LINORIA .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(fetch(LINORIA .. "addons/SaveManager.lua"))()

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

local HomeTab = Window:AddTab("Home")
local HomeBox = HomeTab:AddLeftGroupbox("Vanta")
HomeBox:AddButton("Unload", function()
    Library:Unload()
end)

local SettingsTab = Window:AddTab("Settings")
local ThemeBox = SettingsTab:AddLeftGroupbox("Theme")

ThemeManager:SetLibrary(Library)
ThemeManager:CreateThemeManager(ThemeBox)
ThemeManager:ApplyTheme("Vanta (Black & White)")

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Vanta/settings")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

return {
    Library = Library,
    Window = Window,
    ThemeManager = ThemeManager,
    SaveManager = SaveManager,
    NewTab = function(name)
        return Window:AddTab(name)
    end,
}
