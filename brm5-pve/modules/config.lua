local Config = {
    aimEnabled = true,
    silentAim = false,
    fovRadius = 200,
    smoothing = 0.3,
    wallCheck = true,
    lockTarget = true,
    hitboxExpanderEnabled = true,
    hitboxExpander = 1.5,

    espEnabled = true,
    showBox = true,
    showTracer = true,

    visibleColor = {R = 255, G = 80, B = 30},
    hiddenColor = {R = 255, G = 200, B = 50},

    NPC_REFRESH_INTERVAL = 1.0,
    ESP_COLOR_UPDATE_INTERVAL = 0.5,

    guiVisible = true,
    isUnloaded = false
}

-- same save/load functions as before
function Config:save() _G.FireHUB_Config = self end
function Config:load()
    local saved = _G.FireHUB_Config
    if saved then
        for k, v in pairs(saved) do
            if type(v) ~= "function" then self[k] = v end
        end
    end
end

-- update helpers
function Config:updateFOVRadius(val) self.fovRadius = val end
function Config:updateSmoothing(val) self.smoothing = val end
function Config:updateVisibleColor(r,g,b) -- not used, kept for compatibility end
function Config:updateHiddenColor(r,g,b) end
return Config
