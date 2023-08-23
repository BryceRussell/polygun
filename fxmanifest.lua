fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Bryce Russell'
description 'polygun'
version '0.0.1'

dependencies {
    'ox_lib',
    'PolyZone'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    'client/client.lua'
}

server_scripts {
    'server/server.lua',
}

files {
    'hashes.json'
}
