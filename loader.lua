--------------------------------------------------------------------
-- VANTA — LOADER
-- This is the ONLY script you execute. Everything else is fetched
-- over HTTP at runtime, so every user always gets the latest build
-- without re-downloading or re-pasting anything.
--------------------------------------------------------------------

-- 1) Where your files are hosted. See README.md for the two options
--    (raw.githubusercontent.com vs jsDelivr) and pick one.
local REPO = "https://raw.githubusercontent.com/YOUR-USERNAME/Vanta/main/"

-- 2) Small fetch/compile helpers so one bad request gives you a real
--    error instead of a silent crash.
local function fetch(path)
    local ok, result = pcall(game.HttpGet, game, REPO .. path .. "?t=" .. tostring(os.time()))
    if not ok then
        error(("[Vanta] Failed to fetch '%s': %s"):format(path, tostring(result)), 0)
    end
    return result
end

local function load(path, ...)
    local source = fetch(path)
    local fn, err = loadstring(source, "=Vanta/" .. path)
    if not fn then
        error(("[Vanta] Failed to compile '%s': %s"):format(path, tostring(err)), 0)
    end
    return fn(...)
end

-- 3) Boot the shared framework: LinoriaLib, theme, window, Home/Settings tabs.
local Vanta = load("Core.lua")

-- 4) Route to the right game module by PlaceId. Add one line per game
--    you support; everything else falls back to Games/_Generic.lua.
local GAME_MODULES = {
    -- [920587237] = "Games/ExampleGame.lua",   -- replace with real PlaceIds
    -- [271000000] = "Games/AnotherGame.lua",
}

local modulePath = GAME_MODULES[game.PlaceId] or "Games/_Generic.lua"
local ok, GameModule = pcall(load, modulePath)

if ok and type(GameModule) == "table" and type(GameModule.Init) == "function" then
    GameModule.Init(Vanta)
else
    warn("[Vanta] Game module '" .. modulePath .. "' failed to load: " .. tostring(GameModule))
end

Vanta.Library:Notify("Vanta loaded.", 3)
