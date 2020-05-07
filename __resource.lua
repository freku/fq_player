resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    'client.lua',
    'model.lua',
    'basic.lua',
    'bars.lua',
    'relations.lua',
    'voice.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/main.js',
}