local maxDistance = 35
local width = 0.03
local height = 0.0085
local border = 0.001
local screenResolution = {}
screenResolution.x, screenResolution.y = GetScreenActiveResolution()
local peds = {}
local mpGamerTags = {}

RegisterCommand('addped', function(src, args)
    RequestModel('mp_m_freemode_01')
	
	while not HasModelLoaded('mp_m_freemode_01') do
		Wait(5)
	end
	local pos = GetEntityCoords(GetPlayerPed(-1))
    local ped = CreatePed(4, GetHashKey('mp_m_freemode_01'), pos.x, pos.y, pos.z, 0.0, false, false)
    SetPedArmour(ped, 100)
    AddArmourToPed(ped, 100)
    SetBlockingOfNonTemporaryEvents(ped, true)
    table.insert(peds, ped)
    -- print(PlayerId() .. ' ' .. src .. ' ' .. GetPlayerServerId(src))
    -- local tagId = CreateMpGamerTagForNetPlayer(
    --     GetPlayerServerId(src),
    --     'test test test',
    --     false, false,
    --     '', 0,
    --     0, 0, 0
    -- )
    local tag = CreateFakeMpGamerTag(ped, 'freku0', false, false, 'RCID', 0)
    -- SetMpGamerTagVisibility(tag, 1, true) -- crew tag           /\
    SetMpGamerTagVisibility(tag, 2, true) -- health bar
    
    SetMpGamerTagColour(tag, 0, 18)
    SetMpGamerTagAlpha(tag, 2, 255)
    SetMpGamerTagHealthBarColour(tag, 18)

    -- light green - 18, 177, 18 better 
    -- table.insert(mpGamerTags, {tag=tagId, ped=GetPlayerPed(-1)})
    table.insert(mpGamerTags, {tag=tag, ped=ped})
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        for _, v in pairs(mpGamerTags) do
            RemoveMpGamerTag(v.tag)
        end
    end
end)

Citizen.CreateThread(function()
    local camCoords = GetGameplayCamCoords()
    local fov = GetGameplayCamFov()

    -- while true do
    --     Citizen.Wait(0)
    --     for i, v in ipairs(peds) do
    --         if DoesEntityExist(v) and not IsEntityDead(v) then
    --             local targetPos = GetEntityCoords(v, true)                      --ped_id, sv_id
    --             DrawNameTag(targetPos.x, targetPos.y, targetPos.z + 0.85, camCoords, fov, v, v);
    --         end
    --     end
    -- end
end)

function DrawNameTag(x, y, z, camCoords, camFov, otherPed, otherPlayer)
    local dist = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, x, y, z, true);
    if dist <= maxDistance then
        local screenCoords = {}
        screenCoords.bool, screenCoords.x, screenCoords.y = GetScreenCoordFromWorldCoord(x, y, z);

        if not screenCoords.bool then
            return
        end

        local scale = dist / maxDistance
        scale = (scale + scale * camFov) / 2
        if scale < 0.6 then
            scale = 0.6
        end

        local health = GetEntityHealth(otherPed)
        health = health < 100 and 0 or (health - 100) / 100
        -- health = health < 100 ? 0 : (health - 100) / 100

        local armour = GetPedArmour(otherPed) / 100
        y = screenCoords.y;
        y = y - scale * (0.005 * (screenResolution.y / 1080))
        x = screenCoords.x
        -- if (IsPlayerFreeAimingAtEntity(PlayerId(), otherPed)) then
            local y2 = y
            DrawId(x - 0.0122, y2 - 0.030, 'freku0') -- otherPlayer - 0.0125
            if armour > 0 then
                local x2 = x - width / 2 - border / 2
                DrawRect(x2, y2, width + border * 2, 0.0085, 0, 0, 0, 200);
                DrawRect(x2, y2, width, height, 68, 121, 68, 255);
                DrawRect(x2 - (width / 2) * (1 - health), y2, width * health, height, 114, 203, 114, 200);

                x2 = x + width / 2 + border / 2;
                DrawRect(x2, y2, width + border * 2, height + border * 2, 0, 0, 0, 200);
                DrawRect(x2, y2, width, height, 41, 66, 78, 255);
                DrawRect(x2 - (width / 2) * (1 - armour), y2, width * armour, height, 48, 108, 135, 200);
            else 
                DrawRect(x, y2, width + border * 2, height + border * 2, 0, 0, 0, 200);
                DrawRect(x, y2, width, height, 68, 121, 68, 255);
                DrawRect(x - (width / 2) * (1 - health), y2, width * health, height, 114, 203, 114, 200);
            end
        -- end
    end
end

function DrawId(x, y, id) 
    SetTextFont(4);
    SetTextScale(0.35, 0.35);
    SetTextProportional(true);
    SetTextColour(255, 255, 255, 225);
    SetTextOutline();
    SetTextEntry('STRING');
    AddTextComponentString(id);
    DrawText(x, y);
end