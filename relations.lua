local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs

local gangNames = {
    'AMBIENT_GANG_LOST',
    'AMBIENT_GANG_MEXICAN',
    'AMBIENT_GANG_FAMILY ',
    'AMBIENT_GANG_BALLAS',
    'AMBIENT_GANG_MARABUNTE',
    'AMBIENT_GANG_CULT',
    'AMBIENT_GANG_SALVA',
    'AMBIENT_GANG_WEICHENG',
    'AMBIENT_GANG_HILLBILLY',
    'GANG_1',
    'GANG_2',
    'GANG_9',
    'GANG_10'
}

do --set up relationships between gangs
    NetworkSetFriendlyFireOption(false)
    AddRelationshipGroup(gCFG[1].name)
    AddRelationshipGroup(gCFG[2].name)
    AddRelationshipGroup(gCFG[3].name)
    AddRelationshipGroup(gCFG[4].name)

    for _, v in ipairs(gCFG) do
        for i, k in ipairs(gCFG) do
            if v.name ~= k.name then
                SetRelationshipBetweenGroups(5, v.name, k.name)
            end
        end
    end
end

-- to raczej wystarczy raz zrobic, nie potrzebna petla

Citizen.CreateThread(function()

	while true do
        Citizen.Wait(1)
        local playerRelationHash = GetPedRelationshipGroupHash(GetPlayerPed(-1))

        for i, v in ipairs(gangNames) do
            SetRelationshipBetweenGroups(1, playerRelationHash, v)
            SetRelationshipBetweenGroups(1, v, playerRelationHash)
        end
    end
end)