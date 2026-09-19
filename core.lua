--------------------------------------------------------------------
-- VANTA — CORE
-- Loads LinoriaLib, registers/applies Vanta's default Black & White
-- theme, builds the Window plus Home + Settings tabs, and returns a
-- small API table that every per-game module builds on top of.
--------------------------------------------------------------------

local LINORIA = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local function fetch(url)
    return game:HttpGet(url)
end

local Library      = loadstring(fetch(LINORIA .. "Library.lua"))()
local ThemeManager  = loadstring(fetch(LINORIA .. "addons/ThemeManager.lua"))()
local SaveManager   = loadstring(fetch(LINORIA .. "addons/SaveManager.lua"))()

-- Vanta's default theme: pure black & white, registered alongside
-- whatever built-in themes ship with LinoriaLib itself.
ThemeManager.BuiltInThemes["Vanta (Black & White)"] = {
    1,
    {
        FontColor       = "ffffff",
        MainColor       = "0b0b0b",
        AccentColor     = "ffffff",
        BackgroundColor = "000000",
        OutlineColor    = "2b2b2b",
    },
}

local Window = Library:CreateWindow({
    Title     = "Vanta",
    Center    = true,
    AutoShow  = true,
    Resizable = true,
})

----------------------------------------------------------------
-- Home tab: general info + Unload. Split by category (groupbox),
-- not blank lines.
----------------------------------------------------------------
local HomeTab = Window:AddTab("Home")
local AboutBox = HomeTab:AddLeftGroupbox("Vanta")

AboutBox:AddLabel("Multi-game utility hub.")
AboutBox:AddLabel("Game-specific categories appear automatically once loaded.")
AboutBox:AddDivider()
AboutBox:AddButton("Unload Vanta", function()
    Library:Unload()
end)

----------------------------------------------------------------
-- Settings tab: theme category + config category, using
-- LinoriaLib's own addons rather than hand-rolled versions.
----------------------------------------------------------------
local SettingsTab = Window:AddTab("Settings")
local ThemeBox  = SettingsTab:AddLeftGroupbox("Theme")
local ConfigBox = SettingsTab:AddRightGroupbox("Config")

ThemeManager:SetLibrary(Library)
ThemeManager:CreateThemeManager(ThemeBox)
ThemeManager:ApplyTheme("Vanta (Black & White)")

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Vanta/settings")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(ConfigBox)
SaveManager:LoadAutoloadConfig()

ConfigBox:AddDivider()
ConfigBox:AddButton("Unload Vanta", function()
    Library:Unload()
end)

----------------------------------------------------------------
-- Public API handed to Loader.lua and every game module.
----------------------------------------------------------------
return {
    Library      = Library,
    Window       = Window,
    ThemeManager = ThemeManager,
    SaveManager  = SaveManager,

    -- Game modules should use this instead of touching Window directly,
    -- so Core stays the only place that owns window setup.
    NewTab = function(name)
        return Window:AddTab(name)
    end,
}
