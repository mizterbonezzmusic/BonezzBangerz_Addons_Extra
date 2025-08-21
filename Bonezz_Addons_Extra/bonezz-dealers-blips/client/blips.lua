-- client/blips.lua

CreateThread(function()
    local function removeBlips()
        if not Config or not Config.Dealers then return end
        for _, d in pairs(Config.Dealers) do
            if d.blip and DoesBlipExist(d.blip) then
                RemoveBlip(d.blip)
            end
            d.blip = nil
        end
    end

    local function createBlips()
        if not Config or not Config.Dealers then return end
        for _, d in pairs(Config.Dealers) do
            local c = d.coords or d.Coords or d.location
            if c then
                local x = c.x or c[1]
                local y = c.y or c[2]
                local z = c.z or c[3] or 0.0

                if x and y then
                    local blip = AddBlipForCoord(x + 0.0, y + 0.0, z + 0.0)
                    SetBlipSprite(blip, d.blipSprite or 501)
                    SetBlipScale(blip,  d.blipScale  or 0.8)
                    SetBlipColour(blip, d.blipColor  or 2)
                    SetBlipAsShortRange(blip, true)
                    SetBlipDisplay(blip, 6)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString(d.blipLabel or d.label or 'Dealer')
                    EndTextCommandSetBlipName(blip)
                    d.blip = blip
                end
            end
        end
    end

    if Config and (Config.ShowDealerBlipsAlways == nil or Config.ShowDealerBlipsAlways == true) then
        Wait(2000)
        createBlips()
    else
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            Wait(1500)
            createBlips()
        end)
        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            removeBlips()
        end)
    end
end)
