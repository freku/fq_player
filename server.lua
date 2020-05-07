local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs
-- local ESXs = nil

local playerMoney = {} -- [gracz_id] = ilosc_pieniedzy
local playerStats = {} -- [id-gracza] = {kills, deaths, time, visible}

local moneyForKIll = 50
local _fq = nil
local mysqlReady

Citizen.CreateThread(function()
    Citizen.Wait(100)
    _fq = exports['fq_essentials']:get_fq_object()
end)

MySQL.ready(function ()
    mysqlReady = true
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local playerSteamId = getSteamid(source)
    local ds = exports['fq_essentials']:_getPlayerIdentifiers(source)
    
    deferrals.defer()
    deferrals.update(string.format("Hello %s. Loading data...", name))
    
    if not playerSteamId then
        deferrals.done("You are not connected to steam.")
        return
    end

    while not mysqlReady do
        Wait(50)
    end

    local blacklistVAR = nil
    
    exports['fq_essentials']:isBlacklisted(source, function()
        -- blacklistVAR = -1
    end, function(blacklist_id)
        blacklistVAR = blacklist_id
    end)

    local timeLimit = 0
    
    -- deferrals.done()
    while not blacklistVAR and timeLimit < 5000 do
        Wait(125)
        timeLimit = timeLimit + 125
    end

    if blacklistVAR then
        deferrals.done('\nYou are blacklisted on this server! Appeal ID: '..blacklistVAR..'\nWebsite: Ragekill.pl\n\n')
        return
    end

    local outsideVAR = nil

    -- exports['fq_essentials']:isBanned(source, function(data) -- not banned
    exports['fq_essentials']:isBanned(ds, function(data) -- not banned
        outsideVAR = -1
    end, function(data) -- banned
        outsideVAR = data[1]
        return
    end)

    timeLimit = 0
    
    -- deferrals.done()
    while not outsideVAR and timeLimit < 5000 do
        Wait(125)
        timeLimit = timeLimit + 125
    end

    if outsideVAR == -1 then
        deferrals.done()
    elseif type(outsideVAR) == 'table' then
        local ban = outsideVAR
        local b_time = os.date("%d-%m-%Y %H:%M:%S", ban.unban_time-3600)
        local exp = os.date('*t', ban.unban_time - 3600 - os.time())
        exp.hour = exp.hour - 1

        deferrals.presentCard('{"type":"AdaptiveCard","version":"1.0","body":[{"type":"TextBlock","text":"Ragekill.pl | NETWORK","horizontalAlignment":'
        ..'"Center","weight":"Bolder","size":"Medium","color":"Good"},'
        ..'{"type":"TextBlock","text":"You are currently banned!","horizontalAlignment":"Center","color":"Attention"},{"type":"TextBlock",'
        ..'"text":"Banned by: '..ban.banning_nick..'","horizontalAlignment":"Center"},{"type":"TextBlock","text":"Reason: '..ban.reason..'","horizontalAlignment":"Center"},{"type":"TextBlock",'
        ..'"text":"Expires in: '..exp.hour..'h '..exp.min..'m ('..b_time..')","horizontalAlignment":"Center"},{"type":"TextBlock","text":"Visit www.ragekill.pl to appeal.","horizontalAlignment":'
        ..'"Center","size":"Small","color":"Good"}],"minHeight":"11px","$schema":"http://adaptivecards.io/schemas/adaptive-card.json","fallbackText":'
        ..'"asdasdasd asda as "}')

        timeLimit = 0
    
        while timeLimit < 10000 do
            Wait(125)
            timeLimit = timeLimit + 125
        end

        deferrals.done('Ragekill.pl')
        -- deferrals.done('You are banned!\nBy: '..ban.banning_nick..'\nUnban on: '
        -- -- ..os.date("%H:%M:%S %d.%m.%Y", ban.ub_time)..'\nReason: '..ban.reason
        -- ..b_time..'\nReason: '..ban.reason
        -- ..'\nVisit www.ragekill.pl to appeal.')
    else
        deferrals.done('Something went wrong.\n Get help on discord or ragekill.pl!')
    end
end)

-- local defaultUpgrades = '[[false,false],[false,false,false],[false,false],[false,false,false,false]]'

RegisterNetEvent('fq:onPlayerScriptStart')
AddEventHandler('fq:onPlayerScriptStart', function(resourceName)    
    if resourceName == 'fq_player' then
        local _src = source
        local playerSteamId = getSteamid(_src)

        TriggerEvent('fq:setPlayerSteamID', _src, playerSteamId)
        
        if not playerMoney[_src] then
            TriggerEvent('fq:setPlayerSteamID', source, playerSteamId)
            TriggerEvent('fq:playerConnected', source)
            
        else
            -- player money[src] is set, kick/punish player for triggering it twice
            DropPlayer(source, '')
        end
    end
end)

RegisterNetEvent('fq:setPlayerDataSV')
AddEventHandler('fq:setPlayerDataSV', function(_src)
    if exports['fq_essentials']:isCallerConsole(source) then
        local data = _fq.GetPlayerData(_src)
        playerMoney[_src] = data.money
        playerStats[_src] = {}
        playerStats[_src][1] = data.kills
        playerStats[_src][2] = data.deaths
        playerStats[_src][3] = 0
        playerStats[_src][4] = false
        TriggerClientEvent('fq:updateLocalMoney', _src, data.money, data.upgrades)
        exports['fq_shop']:setPlayerUpgrades(_src, data.upgrades)
        print('^3Player (' .. _src .. ') data set!^7')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local playerSteamId = getSteamid(src)
    local ups = exports['fq_shop']:getPlayerUpgrades(src)
    ups = json.encode(ups)

    if playerMoney[src] then
        if ups then
            MySQL.Async.execute(
                'UPDATE tbl_accounts SET money = @mon, kills = @kls, deaths = @dths, upgrades = @ups, spent_time = @time WHERE id_account=@id',
            {['@time'] = _fq.GetPlayerData(src).spent_time + playerStats[src][3], ['@mon'] = playerMoney[src], ['@ups'] = ups, ['@id'] = _fq.GetPlayerAccID(src), ['@kls'] = playerStats[src][1], ['@dths'] = playerStats[src][2]}, function(res) 
                TriggerEvent('fq:playerLeftEss', src)
                TriggerEvent('fq:playerLeftShop', src)
            end)
        else
            MySQL.Async.execute('UPDATE tbl_accounts SET money = @mon, kills = @kls, deaths = @dths, spent_time = @time WHERE id_account=@id',
            {['@time'] = _fq.GetPlayerData(src).spent_time + playerStats[src][3], ['@mon'] = playerMoney[src], ['@id'] = _fq.GetPlayerAccID(src), ['@kls'] = playerStats[src][1], ['@dths'] = playerStats[src][2]}, function(res) 
                TriggerEvent('fq:playerLeftEss', src)
                TriggerEvent('fq:playerLeftShop', src)
            end)
        end

        playerMoney[src] = nil
        playerStats[src] = nil
        print('^6Client records deleted: ^3' .. src..'.^7')
    end

    print('^6* Player left: ^3' .. (source or 'null') .. '.^7')

    if source and source > 0 then
        -- DropPlayer(source)
    end
end)

RegisterNetEvent('fq:removeMoney')
AddEventHandler('fq:removeMoney', function(amount, src)
    source = src and src or source
    if tonumber(amount) then
        amount = math.abs(amount)
        
        playerMoney[source] = playerMoney[source] - amount
        TriggerClientEvent('fq:updateLocalMoney', source, playerMoney[source])
        print('$' .. amount .. ' removed from ' .. source)
    end
end)

-- TO CHANGE, client can abuse it easly
-- only server triggers this event, secure it so only sv can trigger it
-- solution: make it function ;)
-- RegisterServerEvent('fq:updateStats')
-- AddEventHandler('fq:updateStats', function(src, index, value)
--     if playerStats[src] then
--         playerStats[src][index] = playerStats[src][index] + value
--     end
-- end)

RegisterServerEvent('fq:addLocalMessage')
AddEventHandler('fq:addLocalMessage', function(message, coords, gangid)
    if not message then
        return
    end

    TriggerClientEvent('fq:getLocalMessage', -1, message, coords, gangid)
end)

-- backup money saving in DB      ////     ADD GUN UPGRADES TO BAKCUP
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(30000) -- MAKE IT TO 5 MINUTES OR LONGER ***
        for k, v in pairs(playerMoney) do
            if v then
                -- local playerSteamId = getSteamid(k)
                local ups = exports['fq_shop']:getPlayerUpgrades(tonumber(k))
                ups = json.encode(ups)

                MySQL.Async.execute('UPDATE tbl_accounts SET money = @mon, kills = @kls, deaths = @dths, upgrades = @ups, spent_time = @time WHERE id_account=@id',
                {['@time'] = _fq.GetPlayerData(k).spent_time + playerStats[k][3], ['@mon'] = playerMoney[k], ['@ups'] = ups, ['@id'] = _fq.GetPlayerAccID(k), ['@kls'] = playerStats[k][1], ['@dths'] = playerStats[k][2]}, function(res) 
                end)
                print('^5# ^3Data updated > ^2' .. playerMoney[k] .. ' ' .. ups .. ' ^3ID: ^2' .. k..'.^7')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        -- add 1 to time spent on server every 1 minute
        Citizen.Wait(60000)
        for k, v in pairs(playerStats) do
            TriggerEvent('fq:updateStats', k, 3, 1)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2500)
        TriggerClientEvent('fq:getStatInfo', -1, playerMoney, playerStats)
    end
end)

-- MONEY FOR PLAYING ON SERVER
local moneyForPlaying = 500
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(480000) -- 8 min
        for k, v in pairs(playerMoney) do
            if exports['fq_gangs']:isPlayerInAnyGang(k) then
                addMoneyToPlayer(k, moneyForPlaying)
            end
        end
        -- TriggerClientEvent('fq:sendNotification', -1, '~o~Ragekill.pl ~c~| ~w~Dostales ~b~$'..moneyForPlaying..'~w~ za granie na serwerze!')
        -- money_for_playing_msg
        TriggerClientEvent('fq:sendNotification', -1, 'ESS', 'money_for_playing_msg', {moneyForPlaying})
    end
end)

function updateStats(src, index, modType, value)
    if playerStats[src] then
        if modType == 'add' then
            playerStats[src][index] = playerStats[src][index] + value
        elseif modType == 'remove' then
            playerStats[src][index] = playerStats[src][index] - value
        elseif modType == 'set' then
            playerStats[src][index] = value
        end
    end
end
exports('updateStats', updateStats)

function getSteamid(source)
    local player_steam_id = nil
    local ids = GetPlayerIdentifiers(source)
    for i, v in ipairs(ids) do 
        if string.find(v, 'steam') then
            player_steam_id = v:sub(7)
            break
        end
    end
    
    return player_steam_id
end

function addMoneyToPlayer(playerID, money)
    if playerMoney[playerID] then
        playerMoney[playerID] = playerMoney[playerID] + money
        TriggerClientEvent('fq:updateLocalMoney', playerID, playerMoney[playerID])
    end
end

function getPlayerMoney(playerID)
    if playerMoney[playerID] then
        return playerMoney[playerID]
    end
end

exports('addMoneyToPlayer', addMoneyToPlayer)
exports('getPlayerMoney', getPlayerMoney)


