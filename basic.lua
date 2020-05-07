-- SetArtificialLightsState(true)
SetPoliceIgnorePlayer(PlayerId(), true)
SetDispatchCopsForPlayer(PlayerId(), true)
SetMaxWantedLevel(0)

AddEventHandler('onClientMapStart', function(resourceName)

    -- exports.spawnmanager:spawnPlayer()
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        StatSetInt('MP0_STAMINA', 100, true)
        StatSetInt('MP0_STRENGTH', 100, true)
        -- StatSetInt('MP0_LUNG_CAPACITY', 100, true)
        -- StatSetInt('MP0_WHEELIE_ABILITY', 100, true)
        -- StatSetInt('MP0_FLYING_ABILITY', 100, true)
        -- StatSetInt('MP0_SHOOTING_ABILITY', 100, true)
        -- StatSetInt('MP0_STEALTH_ABILITY', 100, true)

        --  DISABLE SPAWN OF CARS AND PEDS
        -- SetVehicleDensityMultiplierThisFrame(0.0)
		-- SetRandomVehicleDensityMultiplierThisFrame(0.0)
        -- SetParkedVehicleDensityMultiplierThisFrame(0.0)
        -- SetSomeVehicleDensityMultiplierThisFrame(0.0)
        -- SetPedDensityMultiplierThisFrame(0.0)
        -- SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        -- SetGarbageTrucks(0)
        -- SetRandomBoats(0)
        SetPlayerWantedLevelNow(PlayerId(), false)
        -- StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    end
end)