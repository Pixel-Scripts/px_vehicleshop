RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        local PlayerCoords = GetEntityCoords(cache.ped)
        local distance = #(Config.Shops.bossMenu - PlayerCoords)
        if distance > 10.0 then
            sleep = 500
        else
            sleep = 0
            if distance < 1.0 and not inCam and ESX.PlayerData.job.name == Config.Shops.jobName and ESX.PlayerData.job.grade_label == Config.Shops.gradeBoss and Config.Shops.requiredJob then
                ESX.ShowHelpNotification(locale('interact_marker'))
                DrawMarker(2, Config.Shops.bossMenu.x, Config.Shops.bossMenu.y, Config.Shops.bossMenu.z, 0.0, 0.0, 0.0,
                    0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if IsControlJustPressed(0, 38) then
                    OpenBossMenu(Config.Shops.jobName)
                end
            end
        end
        Wait(sleep)
    end
end)

function OpenBossMenu(k)
    TriggerEvent('esx_society:openBossMenu', k, function(data, menu)
        menu.close()
    end, {wash = false})
end