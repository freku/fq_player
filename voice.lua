local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs
local msgCFG = CFG.msg.pl

local voiceState = 'normal'
-- normal, gang
local canTalk = nil

local voiceIndex = 1
local voiceVolume = {
    {'normal', 5.0},
    {'whisper', 1.0},
    {'shout', 12.0},
}

RegisterNetEvent('fq:onAuth')
AddEventHandler('fq:onAuth', function()
    msgCFG = CFG.msg[exports['fq_login']:getLang()]
end)

AddEventHandler('onClientMapStart', function()
    NetworkSetVoiceChannel(tostring(GetGameTimer()))
    NetworkSetTalkerProximity(voiceVolume[1][2])
end)

AddEventHandler('fq:pickedCharacter', function(gangIndex, modelIndex)
    if gCFG[gangIndex] and gCFG[gangIndex].models[modelIndex] then
        NetworkClearVoiceChannel()
        canTalk = true
    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1)
        if canTalk then
            if IsControlJustPressed(0, 311) then -- K, zmiana kanalu
                if exports['fq_player'] then
                    local gid = exports['fq_player']:getGangId()
                    
                    if voiceState == 'normal' then
                        NetworkSetVoiceChannel(gCFG[gid].name)
                        NetworkSetTalkerProximity(0.0)
                        voiceState = 'gang'
                    else
                        NetworkClearVoiceChannel()
                        NetworkSetTalkerProximity(voiceVolume[voiceIndex][2])
                        voiceState = 'normal'
                    end
                end
            end
            
            if IsControlJustPressed(0, 303) then -- U, zmiana glosnosci
                changeVolume()
            end

            -- drawText('Talking mode: '..voiceState..' (press K)', 0.85, 0.87, 100, 100, 0)
            drawText(string.format(msgCFG.c.pl_voice_talk_mode, voiceState), 0.85, 0.87, 100, 100, 0)
            if NetworkIsPlayerTalking(PlayerId()) then
                drawText(string.format(msgCFG.c.pl_voice_voluem, voiceVolume[voiceIndex][1]), 0.85, 0.90, 255, 102, 102)
            else
                drawText(string.format(msgCFG.c.pl_voice_voluem, voiceVolume[voiceIndex][1]), 0.85, 0.90, 255, 0, 255)
            end
        end
    end
end)

function changeVolume()
    if voiceIndex == #voiceVolume then
        voiceIndex = 1
    else 
        voiceIndex = voiceIndex + 1
    end

    NetworkSetTalkerProximity(voiceVolume[voiceIndex][2])
end

function drawText(msg, x,y, r,g,b)
    SetTextFont(4)
	SetTextScale(0.5, 0.5)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayText(x, y)
end