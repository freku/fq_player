local menuButtons = {'Component: ', 'Drawable: ', 'Texture: '}
local menuIndex = 1
local componentLimit = 11
local componentIndex = 0
local pedDrawableLimit = GetNumberOfPedDrawableVariations(GetPlayerPed(-1), componentIndex)
local drawableIndex = 0
local txtVariationsLimit = GetNumberOfPedTextureVariations(GetPlayerPed(-1), componentIndex, drawableIndex)
local txtVariationIndex = 0
local namesTable = {
    'Face',
    'Mask',
    'Hair',
    'Torso',
    'Leg',
    'Parachute / bag',
    'Shoes',
    'Accessory',
    'Undershirt',
    'Kevlar',
    'Badge',
    'Torso 2',
}

local cMode = false

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.25, 0.25)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function limitCheck(dir, variable, limit)
    variable = variable + dir

    if variable > limit then
        variable = 0
    end
    if variable < 0 then
        variable = limit
    end

    return variable
end

function changeValueSetting(dir)
    local ped = GetPlayerPed(-1)

    if menuIndex == 1 then
        componentIndex = limitCheck(dir, componentIndex, componentLimit)

    elseif menuIndex == 2 then
        drawableIndex = limitCheck(dir, drawableIndex, pedDrawableLimit)
        txtVariationIndex = 0
        SetPedComponentVariation(ped, componentIndex, drawableIndex, txtVariationIndex, 2)
    else -- 3
        txtVariationIndex = limitCheck(dir, txtVariationIndex, txtVariationsLimit)
        SetPedComponentVariation(ped, componentIndex, drawableIndex, txtVariationIndex, 2)
    end
    
    pedDrawableLimit = GetNumberOfPedDrawableVariations(ped, componentIndex)
    txtVariationsLimit = GetNumberOfPedTextureVariations(ped, componentIndex, drawableIndex)
end


function moveButton(dir)
    menuIndex = limitCheck(dir, menuIndex, #menuButtons)
end

RegisterCommand('cmodel', function()
    cMode = not cMode 
end)
-- mp_m_freemode_01
RegisterCommand('face', function(src, args)
    local face = 45 or tonumber(args[1])
    local skin = 45 or tonumber(args[2])
    SetPedHeadBlendData(GetPlayerPed(-1), 27, 39, 0, 27, 39, 0, 0.5, 0.0, 0.0, false)
end)

RegisterCommand('cprint', function()
    local msg = ''
    local ped = GetPlayerPed(-1)
    for i = 0, componentLimit do 
        local drawable = GetPedDrawableVariation(ped, i)
        local txt = GetPedTextureVariation(ped, i)
        msg = msg .. '['..i..']={'..drawable..','..txt..'},\n'
    end
    TriggerServerEvent('fq:print', msg)
end)

RegisterCommand('test', function(source, args)
    -- local pos = GetEntityCoords(GetPlayerPed(-1))
    local num = tonumber(args[1])
    local model = num == 1 and 'mp_m_freemode_01' or 'mp_f_freemode_01'
    RequestModel(model)
    
    while not HasModelLoaded(model) do
        Wait(5)
    end
    
    SetPlayerModel(PlayerId(), GetHashKey(model))
    SetModelAsNoLongerNeeded(model)
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1)
        if cMode then
            if IsControlJustPressed(0, 172) then -- up 
                moveButton(-1)
            end
            if IsControlJustPressed(0, 173) then -- down 
                moveButton(1)
            end
            if IsControlJustPressed(0, 174) then -- left 
                changeValueSetting(-1)
            end
            if IsControlJustPressed(0, 175) then -- right
                changeValueSetting(1)
            end

            drawTxt(0.8, 0.66, 0.6,0.6,0.50, namesTable[componentIndex+1]..': '.. componentIndex..' / '..componentLimit, (menuIndex == 1 and 0 or 255),255,255, 255)
            drawTxt(0.8, 0.68, 0.6,0.6,0.50, menuButtons[2] .. drawableIndex..' / '..pedDrawableLimit, (menuIndex == 2 and 0 or 255),255,255, 255)
            drawTxt(0.8, 0.70, 0.6,0.6,0.50, menuButtons[3] .. txtVariationIndex..' / '..txtVariationsLimit, (menuIndex == 3 and 0 or 255),255,255, 255)

        end
    end
end)