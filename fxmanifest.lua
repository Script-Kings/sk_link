fx_version "cerulean"

description "ScriptKings - Link Script & SDK"
author "Script Kings"
version '1.0.0'

lua54 'yes'

game "gta5"

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'links/frameworks/**/client.lua',
    'links/interactions/**/client.lua',
    'links/playergroups/client.lua',
    'links/exports/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'links/frameworks/**/server.lua',
    'links/interactions/**/server.lua',
    'links/playergroups/server.lua',
    'links/exports/server.lua'
}

shared_scripts {
    'config.lua',
    'links/shared.lua',
    'links/playergroups/config.lua',
    '@ox_lib/init.lua',
}
