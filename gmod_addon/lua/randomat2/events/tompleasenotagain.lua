AddCSLuaFile()

local EVENT = {}

local LOG_ID = "[RANDOMAT] [TPNA] "

CreateConVar("randomat_tompleasenotagain_spawn_time", 45, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds between destroyers.")
CreateConVar("randomat_tompleasenotagain_dowhatcomesnaturally_weaponid", "weapon_ttt_knife", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "ID of the knife")
CreateConVar("randomat_tompleasenotagain_maxdestroyerevents", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of destroyer events")

EVENT.Title = "Tom Please Not Again"
EVENT.id = "tompleasenotagain"

local giveaways = 0

local function getRandomPlayer()
    local players = {}
    for k, player in pairs(player.GetAll()) do
        if not player:IsSpec() then
            players[k] = player
        end
    end

    return table.Random(players)
end

local function getRandomPlayerWhoIsnt(not_player)
    local players = {}
    for k, player in pairs(player.GetAll()) do
        if not player:IsSpec() and not player:UserID() == not_player:UserID() then
            players[k] = player
        end
    end

    return table.Random(players)
end

-- Copied directly out of barrels.lua
local function TriggerBarrels()
    local plys = {}
    for k, ply in ipairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    for _, ply in pairs(plys) do
        if ply:Alive() and not ply:IsSpec() then
            for _ = 1, GetConVar("randomat_barrels_count"):GetInt() do
                local ent = ents.Create("prop_physics")

                if (not IsValid(ent)) then return end

                ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
                local sc = GetConVar("randomat_barrels_range"):GetInt()
                ent:SetPos(ply:GetPos() + Vector(math.random(-sc, sc), math.random(-sc, sc), math.random(5, sc)))
                ent:Spawn()

                local phys = ent:GetPhysicsObject()
                if (not IsValid(phys)) then ent:Remove() return end
            end
        end
    end
end

local function doWhatComesNaturally()
    local player = getRandomPlayer()

    local knife_weaponid = GetConVar("randomat_tompleasenotagain_dowhatcomesnaturally_weaponid"):GetString()

    if not player:HasWeapon(knife_weaponid) then
        player:Give(knife_weaponid)
        Randomat:EventNotifySilent(player:Nick() .. " I want you to do what comes naturally.")
    else
        -- They already have a knife, so give them a detonator instead :)
        local target = getRandomPlayerWhoIsnt(player)

        player:Give("weapon_ttt_randomatdet")
        player:GetWeapon("weapon_ttt_randomatdet").Target = target

        -- Make sure that only this person gets the message to avoid giving
        --  their role away
        local message = "You're not thinking big brain enough " .. player:Nick() .. "."
        Randomat:SmallNotify(message, message:len(), player)
    end

    giveaways = giveaways + 1
end

local function notAgain()
    local player = getRandomPlayer()

    if not player:HasWeapon("weapon_ttt_suicide") then
        player:Give("weapon_ttt_suicide")
        TriggerBarrels() -- muahahaha >:)
        Randomat:EventNotifySilent(player:Nick() .. " I want you to do what comes naturally.")

        giveaways = giveaways + 1
    end
end

local allDestroyers = {}
table.insert(allDestroyers, notAgain)
table.insert(allDestroyers, doWhatComesNaturally)

local function chooseTheDestroyer()
    local max_destroyerevents = GetConVar("randomat_tompleasenotagain_maxdestroyerevents"):GetInt()

    local destroyer = allDestroyers[math.random(1, #allDestroyers)]

    destroyer()

    if giveaways < max_destroyerevents then
        timer.Create("RandomatBarrelSpawnTimer", GetConVar("randomat_tompleasenotagain_spawn_time"):GetInt(), 1, chooseTheDestroyer)
    end
end

function EVENT:Begin()
    timer.Create("RandomatBarrelSpawnTimer", GetConVar("randomat_tompleasenotagain_spawn_time"):GetInt(), 1, chooseTheDestroyer)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"spawn_time", "exp_radius"}) do
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
    timer.Remove("RandomatBarrelSpawnTimer")

    giveaways = 0
end

-- Disabled for now until i know it works
Randomat:register(EVENT)

