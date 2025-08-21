-- Corrupt_Cops / client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()

local activeScene = false
local spawned = {} -- all spawned entities for cleanup

local function loadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 200 do
        Wait(10); tries = tries + 1
    end
    return HasModelLoaded(hash) and hash or nil
end

local function giveWeapon(ped, weapon)
    GiveWeaponToPed(ped, GetHashKey(weapon), 120, false, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAbility(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedArmour(ped, 25)
end

local function createNPC(model, coords, heading, weapon)
    local hash = loadModel(model)
    if not hash then return nil end
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, heading or 0.0, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCanRagdoll(ped, true)
    if weapon then giveWeapon(ped, weapon) end
    return ped
end

local function addToCleanup(e) if e and DoesEntityExist(e) then table.insert(spawned, e) end end

local function cleanupScene()
    for _, e in ipairs(spawned) do
        if e and DoesEntityExist(e) then DeleteEntity(e) end
    end
    spawned = {}
    activeScene = false
end

-- Request meet from a qb-target zone
local function requestMeet(spotIndex)
    if activeScene then
        QBCore.Functions.Notify("Scene already active.", "error")
        return
    end
    activeScene = true
    TriggerServerEvent("corrupt_cops:requestMeet", spotIndex)
end

-- Scene start from server
RegisterNetEvent("corrupt_cops:startScene", function(data)
    local spot = data.spot
    local outcome = data.outcome

    -- Seller + bodyguards
    local seller = createNPC(Config.SellerModel, spot.coords + vector3(0.0, 2.2, 0.0), spot.heading, Config.SellerWeapon)
    addToCleanup(seller)
    local guards = math.random(0, Config.MaxBodyguards)
    for i=1, guards do
        local off = vector3(2.0 * i, -1.5, 0.0)
        local bg = createNPC(Config.BodyguardModel, spot.coords + off, spot.heading, Config.BodyguardWeapon)
        addToCleanup(bg)
    end

    -- qb-target interaction
    if seller and exports['qb-target'] then
        exports['qb-target']:AddTargetEntity(seller, {
            options = {
                {
                    icon = "fas fa-handshake",
                    label = "Negotiate Purchase",
                    action = function(ent) TriggerServerEvent("corrupt_cops:openCatalog", data.sceneId) end
                },
                {
                    icon = "fas fa-times",
                    label = "Cancel Meet",
                    action = function(ent) TriggerServerEvent("corrupt_cops:cancelScene", data.sceneId) end
                }
            },
            distance = 2.5
        })
    end

    -- Random outcomes handling
    if outcome == "UC_Shootout" then
        CreateThread(function()
            Wait(3500 + math.random(0, 2500))
            if seller and DoesEntityExist(seller) then
                TaskCombatPed(seller, PlayerPedId(), 0, 16)
            end
        end)
    elseif outcome == "GangIntervention" then
        CreateThread(function()
            Wait(4500 + math.random(0, 3000))
            for i=1, Config.GangCount do
                local model = Config.GangModels[math.random(1, #Config.GangModels)]
                local off = vector3(-6.0 + i * 1.5, -6.0, 0.0)
                local gp = createNPC(model, spot.coords + off, spot.heading, Config.GangWeapon)
                addToCleanup(gp)
                if gp then TaskCombatPed(gp, PlayerPedId(), 0, 16) end
            end
        end)
    end
end)

-- Scene end from server (cancel or cleanup)
RegisterNetEvent("corrupt_cops:endScene", function()
    cleanupScene()
end)

-- Add meet zones
CreateThread(function()
    for i, s in ipairs(Config.MeetSpots) do
        if exports['qb-target'] then
            exports['qb-target']:AddBoxZone("cc_meet_"..i, s.coords, 1.4, 1.4, {
                name="cc_meet_"..i, heading=s.heading or 0.0, debugPoly=false,
                minZ = s.coords.z - 1.0, maxZ = s.coords.z + 2.0
            }, {
                options = {
                    { action = function() requestMeet(i) end, icon="fas fa-user-secret", label="Request UC Meet ("..(s.label or "UC")..")" }
                },
                distance = 2.0
            })
        end
    end
end)
