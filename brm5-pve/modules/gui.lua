local GUI = {}
local screenGui
local mainFrame

function GUI:init(Services, Config, callbacks)
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FireHUB"
    screenGui.Parent = Services.localPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10000
    screenGui.IgnoreGuiInset = true

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 700)
    mainFrame.Position = UDim2.new(1, -400, 0, 30)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true  -- title bar will override drag
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    -- Glow
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 6, 1, 6)
    glow.Position = UDim2.new(0, -3, 0, -3)
    glow.BackgroundColor3 = Color3.fromRGB(255, 80, 30)
    glow.BackgroundTransparency = 0.5
    glow.BorderSizePixel = 0
    glow.Parent = mainFrame
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Active = true
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

    -- drag
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Text = "🔥"
    logo.TextSize = 22
    logo.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 50, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "FIRE HUB"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() callbacks.onUnload() end)

    -- Scroll area
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -60)
    scroll.Position = UDim2.new(0, 5, 0, 55)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 30)
    scroll.Active = false
    scroll.Selectable = false
    scroll.Parent = mainFrame

    -- Helper: section label
    local function addSection(text, y)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 25)
        lbl.Position = UDim2.new(0, 10, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 100, 30)
        lbl.TextSize = 16
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = scroll
        return y + 30
    end

    -- Toggle
    local function addToggle(y, text, initial, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 40)
        container.Position = UDim2.new(0, 10, 0, y)
        container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        container.Parent = scroll
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 200, 1, 0)
        lbl.Position = UDim2.new(0, 15, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = container

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 22)
        btn.Position = UDim2.new(1, -60, 0.5, -11)
        btn.BackgroundColor3 = initial and Color3.fromRGB(255, 80, 30) or Color3.fromRGB(80, 80, 80)
        btn.Text = initial and "ON" or "OFF"
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)

        btn.MouseButton1Click:Connect(function()
            local state = btn.Text == "OFF"
            btn.Text = state and "ON" or "OFF"
            btn.BackgroundColor3 = state and Color3.fromRGB(255, 80, 30) or Color3.fromRGB(80, 80, 80)
            callback(state)
        end)
        return y + 50
    end

    -- Slider
    local function addSlider(y, text, min, max, cur, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 65)
        container.Position = UDim2.new(0, 10, 0, y)
        container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        container.Parent = scroll
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 8)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. string.format("%.1f", cur)
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 8)
        track.Position = UDim2.new(0, 10, 0, 35)
        track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        track.Parent = container
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((cur-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 100, 30)
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((cur-min)/(max-min), 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Text = ""
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 11)

        local function update(v)
            local p = (v-min)/(max-min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            label.Text = text .. ": " .. string.format("%.1f", v)
        end

        local dragging = false
        knob.MouseButton1Down:Connect(function()
            dragging = true
            Services.UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local relX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    local val = min + (relX / track.AbsoluteSize.X) * (max-min)
                    val = math.clamp(math.round(val * 10) / 10, min, max)
                    update(val)
                    callback(val)
                end
            end)
        end)
        Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
                local relX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                local val = min + (relX / track.AbsoluteSize.X) * (max-min)
                val = math.clamp(math.round(val * 10) / 10, min, max)
                update(val)
                callback(val)
            end
        end)
        return y + 75
    end

    local y = 10
    y = addSection("🎯 AIMBOT (NPCs)", y)
    y = addToggle(y, "Aimbot", Config.aimEnabled, callbacks.onAimToggle)
    y = addToggle(y, "Silent Aim", Config.silentAim, callbacks.onSilentAimToggle)
    y = addToggle(y, "Lock Target", Config.lockTarget, callbacks.onLockTargetToggle)
    y = addToggle(y, "Hitbox Expander", Config.hitboxExpanderEnabled, callbacks.onHitboxToggle)
    y = addSlider(y, "Expander Multiplier", 1.0, 3.0, Config.hitboxExpander, callbacks.onHitboxMultiplierChange)
    y = addSlider(y, "FOV Radius", 50, 1000, Config.fovRadius, callbacks.onFOVChange)
    y = addSlider(y, "Smoothness", 0.1, 1.0, Config.smoothing, callbacks.onSmoothingChange)
    y = addToggle(y, "Wall Check", Config.wallCheck, callbacks.onWallCheckToggle)

    y = y + 10
    y = addSection("👁 ESP", y)
    y = addToggle(y, "ESP Master", Config.espEnabled, callbacks.onESPToggle)
    y = addToggle(y, "Boxes", Config.showBox, callbacks.onBoxToggle)
    y = addToggle(y, "Tracers", Config.showTracer, callbacks.onTracerToggle)
    y = addToggle(y, "Names", Config.showName, callbacks.onNameToggle)
    y = addToggle(y, "Distance", Config.showDistance, callbacks.onDistanceToggle)
    y = addToggle(y, "Health Bar", Config.showHealth, callbacks.onHealthToggle)
    y = addToggle(y, "ESP Wall Check", Config.espWallCheck, callbacks.onESPWallCheckToggle)
    y = addToggle(y, "Show Invisible", Config.showInvisible, callbacks.onShowInvisibleToggle)

    y = y + 10
    y = addSection("⚙ EXTRAS", y)
    y = addToggle(y, "Fullbright", Config.fullBrightEnabled, callbacks.onFullBrightToggle)
    y = addToggle(y, "No Recoil", Config.patchOptions.recoil, callbacks.onNoRecoilToggle)
    y = addToggle(y, "Firemode Patch", Config.patchOptions.firemodes, callbacks.onFiremodeToggle)

    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 30)

    self.visible = true
end

function GUI:toggleVisibility()
    if screenGui then
        screenGui.Enabled = not screenGui.Enabled
        return screenGui.Enabled
    end
    return false
end

function GUI:destroy()
    if screenGui then screenGui:Destroy() end
end

return GUI
