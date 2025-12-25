fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Pickpocket - Created by NaorNC - Discord.gg/NCHub - Converted to dlrp_base'
version '2.2.0'
author 'NaorNC'

ui_page 'html/index.html'

shared_scripts {
    '@dlrp_lib/init.lua',
    '@dlrp_base/modules/lib.lua',
    'config.lua'
}

client_scripts {
    '@dlrp_base/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js',
    'html/imgs/*.jpg',
    'html/imgs/*.png'
}

dependencies {
    'dlrp_base',
    'dlrp_target',
    'dlrp_mdt',
    'dlrp_lib',
    'oxmysql'
}
