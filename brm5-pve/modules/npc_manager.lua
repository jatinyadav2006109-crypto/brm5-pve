local NPCManager = {}
local trackedNPCs = {}   -- [npc] = true

function NPCManager:scanWorkspace(workspace, ESP, Config)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not self:isPlayer(obj) then
            trackedNPCs[obj] = true
            ESP.createESP(obj, Config)
        end
    end
end

function NPCManager:isPlayer(model)
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

function NPCManager:refreshTrackedNPCs(workspace, ESP, HitboxAim, Config)
    local current = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not self:isPlayer(obj) then
            current[obj] = true
            if not trackedNPCs[obj] then
                trackedNPCs[obj] = true
                ESP.createESP(obj, Config)
            end
        end
    end
    -- Remove dead/despawned NPCs
    for npc in pairs(trackedNPCs) do
        if not current[npc] then
            ESP.removeESP(npc)
            trackedNPCs[npc] = nil
        end
    end
end

function NPCManager:setupListener(workspace, ESP, Config)
    workspace.DescendantAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and not self:isPlayer(child) then
            trackedNPCs[child] = true
            ESP.createESP(child, Config)
        end
    end)
    workspace.DescendantRemoving:Connect(function(child)
        if trackedNPCs[child] then
            ESP.removeESP(child)
            trackedNPCs[child] = nil
        end
    end)
end

function NPCManager:cleanup()
    trackedNPCs = {}
end

return NPCManager
