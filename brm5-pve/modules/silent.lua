local HitboxAim = {}
HitboxAim.holdingRightClick = false

local function isVisible(camera, targetPart, localPlayer)
    if not localPlayer.Character then return false end
    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {localPlayer.Character}
    local result = workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

function HitboxAim:getClosestValidTarget(NPCManager, camera, Config)
    local bestTarget, bestDist = nil, Config.fovRadius
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    for npc in pairs(NPCManager) do
        if not npc:FindFirstChild("HumanoidRootPart") then continue end
        local part = npc.HumanoidRootPart
        if Config.wallCheck and not isVisible(camera, part, game.Players.LocalPlayer) then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if Config.hitboxExpanderEnabled then
            dist = dist / Config.hitboxExpander
        end
        if dist < bestDist then
            bestDist = dist
            bestTarget = part
        end
    end
    -- Lock target logic
    if Config.lockTarget and self.lastTarget and bestTarget ~= self.lastTarget then
        -- check if lastTarget still valid
        local part = self.lastTarget
        local npc = part.Parent
        if npc and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Humanoid").Health > 0 then
            if not Config.wallCheck or isVisible(camera, part, game.Players.LocalPlayer) then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if Config.hitboxExpanderEnabled then dist = dist / Config.hitboxExpander end
                    if dist <= Config.fovRadius then
                        return part  -- keep lock
                    end
                end
            end
        end
    end
    self.lastTarget = bestTarget
    return bestTarget
end

function HitboxAim:aimAtTarget(targetPart, camera, Config)
    local lookAt = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
    if Config.silentAim then
        camera.CFrame = lookAt
    else
        camera.CFrame = camera.CFrame:Lerp(lookAt, Config.smoothing)
    end
end

function HitboxAim:setHoldingRightClick(state)
    self.holdingRightClick = state
end

function HitboxAim:cleanup()
    self.holdingRightClick = false
    self.lastTarget = nil
end

return HitboxAim
