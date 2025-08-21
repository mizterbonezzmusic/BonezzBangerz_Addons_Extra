-- Corrupt_Cops / server/main.lua
local QBCore = exports['qb-core']:GetCoreObject()

local lastBuyer = {}   -- cooldown per buyer
local lastGlobal = 0   -- global cooldown
local activeScenes = {} -- sceneId -> { buyer, spotIndex, outcome, ts }

local function now() return os.time() end

local function isCorrupt(Player)
    local jobName = Player.PlayerData.job and Player.PlayerData.job.name or "unemployed"
    local grade   = Player.PlayerData.job and (Player.PlayerData.job.grade and Player.PlayerData.job.grade.name) or nil
    if Config.CorruptJobs[jobName] then return true end
    if grade and Config.CorruptGrades[jobName] and Config.CorruptGrades[jobName][grade] then return true end
    local meta = Player.PlayerData.metadata or {}
    if meta.corrupt == true then return true end
    return false
end

local function canBuy(Player)
    local jobName = Player.PlayerData.job and Player.PlayerData.job.name or "unemployed"
    if not Config.LEOJobs[jobName] then return false, "Only law enforcement can request a UC meet." end
    if Config.RequireOnDuty and not (Player.PlayerData.job and Player.PlayerData.job.onduty) then
        return false, "You must be on duty."
    end
    return true, nil
end

local function pickOutcome()
    local r = math.random()
    local acc = Config.Probabilities.CleanBuy
    if r <= acc then return "CleanBuy" end
    acc = acc + Config.Probabilities.UC_Shootout
    if r <= acc then return "UC_Shootout" end
    return "GangIntervention"
end

local function startScene(src, spotIndex)
    local Player = QBCore.Functions.GetPlayer(src); if not Player then return end
    local ok, msg = canBuy(Player)
    if not ok then TriggerClientEvent("QBCore:Notify", src, msg, "error"); return end

    local t = now()
    if (t - (lastBuyer[src] or 0)) < Config.BuyerCooldown then
        TriggerClientEvent("QBCore:Notify", src, "Cooldown active. Please wait.", "error"); return
    end
    if (t - lastGlobal) < Config.UCGlobalCooldown then
        TriggerClientEvent("QBCore:Notify", src, "UCs are busy. Try again shortly.", "error"); return
    end
    lastBuyer[src] = t; lastGlobal = t

    local sceneId = math.random(11111, 99999)
    local spot = Config.MeetSpots[spotIndex]
    if not spot then TriggerClientEvent("QBCore:Notify", src, "Invalid meet spot.", "error"); return end

    local outcome = pickOutcome()
    activeScenes[sceneId] = { buyer = src, spotIndex = spotIndex, outcome = outcome, ts = t }
    TriggerClientEvent("corrupt_cops:startScene", src, { sceneId = sceneId, spot = spot, outcome = outcome })

    if outcome ~= "CleanBuy" and Config.DispatchEvent and Config.DispatchEvent ~= "" then
        TriggerEvent(Config.DispatchEvent, { type = outcome, coords = spot.coords, buyer = ("license:%s"):format(Player.PlayerData.license or "unknown") })
    end
end

RegisterNetEvent("corrupt_cops:requestMeet", function(spotIndex) startScene(source, spotIndex) end)

RegisterNetEvent("corrupt_cops:openCatalog", function(sceneId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src); if not Player then return end
    local scene = activeScenes[sceneId]
    if not scene or scene.buyer ~= src then TriggerClientEvent("QBCore:Notify", src, "No active meet.", "error"); return end

    local items = {}
    for item, price in pairs(Config.Catalog) do items[#items+1] = { item = item, price = price } end
    TriggerClientEvent('chat:addMessage', src, { color = {255,200,0}, multiline = true, args = { "UC Seller", "Available: " .. json.encode(items) } })
    TriggerClientEvent('chat:addMessage', src, { color = {255,255,255}, multiline = true, args = { "Usage", "/uc_buy <item> <amount>" } })
end)

-- Purchase command
QBCore.Commands.Add('uc_buy', 'Buy item from UC meet', {{name='item', help='item name'}, {name='amount', help='quantity'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src); if not Player then return end
    local item = tostring(args[1] or '')
    local count = tonumber(args[2] or '1') or 1

    -- Validate scene
    local scene
    for id, data in pairs(activeScenes) do if data.buyer == src then scene = data break end end
    if not scene then TriggerClientEvent("QBCore:Notify", src, "No active meet.", "error"); return end

    local price = Config.Catalog[item]
    if not price then TriggerClientEvent("QBCore:Notify", src, "Item not available.", "error"); return end

    local total = price * count
    if Player.Functions.GetMoney('cash') < total then TriggerClientEvent("QBCore:Notify", src, "Not enough cash.", "error"); return end

    -- Corruption influence
    local corrupt = isCorrupt(Player)
    if corrupt and scene.outcome == "CleanBuy" and math.random() < 0.3 then
        scene.outcome = "UC_Shootout"
        if Config.DispatchEvent and Config.DispatchEvent ~= "" then
            local spot = Config.MeetSpots[scene.spotIndex]
            TriggerEvent(Config.DispatchEvent, { type = scene.outcome, coords = spot.coords, buyer = ("license:%s"):format(Player.PlayerData.license or "unknown") })
        end
    end

    Player.Functions.RemoveMoney('cash', total, "corrupt-cops")
    Player.Functions.AddItem(item, count)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[item], 'add')
    TriggerClientEvent("QBCore:Notify", src, ("Purchased %sx %s for $%s"):format(count, item, total), "success")

    if not corrupt then
        print(("[Corrupt_Cops] %s bought %sx %s for $%s"):format(GetPlayerName(src), count, item, total))
    end
end)

RegisterNetEvent("corrupt_cops:cancelScene", function(sceneId)
    activeScenes[sceneId] = nil
    TriggerClientEvent("corrupt_cops:endScene", source)
end)

-- Corruption toggle
if Config.AllowCorruptToggle then
    QBCore.Commands.Add('uc_corrupt', 'Toggle corrupt status (LEO only)', {}, false, function(source, _)
        local Player = QBCore.Functions.GetPlayer(source); if not Player then return end
        local jobName = Player.PlayerData.job and Player.PlayerData.job.name or "unemployed"
        if not Config.LEOJobs[jobName] then TriggerClientEvent("QBCore:Notify", source, "LEO only.", "error"); return end
        local meta = Player.PlayerData.metadata or {}
        local cur = meta.corrupt == true
        Player.Functions.SetMetaData('corrupt', not cur)
        TriggerClientEvent("QBCore:Notify", source, "Corrupt mode: "..(not cur and "ON" or "OFF"), (not cur) and "error" or "success")
    end)
end
