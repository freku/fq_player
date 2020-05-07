local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs
local msgCFG = CFG.msg.pl
local ESXs = nil

local gangid = nil
local lastTeamPick = nil
local pickCooldown = 5000
local showBigMap = false
local isMoneyShown = false

local localMoney = nil -- or 0

local inventory = {
    health = 0,
    armor = 0
}

local blipPoses = {
    consumable = {
        {['x']=-795.95318603516,['y']=-940.65203857422,['z']=16.749332427979},
        {['x']=-1230.7430419922,['y']=-1449.3647460938,['z']=4.2524151802063},
        {['x']=324.40927124023,['y']=-230.51161193848,['z']=54.22114944458},
        {['x']=189.91593933105,['y']=306.82302856445,['z']=105.39524078369},
        {['x']=428.36602783203,['y']=-1065.1263427734,['z']=29.213220596313},
        {['x']=41.33687210083,['y']=-1911.1821289063,['z']=21.965536117554},
        {['x']=446.03555297852,['y']=-1578.8836669922,['z']=29.282596588135},
        {['x']=894.66821289063,['y']=-2136.2084960938,['z']=30.482759475708},
    },
    weapons = {
        {['x']=-760.86328125,['y']=-919.41625976563,['z']=19.010446548462,},
        {['x']=-1247.1440429688,['y']=-1472.6999511719,['z']=4.2577729225159,},
        {['x']=292.24176025391,['y']=-224.1153717041,['z']=53.977954864502,},
        {['x']=196.65281677246,['y']=230.93196105957,['z']=105.55369567871,},
        {['x']=431.95599365234,['y']=-980.89837646484,['z']=30.710725784302,},
        {['x']=75.343444824219,['y']=-1936.5815429688,['z']=20.970720291138,},
        {['x']=502.24966430664,['y']=-1534.3016357422,['z']=29.259605407715,},
        {['x']=914.94140625,['y']=-2154.2758789063,['z']=30.494647979736,},
    },
    car_repair = {
        {['x']=247.84393310547,['y']=-1406.8431396484,['z']=29.913408279419},
        {['x']=216.21047973633,['y']=-801.99304199219,['z']=30.122159957886},
        {['x']=907.12646484375,['y']=-1732.2467041016,['z']=29.907312393188},
        {['x']=981.41168212891,['y']=-2444.4528808594,['z']=28.542001724243},
        {['x']=-1143.1094970703,['y']=-916.35772705078,['z']=2.6948027610779},
        {['x']=-1125.8780517578,['y']=-1433.4434814453,['z']=5.0770945549011},
        {['x']=-33.355159759521,['y']=-97.306198120117,['z']=57.337879180908},
        {['x']=458.03860473633,['y']=15.077293395996,['z']=86.244819641113},

    },
    hp_pickups = {
        {['x']=68.158142089844,['y']=-109.97537231445,['z']=56.35404586792},
        {['x']=-1272.5296630859,['y']=-1097.9721679688,['z']=7.5775871276855},
        {['x']=295.60723876953,['y']=-1446.2563476563,['z']=29.555154800415},
        {['x']=806.14343261719,['y']=-2132.3461914063,['z']=29.366399765015}
    },
    armor_pickups = {
        {['x']=205.57997131348,['y']=96.341217041016,['z']=93.541351318359},
        {['x']=-1104.9278564453,['y']=-1250.6572265625,['z']=5.0768399238586},
        {['x']=-38.383571624756,['y']=-1448.4035644531,['z']=31.50319480896},
        {['x']=982.84533691406,['y']=-1870.8466796875,['z']=31.028429031372},
    }
}

Citizen.CreateThread(function()
    Citizen.Wait(50)
    ESXs = exports['fq_callbacks']:getServerObject()
end)

RegisterNetEvent('fq:onAuth')
AddEventHandler('fq:onAuth', function()
    msgCFG = CFG.msg[exports['fq_login']:getLang()]
end)

-- RELATIONS HIPS WERE SET HERE BEFORE RELATIONS.lua

AddEventHandler('fq:pickedCharacter', function(gangIndex, modelIndex)
    if gCFG[gangIndex] and gCFG[gangIndex].models[modelIndex] then
        gangid = gangIndex
        lastTeamPick = GetGameTimer()
        SetPedRelationshipGroupHash(PlayerPedId(), gCFG[gangIndex].name)
        SetCanAttackFriendly(PlayerPedId(), false, false)
        TriggerEvent('fq:showMoney', true)
        TriggerEvent('fq:showKillBox', true)
    end
end)

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() == resourceName) then
        TriggerServerEvent('fq:onPlayerScriptStart', resourceName)

        drawBlipsFor(blipPoses.consumable, 59, 9, msgCFG.c.pl_cons_shop)
        drawBlipsFor(blipPoses.weapons, 110, 82, msgCFG.c.pl_weapon_shop)
        drawBlipsFor(blipPoses.car_repair, 100, 31, msgCFG.c.pl_repair_car_shop)

        drawBlipsFor(blipPoses.hp_pickups, 153, 35, msgCFG.c.pl_hp_pickup)
        drawBlipsFor(blipPoses.armor_pickups, 175, 39, msgCFG.c.pl_armor_pickup)
        setPickup(blipPoses.hp_pickups, 'PICKUP_HEALTH_STANDARD', true)
        setPickup(blipPoses.armor_pickups, 'PICKUP_ARMOUR_STANDARD', true)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1) 
                local pos = GetEntityCoords(GetPlayerPed(-1))
                for i, v in ipairs(blipPoses.consumable) do
                    if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 50.0 then
                        DrawMarker(1, v.x,v.y,v.z-1, 0,0,0, 0,0,0, 2.0,2.0,1.0, 52,221,1,80, false,false,2,false, nil,nil,false)
                        DrawMarker(20, v.x,v.y,v.z+2, 0,0,0, 180.0,0,0, 2.0,2.0,1.7, 52,221,1,80, true,true,2,false, nil,nil,false)
                        
                        if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 2.0 then
                            showHelp(msgCFG.c.pl_pickup_help_msg)
                            if IsControlJustPressed(0, 38) then
                                TriggerEvent('fq:showShop', true, {'u'})
                            end
                        end
                    end
                end
               for i, v in ipairs(blipPoses.weapons) do
                    if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 50.0 then
                        DrawMarker(1, v.x,v.y,v.z-1, 0,0,0, 0,0,0, 2.0,2.0,1.0, 255,136,0,80, false,false,2,false, nil,nil,false)
                        DrawMarker(20, v.x,v.y,v.z+2, 0,0,0, 180.0,0,0, 2.0,2.0,1.7, 255,136,0,80, true,true,2,false, nil,nil,false)
                        
                        if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 2.0 then
                            showHelp(msgCFG.c.pl_weapon_shop_help_msg)
                            if IsControlJustPressed(0, 38) then
                                TriggerEvent('fq:showShop', true, {'w'})
                            end
                        end
                    end
                end
                for i, v in ipairs(blipPoses.car_repair) do
                    if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 50.0 then
                        DrawMarker(1, v.x,v.y,v.z-1, 0,0,0, 0,0,0, 3.0,3.0,1.5, 0,184,230,80, false,false,2,false, nil,nil,false)
                        
                        if GetDistanceBetweenCoords(pos.x,pos.y,pos.z,v.x,v.y,v.z,false) < 2.0 then
                            showHelp(msgCFG.c.pl_repair_shop_help_msg)
                            if IsControlJustPressed(0, 38) then
                                TriggerEvent('fq:repairCar')
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- AddEventHandler('baseevents:onPlayerKilled', function(killerID, data)

-- end)

RegisterNetEvent('fq:repairCar')
AddEventHandler('fq:repairCar', function()
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)

    if veh ~= 0 then
        ESXs.TriggerServerCallback('fq:canBuyItem', function(canBuy)
            if canBuy then
                SetVehicleFixed(veh)
                TriggerServerEvent('fq:removeMoneyByItemID', 'car')
                TriggerEvent('fq:sendNotification', msgCFG.c.pl_repaired_car_msg)
            else
                TriggerEvent('fq:sendNotification', msgCFG.c.pl_cant_repair_car_msg)
            end
        end, 'car')
    end
end)

RegisterNetEvent('fq:healPlayer')
AddEventHandler('fq:healPlayer', function()
    local toHealHP = 33
    local maxHP = GetEntityMaxHealth(GetPlayerPed(-1))
    local currentHP = GetEntityHealth(GetPlayerPed(-1))
    
    local animDict = 'anim@mp_snowball'
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(50)
    end
    if not IsEntityPlayingAnim(GetPlayerPed(-1), animDict, 'pickup_snowball', 3) then
        Citizen.CreateThread(function()
            TaskPlayAnim(GetPlayerPed(-1), animDict, 'pickup_snowball', 8.0, 8.0, 4500, 0, 1, false, false, false)
            
            Citizen.Wait(1)
            while IsEntityPlayingAnim(GetPlayerPed(-1), animDict, 'pickup_snowball', 3) do
                Citizen.Wait(10)
            end

            if inventory.health > 0 then
                if maxHP - currentHP < 33 then
                    SetEntityHealth(GetPlayerPed(-1), currentHP + maxHP - currentHP)
                else
                    SetEntityHealth(GetPlayerPed(-1), currentHP + toHealHP)
                end
                removeItem('health')
            end
        end)
    end
end)

RegisterNetEvent('fq:getLocalMessage')
AddEventHandler('fq:getLocalMessage', function(msg, coords, gid)
    if gangid and gid == gangid then
        ncoords = {x=coords.x,y=coords.y,z=coords.z+1.055}
        exports.motiontext:Draw3DTextTimeout({
            xyz=ncoords,
            timeout=1500,
            isMoving=true,
            text={
                content=msg,
                rgb={255 , 255, 255},
                textOutline=true,
                scaleMultiplier=1,
                font=4 -- or 5 slim font
            },
            perspectiveScale=5,
            radius=350,
        })
    end
end)

RegisterNetEvent('fq:updateLocalMoney')
AddEventHandler('fq:updateLocalMoney', function(money)
    if not localMoney then
        TriggerEvent('fq:setMoneyUI', money)
    else
        TriggerEvent('fq:addMoneyUI', money - localMoney)
    end

    localMoney = money
end)

RegisterNetEvent('fq:showMoney')
AddEventHandler('fq:showMoney', function(state)
	SendNUIMessage({
		type = 'ON_STATE',
        display = state,
        gid = gangid
	})
	
	isMoneyShown = state
end)

RegisterNetEvent('fq:addMoneyUI')
AddEventHandler('fq:addMoneyUI', function(mon)
	SendNUIMessage({
		type = 'ON_UPDATE',
		money = mon
	})
end)

RegisterNetEvent('fq:setMoneyUI')
AddEventHandler('fq:setMoneyUI', function(mon)
	SendNUIMessage({
		type = 'ON_SET',
		money = mon
	})
end)

RegisterNetEvent('fq:setPlayerInfoNull')
AddEventHandler('fq:setPlayerInfoNull', function()
    gangid = nil
    lastTeamPick = nil
end)

RegisterCommand('chgang', function(source, args)
    local dif = GetTimeDifference(GetGameTimer(), lastTeamPick)
    if lastTeamPick and dif > pickCooldown then
        -- gangid = nil
        -- lastTeamPick = nil
        TriggerEvent('fq:setPlayerInfoNull') -- move it to showMenu event?
        TriggerEvent('fq:showMenu')
        TriggerEvent('fq:clearBlips')
        TriggerServerEvent('fq:removePlayerFromGang')
        TriggerEvent('fq:showMoney', false)
        TriggerEvent('fq:showKillBox', false)
    else
        -- TriggerEvent('fq:sendNotification', 'You cant pick a gang for ' .. math.floor((pickCooldown - dif) / 1000) .. 's')
        TriggerEvent('fq:sendNotification', string.format(msgCFG.c.pl_cant_change_gang, math.floor((pickCooldown - dif) / 1000)))
    end
end)

RegisterCommand('shop', function(source, args)
    if args[1] then
        if args[2] then
            TriggerEvent('fq:showShop', true, {'w', 'u'})
            return     
        end
        TriggerEvent('fq:showShop', true, {'w'})
        return     
    end
    TriggerEvent('fq:showShop', true)
end)

RegisterCommand('ablip', function(source, args)
    -- 436 - fire  - twoje atakowane
    -- 432 - radar - ty atakujacy
    -- 310 - skull
    -- 461 - shild with X on the center - twoje atakowane v2
    
    local p = {x= 1000.0, y=1000.0, z=0.0}
    local blip2 = AddBlipForCoord(p.x, p.y, p.z)
    SetBlipSprite(blip2, 310)
    SetBlipColour(blip2, 35)
    SetBlipScale(blip2, 1.15)
    SetBlipFlashes(blip2, true)
    SetBlipFlashInterval(blip2, 500)
    ShowHeadingIndicatorOnBlip(blip2, true)
end)

local gangColors = {
    '~p~', '~g~', '~y~', '~r~'
}

RegisterCommand('l', function(src, args)
    local msg = table.concat(args, " ")

    if msg and gangid then 
        -- local prefix = '[' .. gCFG[gangid].name:sub(1,1) .. ']'
        local prefix = gangColors[gangid] .. GetPlayerName(PlayerId()) .. ': ~s~'
        TriggerServerEvent('fq:addLocalMessage', prefix .. msg, GetEntityCoords(GetPlayerPed(-1)), gangid)
    end
end)

RegisterCommand('gchat', function(src, args)
    local msg = table.concat(args, ' ')

    if msg and gangid then 
        TriggerServerEvent('fq:gangChatMsg', GetPlayerName(PlayerId()), msg, gangid)
    end
end)

RegisterCommand('healme', function(src, args)
    if inventory.health > 0 then
        TriggerEvent('fq:healPlayer')
    else
        TriggerEvent('fq:sendNotification', msgCFG.c.pl_no_med)
    end
end)

RegisterCommand('rarmor', function(src, args)
    -- repair armor here
end)

RegisterCommand('inv', function(src, args)
    print(json.encode(inventory))
end)

function drawBlipsFor(array, sprite, color, name)
    for i, v in ipairs(array) do
        local blip2 = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip2, sprite)
        SetBlipColour(blip2, color)
        SetBlipAsShortRange(blip2, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(name)
        EndTextCommandSetBlipName(blip2)
    end
end

function showHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function setPickup(posArray, name, regen)
    for i, v in ipairs(posArray) do
        local pup = CreatePickup(GetHashKey(name), v.x, v.y, v.z)
        if regen then
            SetPickupRegenerationTime(pup, 300000) -- 5 min
        end
    end
end

function getInventory()
    return inventory
end

function addItem(name)
    if inventory[name] then
        inventory[name] = inventory[name] + 1
    end
end

function removeItem(name)
    if inventory[name] and inventory[name] > 0 then
        inventory[name] = inventory[name] - 1
    end
end

function getGangId()
    return gangid
end

exports('getInventory', getInventory)
exports('addItem', addItem)
exports('getGangId', getGangId)

-- SetBigmapActive(true , false)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if gangid then
            if IsPauseMenuActive() and isMoneyShown then
                TriggerEvent('fq:showMoney', false)
            elseif not isMoneyShown and not IsPauseMenuActive() then
                TriggerEvent('fq:showMoney', true)
            end
        end
    end
end)
--         -- if IsDisabledControlJustPressed(0, 20) or IsControlJustPressed(0, 20) then
--         --     SetBigmapActive(true, false)
--         -- end
--         -- if IsControlJustReleased(0, 20) or IsDisabledControlJustReleased(0, 20) then
--         --     SetBigmapActive(false, false)
--         -- end
--     end
-- end)

