-- Corrupt_Cops / config.lua
Config = {}

-- LEO jobs who can request UC meets
Config.LEOJobs = { police = true, sheriff = true, fbi = true }

-- UC jobs who are allowed to act as sellers (for labeling/logic; seller is NPC here)
Config.UCJobs  = { uc = true, undercover = true }

-- Require buyers to be on duty?
Config.RequireOnDuty = false

-- Corruption controls
Config.AllowCorruptToggle = true   -- enables /uc_corrupt
Config.CorruptJobs = { }           -- e.g., police = true to blanket-allow (not recommended)
Config.CorruptGrades = { }         -- e.g., ['police'] = { ['detective']=true }

-- Items catalog (use your Bonezz Rx item names)
Config.Catalog = {
    weed_bud       = 100,
    joint          = 50,
    coke_bag       = 450,
    meth_bag       = 500,
    oxy            = 250,
    xanax          = 220,
    mdma           = 300,
    lsd_tab        = 220,
    shrooms        = 180,
    lean_bottle    = 350,
    heroin_bag     = 650,
    ketamine_vial  = 420,
    dmt            = 700
}

-- Meet locations (qb-target zones)
Config.MeetSpots = {
    { label = 'UC Meet: Docks',    coords = vec3(937.6,  -3110.4, 5.9), heading = 90.0 },
    { label = 'UC Meet: Parking',  coords = vec3(-324.6, -892.2, 31.0), heading = 0.0  },
    { label = 'UC Meet: Canal',    coords = vec3(-1144.2, -1647.6, 4.4), heading = 120.0 },
}

-- Probabilities for random outcomes
Config.Probabilities = {
    CleanBuy = 0.60,        -- 60%
    UC_Shootout = 0.25,     -- 25%
    GangIntervention = 0.15 -- 15%
}

-- NPC models & weapons
Config.SellerModel = 'g_m_m_chicold_01'
Config.BodyguardModel = 'g_m_m_armboss_01'
Config.GangModels = { 'g_m_y_korean_02', 'g_m_y_salvaboss_01', 'g_m_m_mexboss_01' } -- random pick
Config.SellerWeapon = 'WEAPON_PISTOL'
Config.BodyguardWeapon = 'WEAPON_MICROSMG'
Config.GangWeapon = 'WEAPON_PISTOL'

Config.MaxBodyguards = 2
Config.GangCount = 3

-- Cooldowns (seconds)
Config.BuyerCooldown = 120
Config.UCGlobalCooldown = 60

-- Optional: dispatch hook (server-side event you can listen to)
Config.DispatchEvent = 'corrupt_cops:dispatch'  -- set to '' to disable
