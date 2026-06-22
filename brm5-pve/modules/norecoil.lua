local Weapons = {}

function Weapons.patchWeapons(replicatedStorage, options)
    -- Simple no-recoil / firemode patch (example, adjust for BRM5)
    if options.recoil then
        -- Hook recoil
        local weaponFolder = replicatedStorage:FindFirstChild("Weapons")
        if weaponFolder then
            for _, weapon in ipairs(weaponFolder:GetChildren()) do
                if weapon:FindFirstChild("Recoil") then
                    weapon.Recoil.Value = 0
                end
            end
        end
    end
    if options.firemodes then
        -- Not implemented fully
    end
end

return Weapons
