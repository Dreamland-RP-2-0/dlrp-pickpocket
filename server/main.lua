local function GetJobPlayerCount(jobName)
    local count = 0
    local players = exports.dlrp_base:GetBasePlayers()
    
    for _, player in pairs(players) do
        if player.PlayerData.job.name == jobName and player.PlayerData.job.onduty then
            count = count + 1
        end
    end
    
    return count
end

local function GetPlayer(source)
    return exports.dlrp_base:GetPlayer(source)
end

local function AddPlayerMoney(player, amount)
    if exports.ox_inventory then
        exports.ox_inventory:AddItem(player.PlayerData.source, 'money', amount)
    else
        player.Functions.AddMoney('cash', amount, 'pickpocket')
    end
end

local function AddPlayerItem(player, item, amount)
    if exports.ox_inventory then
        exports.ox_inventory:AddItem(player.PlayerData.source, item, amount)
    else
        player.Functions.AddItem(item, amount)
    end
end

local function SendNotification(source, message, notifyType)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Pickpocket',
        description = message,
        type = notifyType or 'info'
    })
end

RegisterNetEvent('dlrp_pickpocket:server:CheckPoliceCount', function()
    local src = source
    local policeCount = GetJobPlayerCount("police")
    local canContinue = policeCount >= Config.RequiredPolice
    TriggerClientEvent('dlrp_pickpocket:client:ContinuePickpocket', src, canContinue)
end)

RegisterNetEvent('dlrp_pickpocket:server:AddCollectedItems', function(collectedIndices, originalItems)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    for _, index in ipairs(collectedIndices) do
        if originalItems and originalItems[index+1] then
            local item = originalItems[index+1]
            
            if item.name == 'money' then
                AddPlayerMoney(Player, item.amount)
                SendNotification(src, "You stole $" .. item.amount, "success")
            else
                AddPlayerItem(Player, item.name, item.amount)
            end
        end
    end
end)

RegisterNetEvent('dlrp_pickpocket:server:SendDispatch', function(coords, streetAndZone)
    local src = source
    
    -- Create dispatch data structure for dlrp_mdt
    local dispatchData = {
        message = 'Pickpocket in Progress',
        codeName = 'pickpocket',
        code = '10-31',
        icon = 'fas fa-hand',
        priority = 2,
        coords = coords,
        street = streetAndZone or 'Unknown',
        alertTime = nil,
        jobs = { 'leo' },
        alert = {
            radius = 0,
            sprite = 225,
            color = 1,
            scale = 0.6,
            length = 2,
            sound = 'Lose_1st',
            sound2 = 'GTAO_FM_Events_Soundset',
            offset = false,
            flash = false
        }
    }
    
    -- Use dlrp_mdt's createCall export (performant and doesn't iterate players)
    exports.dlrp_mdt:createCall(dispatchData)
end)

RegisterNetEvent('dlrp_pickpocket:server:EmoteMessage', function(coords, message)
    local src = source
    TriggerClientEvent('dlrp_pickpocket:EmoteDisplay', -1, src, message, coords)
end)

RegisterNetEvent('dlrp_pickpocket:EmoteDisplay', function(playerId, message, coords)
    local src = source
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    
    if #(srcCoords - coords) < 10.0 then
        TriggerClientEvent('chat:addMessage', src, {
            template = '<div style="padding: 0.5vh; margin: 0.5vh; background-color: rgba(99, 99, 99, 0.75); border-radius: 3px;"><i class="fas fa-user"></i> {0}: {1}</div>',
            args = {"NPC", message}
        })
    end
end)
