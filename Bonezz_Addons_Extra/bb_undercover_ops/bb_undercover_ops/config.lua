Config = {}

-- Jobs that can see undercover blips
Config.PoliceJobs = {
    police = true,
    sheriff = true,
    trooper = true
}

-- Number of undercovers to spawn
Config.UndercoverCount = 6

-- Models to randomly pick from
Config.Models = {
    `a_m_m_eastsa_01`, `a_m_m_beach_01`, `a_m_m_skater_01`, `a_m_y_eastsa_01`,
    `a_m_y_hipster_01`, `a_f_y_hipster_01`, `a_f_y_bevhills_01`
}

-- Weapon issued on sting
Config.UCWeapon = `WEAPON_PISTOL`

-- If true, UC will attack the buyer after sting triggers
Config.HostileAfterSting = true

-- How far a UC picks the next waypoint (meters)
Config.WanderStepMin = 50.0
Config.WanderStepMax = 120.0

-- Interval for AI tick (ms)
Config.TickMs = 2000

-- Blip settings (only cops see these)
Config.Blip = {
    sprite = 521, -- covert icon
    scale = 0.8,
    color = 29, -- law enforcement blue/teal
    shortRange = false
}

-- City anchors to seed roaming routes (Legion, Vespucci, Sandy, Paleto, Mirror, Rancho)
Config.RouteAnchors = {
    vec3(204.08, -919.12, 30.69),   -- Legion Square
    vec3(-1287.21, -1117.46, 6.99), -- Vespucci
    vec3(1722.63, 3704.11, 34.14),  -- Sandy
    vec3(-135.41, 6397.11, 31.49),  -- Paleto
    vec3(1139.83, -983.04, 46.11),  -- Mirror Park
    vec3(404.63, -1831.54, 28.34)   -- Rancho
}

-- qb-target interaction ranges
Config.Target = {
    distance = 2.0
}
