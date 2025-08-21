local QBCore = exports['qb-core']:GetCoreObject()

local UndercoverPeds = {}
local UndercoverBlips = {}
local isCop = false

local function IsPoliceJob(jobName)
    return jobName and Config.PoliceJobs[jobName] == true
end

-- Job cache
CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end
    local pdata = QBCore.Functions.GetPlayerData()
    isCop = IsPoliceJob(pdata?.job?.name)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    isCop = IsPoliceJob(job?.name)
    -- refresh blips visibility
    for _, ped in ipairs(UndercoverPeds) do
        local blip = UndercoverBlips[ped] or 0
        if blip ~= 0 then RemoveBlip(blip) end
        UndercoverBlips[ped] = 0
        if isCop and DoesEntityExist(ped) then
            local b = AddBlipForEntity(ped)
            SetBlipSprite(b, Config.Blip.sprite)
            SetBlipScale(b, Config.Blip.scale + 0.0)
            SetBlipColour(b, Config.Blip.color)
            SetBlipAsShortRange(b, Config.Blip.shortRange)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Undercover')
            EndTextCommandSetBlipName(b)
            UndercoverBlips[ped] = b
        end
    end
end)

local function loadModel(hash)
    if not IsModelValid(hash) then return false end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(50); timeout = timeout + 1
    end
    return HasModelLoaded(hash)
end

local function randomAnchor()
    local i = math.random(1, #Config.RouteAnchors)
    return Config.RouteAnchors[i]
end

local function randomWanderFrom(pos)
    local step = Config.WanderStepMin + math.random() * (Config.WanderStepMax - Config.WanderStepMin)
    local angle = math.random() * math.pi * 2.0
    local x = pos.x + math.cos(angle) * step
    local y = pos.y + math.sin(angle) * step
    local z = pos.z
    local ok, nz = GetGroundZFor_3dCoord(x, y, z + 50.0, true)
    if ok then z = nz end
    return vec3(x, y, z)
end

local function spawnUndercoverAt(pos)
    local model = Config.Models[math.random(1, #Config.Models)]
    if not loadModel(model) then return 0 end
    local ped = CreatePed(4, model, pos.x, pos.y, pos.z, math.random(0,360)+0.0, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedArmour(ped, 30)
    SetPedAccuracy(ped, 25)
    SetEntityMaxHealth(ped, 200); SetEntityHealth(ped, 200)
    SetPedRelationshipGroupHash(ped, `CIVMALE`)
    -- idle
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

    -- qb-target interactions
    if exports['qb-target'] then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    label = 'Buy…',
                    icon = 'fas fa-capsules',
                    action = function(entity)
                        -- Trigger sting
                        TriggerEvent('bb_uc:sting', entity)
                    end,
                    canInteract = function(entity, dist, data)
                        return not isCop
                    end,
                },
                {
                    label = 'Identify Undercover',
                    icon = 'fas fa-user-secret',
                    action = function(entity)
                        QBCore.Functions.Notify('Undercover unit confirmed. Keep distance.', 'success')
                    end,
                    job = {'police', 'sheriff', 'trooper'}
                }
            },
            distance = Config.Target.distance
        })
    end

    SetModelAsNoLongerNeeded(model)
    return ped
end

local function ensureBlipFor(ped)
    if not isCop then return end
    local b = AddBlipForEntity(ped)
    SetBlipSprite(b, Config.Blip.sprite)
    SetBlipScale(b, Config.Blip.scale + 0.0)
    SetBlipColour(b, Config.Blip.color)
    SetBlipAsShortRange(b, Config.Blip.shortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Undercover')
    EndTextCommandSetBlipName(b)
    UndercoverBlips[ped] = b
end

RegisterNetEvent('bb_uc:sting', function(ped)
    if not DoesEntityExist(ped) then return end
    -- Alert cops
    local coords = GetEntityCoords(ped)
    TriggerServerEvent('bb_uc:alertCops', coords, 'Sting triggered! Suspect attempted purchase from undercover.')
    -- Equip & hostility
    if Config.HostileAfterSting then
        GiveWeaponToPed(ped, Config.UCWeapon, 60, false, true)
        TaskCombatPed(ped, PlayerPedId(), 0, 16)
    else
        -- run away
        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, true, true)
    end
    QBCore.Functions.Notify('It was a sting! RUN!', 'error')
end)

RegisterNetEvent('bb_uc:notify', function(coords, msg)
    if not isCop then return end
    QBCore.Functions.Notify(msg or 'Undercover sting', 'primary')
    -- temporary radius blip
    local b = AddBlipForRadius(coords.x, coords.y, coords.z, 75.0)
    SetBlipColour(b, 3)
    SetBlipAlpha(b, 120)
    SetTimeout(12000, function()
        if b and b ~= 0 then RemoveBlip(b) end
    end)
end)

RegisterNetEvent('bb_uc:reset', function()
    -- clean up
    for _, ped in ipairs(UndercoverPeds) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end
    UndercoverPeds = {}
    for ped, blip in pairs(UndercoverBlips) do
        if blip ~= 0 then RemoveBlip(blip) end
    end
    UndercoverBlips = {}
    Wait(250)
    -- respawn
    CreateThread(spawnAllUndercover)
end)

function spawnAllUndercover()
    math.randomseed(GetGameTimer() + math.random(999999))
    local pool = {}
    for i=1, Config.UndercoverCount do
        pool[i] = spawnUndercoverAt(Config.RouteAnchors[((i-1) % #Config.RouteAnchors) + 1])
        if pool[i] ~= 0 then
            UndercoverPeds[#UndercoverPeds+1] = pool[i]
            ensureBlipFor(pool[i])
            Wait(200)
        end
    end
    -- start roaming loop
    CreateThread(function()
        while true do
            for _, ped in ipairs(UndercoverPeds) do
                if DoesEntityExist(ped) then
                    if IsPedFatallyInjured(ped) then
                        -- respawn near anchor
                        local pos = randomAnchor()
                        SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, true)
                        ClearPedTasksImmediately(ped)
                    end
                    local pos = GetEntityCoords(ped)
                    local nextPos = randomWanderFrom(pos)
                    TaskGoStraightToCoord(ped, nextPos.x, nextPos.y, nextPos.z, 1.5, -1, 0.0, 0.0)
                end
                Wait(100)
            end
            Wait(Config.TickMs)
        end
    end)
end

-- Boot
CreateThread(function()
    -- wait until player active
    while not NetworkIsSessionStarted() do Wait(250) end
    -- small delay for job cache
    Wait(1500)
    spawnAllUndercover()
end)
