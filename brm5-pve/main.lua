-- Fire HUB PvE Main (BRM5 Ronograd)
if typeof(clear) == "function" then clear() end

local MAIN_VERSION = "1.0"
local GITHUB_BASE = "https://raw.githubusercontent.com/jatinyadav2006109-crypto/brm5-pve/main/brm5-pve/modules/"
local CACHE_BUSTER = MAIN_VERSION .. "-" .. tostring(os.time())

local function loadModule(name)
    local url = GITHUB_BASE .. name .. ".lua?v=" .. CACHE_BUSTER
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or type(res) ~= "string" or res == "" then
        error("Failed to download module: " .. name)
    end
    local fn, err = loadstring(res)
    if not fn then error("Compile error in " .. name .. ": " .. tostring(err)) end
    local success, result = pcall(fn)
    if not success then error("Runtime error in " .. name .. ": " .. tostring(result)) end
    return result
end

local Services = loadModule("services")
local Config = loadModule("config")
local NPCManager = loadModule("npc_manager")
local HitboxAim = loadModule("silent")    -- contains aimbot + hitbox expander
local ESP = loadModule("walls")           -- ESP markers
local Lighting = loadModule("fullbright")
local Weapons = loadModule("norecoil")
local GUI = loadModule("gui")

Config:load()
Lighting:storeOriginalSettings(Services.Lighting)

local runtimeConnections = {}

local function saveConfig() Config:save() end

local function syncMouseState()
    if Config.guiVisible then
        Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Services.UserInputService.MouseIconEnabled = true
    end
end

local function forceMouseLock()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    Services.UserInputService.MouseIconEnabled = false
end

local function toggleGUIVisibility()
    local wasVisible = Config.guiVisible
    Config.guiVisible = GUI:toggleVisibility()
    if Config.guiVisible then
        syncMouseState()
    elseif wasVisible then
        forceMouseLock()
    end
end

local function disconnectRuntime()
    for _, c in ipairs(runtimeConnections) do pcall(function() c:Disconnect() end) end
    runtimeConnections = {}
end

-- Callbacks from the GUI
local callbacks = {
    onAimToggle = function(enabled)
        Config.aimEnabled = enabled
        saveConfig()
    end,
    onHitboxToggle = function(enabled)
        Config.hitboxExpanderEnabled = enabled
        saveConfig()
    end,
    onHitboxMultiplierChange = function(val)
        Config.hitboxExpander = val
        saveConfig()
    end,
    onFOVChange = function(val)
        Config.fovRadius = val
        saveConfig()
    end,
    onSmoothingChange = function(val)
        Config.smoothing = val
        saveConfig()
    end,
    onSilentAimToggle = function(enabled)
        Config.silentAim = enabled
        saveConfig()
    end,
    onLockTargetToggle = function(enabled)
        Config.lockTarget = enabled
        saveConfig()
    end,
    onWallCheckToggle = function(enabled)
        Config.wallCheck = enabled
        saveConfig()
    end,
    onESPToggle = function(enabled)
        Config.espEnabled = enabled
        if not enabled then ESP.cleanup() end
        saveConfig()
    end,
    onBoxToggle = function(enabled) Config.showBox = enabled; ESP.refreshAll(NPCManager, Config) end,
    onTracerToggle = function(enabled) Config.showTracer = enabled; ESP.refreshAll(NPCManager, Config) end,
    onNameToggle = function(enabled) Config.showName = enabled; ESP.refreshAll(NPCManager, Config) end,
    onDistanceToggle = function(enabled) Config.showDistance = enabled; ESP.refreshAll(NPCManager, Config) end,
    onHealthToggle = function(enabled) Config.showHealth = enabled; ESP.refreshAll(NPCManager, Config) end,
    onESPWallCheckToggle = function(enabled) Config.espWallCheck = enabled; ESP.refreshAll(NPCManager, Config) end,
    onShowInvisibleToggle = function(enabled) Config.showInvisible = enabled; ESP.refreshAll(NPCManager, Config) end,
    onFullBrightToggle = function(enabled)
        Config.fullBrightEnabled = enabled
        if not enabled then Lighting:restoreOriginal(Services.Lighting) end
        saveConfig()
    end,
    onNoRecoilToggle = function(enabled)
        Config.patchOptions.recoil = enabled
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,
    onFiremodeToggle = function(enabled)
        Config.patchOptions.firemodes = enabled
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,
    onVisibilityToggle = function()
        toggleGUIVisibility()
    end,
    onUnload = function()
        if Config.isUnloaded then return end
        Config.isUnloaded = true
        disconnectRuntime()
        ESP.cleanup()
        HitboxAim.cleanup()
        Lighting:restoreOriginal(Services.Lighting)
        Config.guiVisible = false
        saveConfig()
        forceMouseLock()
        GUI:destroy()
    end
}

GUI:init(Services, Config, callbacks)
syncMouseState()

-- Initial setup
NPCManager:scanWorkspace(Services.Workspace, ESP, Config)
NPCManager:setupListener(Services.Workspace, ESP, Config)
if Config.espEnabled then ESP.enable(NPCManager, Config) end
if Config.patchOptions.recoil or Config.patchOptions.firemodes then
    Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
end

local npcRefreshTimer = 0
local espColorTimer = 0

table.insert(runtimeConnections, Services.RunService.Heartbeat:Connect(function(dt)
    if Config.isUnloaded then return end

    if Config.guiVisible then syncMouseState() end
    Lighting:update(Services.Lighting, Config)

    npcRefreshTimer = npcRefreshTimer + dt
    if npcRefreshTimer >= Config.NPC_REFRESH_INTERVAL then
        NPCManager:refreshTrackedNPCs(Services.Workspace, ESP, HitboxAim, Config)
        npcRefreshTimer = 0
    end

    espColorTimer = espColorTimer + dt
    if espColorTimer >= Config.ESP_COLOR_UPDATE_INTERVAL then
        ESP.updateColors(NPCManager, Services.Workspace.CurrentCamera, Services.Workspace, Services.localPlayer, Config)
        espColorTimer = 0
    end

    -- Aimbot
    if Config.aimEnabled and HitboxAim.holdingRightClick then
        local target = HitboxAim:getClosestValidTarget(NPCManager, Services.Workspace.CurrentCamera, Config)
        if target then
            HitboxAim:aimAtTarget(target, Services.Workspace.CurrentCamera, Config)
        end
    end
end))

-- Input hooks
table.insert(runtimeConnections, Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Config.isUnloaded then return end
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        toggleGUIVisibility()
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HitboxAim:setHoldingRightClick(true)
    end
end))

table.insert(runtimeConnections, Services.UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HitboxAim:setHoldingRightClick(false)
    end
end))
