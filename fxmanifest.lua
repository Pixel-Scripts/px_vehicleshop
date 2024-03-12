fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Haze'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'function/utils.lua'
}

client_scripts {
    'client/*.lua',
    'client/bridge/esx.lua',
    'client/bridge/qb.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/bridge/esx.lua',
    'server/bridge/qb.lua'
}

files {
    "locales/en.json",
    "img/icon/*.png",
}
