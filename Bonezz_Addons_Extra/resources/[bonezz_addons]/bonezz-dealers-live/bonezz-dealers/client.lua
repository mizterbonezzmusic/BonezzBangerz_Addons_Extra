local QBCore = exports['qb-core']:GetCoreObject()

local peds = {}

local function makeBlip(pos, name)
    if not Config.BlipsEnabled then return end
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(name or Config.BlipCategory or 'Dealer')
    EndTextCommandSetBlipName(blip)
end

local function spawnDealer(dealer)
    local model = joaat(Config.PedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local x,y,z,h = dealer.pos.x, dealer.pos.y, dealer.pos.z, dealer.pos.w
    local ped = CreatePed(4, model, x, y, z - 1.0, h, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    if Config.PedScenario and Config.PedScenario ~= '' then
        TaskStartScenarioInPlace(ped, Config.PedScenario, 0, true)
    end

    -- qb-target
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = Config.TargetIcon,
                label = Config.TargetLabel,
                action = function()
                    -- open menu
                    TriggerEvent('bonezz-dealers:client:OpenMenu')
                end
            }
        },
        distance = 2.0
    })

    table.insert(peds, ped)
end

RegisterNetEvent('bonezz-dealers:client:OpenMenu', function()
    local shopItems = {}
    for _, it in ipairs(Config.Items) do
        shopItems[#shopItems+1] = {
            header = (it.label or it.item) .. ' | $' .. it.price .. ' / $' .. it.sell,
            txt = 'Buy or Sell',
            params = {
                event = 'bonezz-dealers:client:ChooseAction',
                args = { item = it.item, label = it.label, price = it.price, sell = it.sell }
            }
        }
    end

    local menu = {
        { header = 'Dealer - Buy & Sell', isMenuHeader = true }
    }
    for _, row in ipairs(shopItems) do menu[#menu+1] = row end
    menu[#menu+1] = { header = 'Close', params = { event = 'qb-menu:client:closeMenu' } }

    TriggerEvent('qb-menu:client:openMenu', menu)
end)

RegisterNetEvent('bonezz-dealers:client:ChooseAction', function(data)
    local item = data.item
    local label = data.label or item
    local price = data.price
    local sell = data.sell

    local menu = {
        { header = 'Dealer: ' .. label, isMenuHeader = true },
        {
            header = 'Buy 1 for $' .. price,
            params = { event = 'bonezz-dealers:client:BuyAmount', args = { item = item, price = price, amount = 1 } }
        },
        {
            header = 'Buy 5 for $' .. (price*5),
            params = { event = 'bonezz-dealers:client:BuyAmount', args = { item = item, price = price, amount = 5 } }
        },
        {
            header = 'Sell 1 for $' .. sell,
            params = { event = 'bonezz-dealers:client:SellAmount', args = { item = item, sell = sell, amount = 1 } }
        },
        {
            header = 'Sell 5 for $' .. (sell*5),
            params = { event = 'bonezz-dealers:client:SellAmount', args = { item = item, sell = sell, amount = 5 } }
        },
        { header = 'Back', params = { event = 'bonezz-dealers:client:OpenMenu' } }
    }
    TriggerEvent('qb-menu:client:openMenu', menu)
end)

RegisterNetEvent('bonezz-dealers:client:BuyAmount', function(data)
    TriggerServerEvent('bonezz-dealers:server:Buy', data.item, data.amount or 1)
end)

RegisterNetEvent('bonezz-dealers:client:SellAmount', function(data)
    TriggerServerEvent('bonezz-dealers:server:Sell', data.item, data.amount or 1)
end)

CreateThread(function()
    for _, dealer in ipairs(Config.Dealers) do
        makeBlip(vector3(dealer.pos.x, dealer.pos.y, dealer.pos.z), dealer.name or Config.BlipCategory)
        spawnDealer(dealer)
    end
end)
