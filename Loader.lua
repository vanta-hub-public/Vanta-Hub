local REPO = "https://raw.githubusercontent.com/vanta-hub-public/Vanta-Hub/main/"

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

local Vanta = load("Core.lua")

local GAME_MODULES = {
    [103138601755519] = "Games/DinoEvolution.lua",
}

local modulePath = GAME_MODULES[game.PlaceId] or "Games/_Generic.lua"
local ok, GameModule = pcall(load, modulePath)

if ok and type(GameModule) == "table" and type(GameModule.Init) == "function" then
    GameModule.Init(Vanta)
else
    warn("[Vanta] Game module '" .. modulePath .. "' failed to load: " .. tostring(GameModule))
end

Vanta.FinalizeSettings()
Vanta.Library:Notify("Vanta loaded.", 3)
