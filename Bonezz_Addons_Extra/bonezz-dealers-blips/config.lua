Config = Config or {}

-- Toggle to always show dealer blips
Config.ShowDealerBlipsAlways = true

-- Example dealer entries (replace / add yours here if needed)
Config.Dealers = Config.Dealers or {
    {
        label = 'Grove St Dealer',
        coords = vector3(-42.1, -1749.3, 29.4),
        blipSprite = 501,
        blipColor  = 2,
        blipScale  = 0.8,
        blipLabel  = 'Dealer'
    },
    {
        label = 'Sandy Dealer',
        coords = vector3(1962.6, 3743.1, 32.3),
    },
}
