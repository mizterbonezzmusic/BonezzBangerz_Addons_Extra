-- bonezz-dealers-blips/client.lua
-- Creates map blips for configured NPC dealer locations.
-- Safe to use standalone or with QBCore/ESX; no dependencies required.

local function makeBlip(entry)
    local blip = AddBlipForCoord(entry.coords.x, entry.coords.y, entry.coords.z)
    SetBlipSprite(blip, entry.sprite or 84)      -- default: gang/drug icon-ish
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, entry.scale or 0.9)
    SetBlipColour(blip, entry.color or 27)
    SetBlipAsShortRange(blip, entry.shortRange ~= false) -- default true
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(entry.label or "Dealer")
    EndTextCommandSetBlipName(blip)
    return blip
end

CreateThread(function()
    if not Config or not Config.Dealers or #Config.Dealers == 0 then
        print("^3[bonezz-dealers-blips]^7 No dealers configured. Edit config.lua -> Config.Dealers[]")
        return
    end

    for _, entry in ipairs(Config.Dealers) do
        makeBlip(entry)
        if entry.radius and entry.radius > 0.0 then
            -- Optional: draw area radius on map (small map circle blip)
            local area = AddBlipForRadius(entry.coords.x, entry.coords.y, entry.coords.z, entry.radius + 0.0)
            SetBlipAlpha(area, entry.radiusAlpha or 128)  -- 0-255
            SetBlipColour(area, entry.radiusColor or (entry.color or 27))
        end
    end
end)
