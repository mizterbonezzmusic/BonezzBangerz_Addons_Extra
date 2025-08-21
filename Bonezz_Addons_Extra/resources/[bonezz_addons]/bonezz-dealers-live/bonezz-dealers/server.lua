local QBCore = exports['qb-core']:GetCoreObject()

local IndexByItem = {}
for i, it in ipairs(Config.Items) do
    IndexByItem[it.item] = it
end

local function GetItemInfo(itemName)
    return IndexByItem[itemName]
end

RegisterNetEvent('bonezz-dealers:server:Buy', function(item, amount)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local info = GetItemInfo(item)
    if not info then
        TriggerClientEvent('QBCore:Notify', src, 'Item not for sale here', 'error')
        return
    end

    amount = tonumber(amount) or 1
    if amount < 1 then amount = 1 end

    local total = math.floor(info.price * amount)
    if xPlayer.PlayerData.money[Config.Currency] < total then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough ' .. Config.Currency, 'error')
        return
    end

    xPlayer.Functions.RemoveMoney(Config.Currency, total, 'dealer-buy-'..item)
    xPlayer.Functions.AddItem(item, amount, false, {})
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
    TriggerClientEvent('QBCore:Notify', src, ('Bought %sx %s'):format(amount, info.label or item), 'success')
end)

RegisterNetEvent('bonezz-dealers:server:Sell', function(item, amount)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local info = GetItemInfo(item)
    if not info then
        TriggerClientEvent('QBCore:Notify', src, 'Item not accepted here', 'error')
        return
    end

    amount = tonumber(amount) or 1
    if amount < 1 then amount = 1 end

    local have = xPlayer.Functions.GetItemByName(item)
    if not have or have.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough to sell', 'error')
        return
    end

    local payout = math.floor(info.sell * amount)
    xPlayer.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
    xPlayer.Functions.AddMoney(Config.Currency, payout, 'dealer-sell-'..item)
    TriggerClientEvent('QBCore:Notify', src, ('Sold %sx %s'):format(amount, info.label or item), 'success')
end)
