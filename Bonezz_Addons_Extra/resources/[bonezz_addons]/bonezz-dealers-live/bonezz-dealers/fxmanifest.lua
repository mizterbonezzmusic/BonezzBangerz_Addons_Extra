fx_version 'cerulean'
game 'gta5'

name 'bonezz-dealers'
author 'Bone Bangerz'
version '1.0.0'
description 'NPC Drug Dealers with map blips, buy & sell menus (QBCore + qb-target)'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-inventory'
}
