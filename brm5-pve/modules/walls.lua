local ESP = {}
local espObjects = {}  -- [npc] = folder

function ESP.createESP(npc, Config)
    if espObjects[npc] then ESP.removeESP(npc) end
    local folder = Instance.new("Folder")
    folder.Name = "FireHUB_ESP"

    -- Box
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Adornee = npc
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.5
    local mult = Config.hitboxExpanderEnabled and Config.hitboxExpander or 1.0
    box.Size = Vector3.new(4, 5, 1) * mult
    box.Color3 = Color3.fromRGB(Config.visibleColor.R, Config.visibleColor.G, Config.visibleColor.B)
    box.Parent = folder

    -- Tracer
    local tracer = Instance.new("LineHandleAdornment")
    tracer.Name = "Tracer"
    tracer.Adornee = npc
    tracer.AlwaysOnTop = true
    tracer.ZIndex = 5
    tracer.Transparency = 0.6
    tracer.Length = 1
    tracer.Thickness = 2
    tracer.Color3 = Color3.fromRGB(Config.visibleColor.R, Config.visibleColor.G, Config.visibleColor.B)
    tracer.Parent = folder

    -- Billboard
    local bill = Instance.new("BillboardGui")
    bill.Name = "Billboard"
    bill.Adornee = npc:FindFirstChild("Head") or npc:FindFirstChild("HumanoidRootPart")
    bill.Size = UDim2.new(0, 200, 0, 60)
    bill.StudsOffset = Vector3.new(0, 2.8, 0)
    bill.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    nameLabel.Text = npc.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = bill

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BackgroundTransparency = 0.3
    healthBg.Size = UDim2.new(1, 0, 0.08, 0)
    healthBg.Position = UDim2.new(0, 0, 0.4, 0)
    healthBg.Parent = bill
    Instance.new("UICorner", healthBg).CornerRadius = UDim.new(0, 2)

    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 80, 30)
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Parent = healthBg
    Instance.new("UICorner", healthBar).CornerRadius = UDim.new(0, 2)

    local visLabel = Instance.new("TextLabel")
    visLabel.Name = "Visibility"
    visLabel.BackgroundTransparency = 1
    visLabel.Size = UDim2.new(1, 0, 0.25, 0)
    visLabel.Position = UDim2.new(0, 0, 0.55, 0)
    visLabel.Text = ""
    visLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    visLabel.TextStrokeTransparency = 0.3
    visLabel.TextSize = 11
    visLabel.Font = Enum.Font.SourceSansBold
    visLabel.Parent = bill

    bill.Parent = folder
    folder.Parent = workspace.CurrentCamera
    espObjects[npc] = folder
end

function ESP.removeESP(npc)
    if espObjects[npc] then
        espObjects[npc]:Destroy()
        espObjects[npc] = nil
    end
end

function ESP.enable(NPCManager, Config)
    for npc in pairs(NPCManager) do
        if not espObjects[npc] then ESP.createESP(npc, Config) end
    end
end

function ESP.disable()
    for npc, folder in pairs(espObjects) do
        folder:Destroy()
        espObjects[npc] = nil
    end
end

function ESP.updateColors(NPCManager, camera, workspace, localPlayer, Config)
    for npc, folder in pairs(espObjects) do
        local part = npc:FindFirstChild("HumanoidRootPart")
        if not part then folder.Parent = nil; continue end
        local visible = true
        if Config.espWallCheck then
            local origin = camera.CFrame.Position
            local direction = part.Position - origin
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {localPlayer.Character}
            local result = workspace:Raycast(origin, direction, rayParams)
            visible = not result or result.Instance:IsDescendantOf(part.Parent)
        end

        local box = folder:FindFirstChild("Box")
        if box then
            box.Visible = Config.showBox
            box.Color3 = visible and Color3.fromRGB(Config.visibleColor.R, Config.visibleColor.G, Config.visibleColor.B)
                or Color3.fromRGB(Config.hiddenColor.R, Config.hiddenColor.G, Config.hiddenColor.B)
            box.Size = Vector3.new(4, 5, 1) * (Config.hitboxExpanderEnabled and Config.hitboxExpander or 1.0)
        end

        local tracer = folder:FindFirstChild("Tracer")
        if tracer then
            tracer.Visible = Config.showTracer
            tracer.Color3 = visible and Color3.fromRGB(Config.visibleColor.R, Config.visibleColor.G, Config.visibleColor.B)
                or Color3.fromRGB(Config.hiddenColor.R, Config.hiddenColor.G, Config.hiddenColor.B)
        end

        local bill = folder:FindFirstChild("Billboard")
        if bill then
            local nameLabel = bill:FindFirstChild("Name")
            local healthBar = bill:FindFirstChild("HealthBg"):FindFirstChild("Health")
            local visLabel = bill:FindFirstChild("Visibility")

            if nameLabel then
                nameLabel.Visible = Config.showName
                local text = npc.Name
                if Config.showDistance then
                    local dist = math.floor((camera.CFrame.Position - part.Position).Magnitude)
                    text = text .. " [" .. dist .. "m]"
                end
                nameLabel.Text = text
            end

            if healthBar then
                local humanoid = npc:FindFirstChild("Humanoid")
                if humanoid then
                    local percent = humanoid.Health / humanoid.MaxHealth
                    healthBar.Size = UDim2.new(percent, 0, 1, 0)
                    healthBar.BackgroundColor3 = Color3.fromRGB(math.clamp((1-percent)*2,0,1), math.clamp(percent*2,0,1), 0)
                end
                healthBar.Parent.Visible = Config.showHealth
            end

            if visLabel then
                visLabel.Visible = Config.espWallCheck
                visLabel.Text = visible and "VISIBLE" or "WALL"
                visLabel.TextColor3 = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,0)
            end
        end
    end
end

function ESP.refreshAll(NPCManager, Config)
    ESP.disable()
    ESP.enable(NPCManager, Config)
end

function ESP.cleanup()
    ESP.disable()
end

return ESP
