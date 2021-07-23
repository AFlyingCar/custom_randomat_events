AddCSLuaFile()

local EVENT = {}

local LOG_ID = "[RANDOMAT] [WHOAREYOUAGAIN] "

EVENT.Title = "Who are you again?"
EVENT.Description = "Forces everybody to share a playermodel, color, and bodygroup"
EVENT.id = "whoareyouagain"

-- Look at that one randomat that turns you into a statue
-- disable player names
-- disable player model selector for the round

local function getRandomPlayer()
    local players = {}
    for k, player in pairs(player.GetAll()) do
        if not player:IsSpec() then
            players[k] = player
        end
    end

    return table.Random(players)
end

local function forcePlayerModel(player, newmodel, newcolor, newbodygroups)
    if not player:IsSpec() and player:Alive() then
        FindMetaTable("Entity").SetModel(player, newmodel)
        FindMetaTable("Entity").SetColor(player, newcolor)

        for i,bg in pairs(newbodygroups) do
            FindMetaTable("Entity").SetBodygroup(player, i, bg)
        end
    end
end

function EVENT:Begin()
    local whoitis = getRandomPlayer()
    local newmodel = whoitis:GetModel()
    local newbodygroups = whoitis:GetBodyGroups()
    local newcolor = whoitis:GetColor()

    print(LOG_ID .. "Chose " .. whoitis:GetNick())
    print(LOG_ID .. "New PlayerModel: " .. newmodel)
    print(LOG_ID .. "New Color: " .. newcolor)

    for _, player in pairs(player.GetAll()) do
        forcePlayerModel(player, newmodel, newcolor, newbodygroups)
    end

    self:AddHook("PlayerSpawn", function(player)
        if player and not player:IsSpec() then
            forcePlayerModel(player, newmodel, newcolor, newbodygroups)
        end
    end)

    -- We have to do this every once in a while to stop people from being able
    --  to change their playermodels _back_
    self:AddHook("Think", function()
        for _, ply in pairs(self:GetAlivePlayers()) do
            if not ply:IsSpec() then
                forcePlayerModel(player, newmodel, newcolor, newbodygroups)
            end
        end
    end)
end

function EVENT:End()
    self:CleanUpHooks()
end

Randomat:register(EVENT)
