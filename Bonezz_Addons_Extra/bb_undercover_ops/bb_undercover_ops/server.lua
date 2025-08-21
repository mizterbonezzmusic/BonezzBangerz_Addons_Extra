local QBCore = exports['qb-core']:GetCoreObject()

-- Simple broadcast to online cops when a sting triggers
RegisterNetEvent('bb_uc:alertCops', function(coords, msg)
    local src = source
    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData and Player.PlayerData.job and Config.PoliceJobs[Player.PlayerData.job.name] then
            TriggerClientEvent('bb_uc:notify', playerId, coords, msg or 'Undercover sting in progress!')
        end
    end
end)

-- Admin command to respawn UCs
QBCore.Commands.Add('ucrefresh', 'Respawn undercover NPCs', {}, false, function(src, args)
    TriggerClientEvent('bb_uc:reset', -1)
end, 'admin')
