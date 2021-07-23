AddCSLuaFile()

local EVENT = {}

CreateConVar("randomat_negsumgame_initial_health", 50, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Initial health of all players", 1, 200)
CreateConVar("randomat_negsumgame_percentage_health_returned", 20, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percentage of health returned when damaging another player", 1, 100)

EVENT.Title = "Negative Sum Game"
EVENT.id = "negsumgame"

-- TODO: Do we need to do the randomataddons.txt bit?

function EVENT:Begin()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and not ply:IsSpec() and ply:Alive() then
            ply:SetMaxHealth(50)
        end
    end

    self:AddHook("EntityTakeDamage", function(entity, damage)
        if IsValid(entity) and entity:IsPlayer() then
            local attacker = damage:GetAttacker()

            -- We want to make sure that the attacker doesn't somehow get an
            --   insane amount of health from 1-hit KO weapons such as the knife.
            --   They should only get up to as much health as was taken from the
            --   one they attacked, so clamp it between 0 and the amount of
            --   health the attacked could actually lose
            local clampedDamage = math.Clamp(damage:GetDamage(), 0, entity:Health())
            local healamount = clampedDamage * (GetConVar("randomat_negsumgame_percentage_health_returned"):GetInt() / 100)

            attacker:SetHealth(attacker:Health() + healamount)
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"initial_health", "percentage_health_returned"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0 -- Number of decimal points to support (precision)
            })
        end
    end

    local checks = {}
    local textboxes = {}

    return sliders, checks, textboxes
end


function EVENT:End()
    self:CleanUpHooks()
end

Randomat:register(EVENT)
