fx_version 'cerulean'
game 'gta5'

author 'Mizter Bonezz'
description 'Corrupt Cops - UC/LEO sting buys with corruption, shootouts, and random gang intervention'
version '1.1.0'

shared_script 'config.lua'
client_scripts {
    '@PolyZone/client.lua', -- optional
    'client/main.lua'
}
server_script 'server/main.lua'

dependencies { 'qb-core', 'qb-target' }
