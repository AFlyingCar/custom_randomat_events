AddCSLuaFile()

local EVENT = {}

local LOG_ID = "[RANDOMAT] [HEMOPHILIA] "

CreateConVar("randomat_hemophilia_loss_speed", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time until next health loss.", 1, 300)
CreateConVar("randomat_hemophilia_amount", 1, {FCVAR, FCVAR_ARCHIVE}, "Amount of health lost each time.", 1, 25)
CreateConVar("randomat_hemophilia_loss_health", 100, {FCVAR, FCVAR_ARCHIVE}, "Minimum amount of health before it starts getting lost over time.", 1, 200)

EVENT.Title = "Hemophilia"
EVENT.id = "hemophilia"

function hemophiliaLoseHealth()
    local players = {}
    for k, player in pairs(player.GetAll()) do
        if not player:IsSpec() then
            players[k] = player
        end
    end

    for _, player in pairs(players) do
        if player:Alive() and not player:IsSpec() then
            if CLIENT then return end

            local health = player:Health()
            if health < GetConVar("randomat_hemophilia_loss_health"):GetInt() then
                player:SetHealth(health - GetConVar("randomat_hemophilia_amount"):GetInt())
            end
        end
    end
end

function EVENT:Begin()
    timer.Create("RandomatHemophiliaTimer", GetConVar("randomat_hemophilia_loss_speed"):GetInt(), 0, hemophiliaLoseHealth)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"loss_speed", "amount", "loss_health"}) do
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
    timer.Remove("RandomatHemophiliaTimer")
end

Randomat:register(EVENT)
