local Config = {
    -- Aimbot
    aimEnabled = true,
    silentAim = false,
    fovRadius = 200,
    smoothing = 0.3,
    wallCheck = true,
    lockTarget = true,
    hitboxExpanderEnabled = true,
    hitboxExpander = 1.5,

    -- ESP
    espEnabled = true,
    showBox = true,
    showTracer = true,
    showName = false,
    showDistance = true,
    showHealth = true,
    espWallCheck = false,
    showInvisible = false,
    maxESPDistance = 1000,

    -- Colors
    visibleColor = {R = 255, G = 80, B = 30},
    hiddenColor = {R = 255, G = 200, B = 50},

    -- Fullbright
    fullBrightEnabled = false,

    -- Weapon patches
    patchOptions = {recoil = false, firemodes = false},

    -- Refresh intervals
    NPC_REFRESH_INTERVAL = 1.0,
    ESP_COLOR_UPDATE_INTERVAL = 0.5,

    guiVisible = true,
    isUnloaded = false
}

function Config:save()
    -- Optional: use _G or DataStore
    _G.FireHUB_Config = self
end

function Config:load()
    local saved = _G.FireHUB_Config
    if saved then
        for k, v in pairs(saved) do
            if type(v) ~= "function" then
                self[k] = v
            end
        end
    end
end

function Config:updateFOVRadius(value)
    self.fovRadius = value
end

function Config:updateSmoothing(value)
    self.smoothing = value
end

function Config:updateVisibleColor(r, g, b)
    if r then self.visibleColor.R = r end
    if g then self.visibleColor.G = g end
    if b then self.visibleColor.B = b end
end

function Config:updateHiddenColor(r, g, b)
    if r then self.hiddenColor.R = r end
    if g then self.hiddenColor.G = g end
    if b then self.hiddenColor.B = b end
end

return Config
