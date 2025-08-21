-- bonezz-dealers: configuration

Config = {}

-- Blip settings
Config.BlipsEnabled = true
Config.BlipSprite = 501         -- generic 'dealer' style (change if you prefer)
Config.BlipColor  = 2           -- green
Config.BlipScale  = 0.8
Config.BlipCategory = "Dealers" -- shows in legend like gas stations (label text)

-- Ped model for dealers
Config.PedModel = 'g_m_y_mexgang_01' -- change to any ped if you like
Config.PedScenario = 'WORLD_HUMAN_DRUG_DEALER' -- idle scenario

-- Interaction
Config.TargetIcon = 'fas fa-capsules'
Config.TargetLabel = 'Talk to Dealer'

-- Currency: 'cash' or 'bank'
Config.Currency = 'cash'

-- Dealer locations across major zones
-- vector4(x, y, z, heading)
Config.Dealers = {
    -- City core
    { pos = vector4(94.85, -1959.91, 20.75, 40.0),   name = "Grove St Dealer" },
    { pos = vector4(181.45, -932.77, 30.69, 320.0),  name = "Legion Dealer" },
    { pos = vector4(-532.92, -221.03, 37.65, 200.0), name = "Rockford Dealer" },
    -- Sandy Shores
    { pos = vector4(1389.44, 3607.90, 38.94, 200.0), name = "Sandy Dealer" },
    -- Grapeseed
    { pos = vector4(1709.87, 4820.36, 41.99, 95.0),  name = "Grapeseed Dealer" },
    -- Paleto Bay
    { pos = vector4(-98.43, 6422.92, 31.64, 225.0),  name = "Paleto Dealer" },
}

-- Inventory: every dealer buys AND sells all items below.
-- price = buy-from-dealer price; sell = price dealer pays to player.
-- Make sure these item names exist in your items table/items.lua.
Config.Items = {
    -- Pills / pharmacy
    { item = 'xanax',     label = 'Xanax',           price = 450,  sell = 250 },
    { item = 'oxy',       label = 'Oxycodone',       price = 500,  sell = 275 },
    { item = 'adderall',  label = 'Adderall',        price = 350,  sell = 200 },
    { item = 'lean',      label = 'Lean',            price = 300,  sell = 175 },

    -- Weed
    { item = 'weed_seed', label = 'Weed Seed',       price = 100,  sell = 50  },
    { item = 'weed_bud',  label = 'Weed Bud',        price = 150,  sell = 80  },
    { item = 'weed_bag',  label = 'Bag of Weed',     price = 250,  sell = 125 },
    { item = 'joint',     label = 'Joint',           price = 100,  sell = 60  },

    -- Coke
    { item = 'coke_leaf',  label = 'Coca Leaf',      price = 200,  sell = 110 },
    { item = 'coke_paste', label = 'Cocaine Paste',  price = 500,  sell = 300 },
    { item = 'coke_brick', label = 'Coke Brick',     price = 6000, sell = 3500 },
    { item = 'coke_baggy', label = 'Coke Baggy',     price = 700,  sell = 400 },

    -- Meth
    { item = 'meth_raw',  label = 'Raw Meth',        price = 700,  sell = 400 },
    { item = 'meth_bag',  label = 'Bag of Meth',     price = 900,  sell = 520 },
}
