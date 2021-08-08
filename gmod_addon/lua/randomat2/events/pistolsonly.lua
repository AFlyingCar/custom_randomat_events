AddCSLuaFile()

local EVENT = {}

local LOG_ID = "[RANDOMAT] [PISTOLSONLY] "

EVENT.Title = "Pistols Only!"
EVENT.id = "pistolsonly"

function EVENT:Begin()
    local valid_pistols = {}

    -- Find all valid pistols
    for _, wep in RandomPairs(weapons.GetList()) do
        if wep.AutoSpawnable and wep.Kind == WEAPON_PISTOL then
            table.insert(valid_pistols, wep)
        end
    end

    -- Replace every non-pistol and non-grenade with a random pistol
    for _, ent in ipairs(ents.GetAll()) do
        if ent.Base == "weapon_tttbase" and ent.AutoSpawnable and ent.Kind ~= WEAPON_PISTOL and ent.Kind ~= WEAPON_NADE then
            -- First we get the position of the weapon to remove
            local ent_pos = ent:GetPos()

            -- Next remove the original weapon (Note: this will happen on the
            --   next tick)
            ent:Remove()
            
            -- Now we go ahead and create a new weapon where the original was
            local new_id = table.Random(valid_pistols)
            local new_ent = ents.Create(new_id)
            new_ent:SetPos(ent_pos)
            new_ent:Spawn()
        end
    end

    -- Strip every non-pistol from each living player
    for k, ply in ipairs(player.GetAll()) do
        -- Only bother stripping them from alive and non-spectators
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then
            for _, wep in ipairs(ply:GetWeapons()) do
                -- We only check for WEAPON_HEAVY, as pistols (obviously),
                --  grenades, melee, carry, and special equipment is still fine
                if wep.Kind == WEAPON_HEAVY then
                    ply:StripWeapon(wep.ClassName)
                end
            end
        end
    end

    -- Now, just to be safe, prevent players from picking up heavy ordinance
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        -- Invalid, dead, and spectator players can pickup whatever they want
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then
            return
        end

        return IsValid(wep) and wep.Kind ~= WEAPON_HEAVY
    end)

    -- Make sure traitors and detectives can't buy heavy ordinance
    -- TODO: Do we want to prevent ordering weird equipment as well (I mean
    --   things like poltergeist, doncannon, knife, etc...)?
    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end

        if is_item then
            -- This hook only gives us the class name, so look the item up
            local wep = ents.FindByClass(id)

            if IsValid(wep) and wep.Base == "weapon_tttbase" and wep.Kind == WEAPON_HEAVY then
                ply:ChatPrint("Come on dude, the randomat is pistols only, what did you think that meant? Your purchase has been refunded.")
                return false
            end
        end

        return true
    end)
end

-- TODO: We may want a convar to allow toggling between allowing buyable weird non-pistol equipment
-- function EVENT:GetConVars()
-- end

function EVENT:End()
    self:CleanUpHooks()
end

-- Disabled for now until i know it works
Randomat:register(EVENT)

