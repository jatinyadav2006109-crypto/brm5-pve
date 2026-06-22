local Lighting = {}
local originalSettings = {}

function Lighting.storeOriginalSettings(lighting)
    originalSettings.Brightness = lighting.Brightness
    originalSettings.Ambient = lighting.Ambient
    originalSettings.ColorShift_Top = lighting.ColorShift_Top
    originalSettings.OutdoorAmbient = lighting.OutdoorAmbient
    originalSettings.ClockTime = lighting.ClockTime
    originalSettings.FogEnd = lighting.FogEnd
end

function Lighting.restoreOriginal(lighting)
    if originalSettings.Brightness then
        for k,v in pairs(originalSettings) do
            lighting[k] = v
        end
    end
end

function Lighting.update(lighting, config)
    if config.fullBrightEnabled then
        lighting.Brightness = 1
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
        lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
    end
end

return Lighting
