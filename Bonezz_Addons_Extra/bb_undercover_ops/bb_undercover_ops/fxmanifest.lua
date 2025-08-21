fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Bone Bangerz'
description 'Undercover NPC sting ops with roaming blips visible only to law enforcement'
version '1.0.0'

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
    'qb-target'
}
