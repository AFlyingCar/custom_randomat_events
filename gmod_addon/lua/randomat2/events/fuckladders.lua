AddCSLuaFile()

local EVENT = {}

local LOG_ID = "[RANDOMAT] [FUCKLADDERS] "

EVENT.Title = "Fuck Ladders"
EVENT.id = "fuckladders"

-- TODO: Do we need to do the randomataddons.txt bit?

function EVENT:Begin()
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() then
            local newhealth = ent:Health() + dmginfo:GetDamage()
            if newhealth > ent:GetMaxHealth() then
                print(LOG_ID .. "Capping health of entity to " .. ent:GetMaxHealth() .. " instead of " .. newHealth)
                newhealth = ent:GetMaxHealth()
            end

            ent:SetHealth(newhealth)
            return true
        end
    end)
end

function EVENT:End()
    self:CleanUpHooks()
end

-- Randomat:register(EVENT)
