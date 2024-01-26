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
        local distance = #(Config.Shops.actionjob - PlayerCoords)
        if distance > 10.0 then
            sleep = 500
        else
            sleep = 0
            if distance < 1.0 and not inCam and ESX.PlayerData.job.name == Config.Shops.jobName and Config.Shops.requiredJob then
                ESX.ShowHelpNotification(locale('interact_marker'))
                DrawMarker(2, Config.Shops.actionjob.x, Config.Shops.actionjob.y, Config.Shops.actionjob.z, 0.0, 0.0, 0.0,
                    0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if IsControlJustPressed(0, 38) then
                    OpenActionCardealer()
                end
            end
        end
        Wait(sleep)
    end
end)

function OpenActionCardealer()
    lib.registerMenu({
        id = 'openActionCardealer',
        title = locale("cardealer_action_cardealer"),
        position = Config.PositioMenu,
        options = {
            { label = locale("cardealer_buy_vehicle"), icon = "nui://px_vehicleshop/img/icon/money.png"},
            { label = locale("cardealer_vehicle_purschased"), icon = "nui://px_vehicleshop/img/icon/garage.png", },
        },
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            CamON("job")
        elseif selected == 2 then
            OpenVehicleSaved()
        end
    end)
    lib.showMenu('openActionCardealer')
end

function OpenVehicleSaved()
    local open
    local options = {}
    local data = lib.callback.await('px_vehicleShop:getAllVehicle', false)
    if type(data) == "table" then
        if not data then
            open = false
        else
            open = true
            for k, v in pairs(data) do
                options[#options + 1] = {
                    label =  string.upper(string.sub(v.name, 1, 1)) ..
                    string.sub(v.name, 2), args = { vehicle = v.name, price = v.price, k = k }
                }
            end
        end
    end
    if open then
        lib.registerMenu({
            id = 'openVehicleSaved',
            title = locale("cardealer_vehicle_saved"),
            position = Config.PositioMenu,
            options = options,
            onClose = function()
                lib.showMenu('openActionCardealer')
            end,
        }, function(selected, scrollIndex, args)
            if selected then
                OpenActionVehicleSaved(args.vehicle, args.price, args.k)
            end
        end)
        lib.showMenu('openVehicleSaved')
    else
        lib.notify({
            title = locale("px_vehicleshop_notify"),
            description = "There are no vehicles in the depot",
            type = 'error',
            position = 'top',
        })
    end
end

function OpenActionVehicleSaved(vehicle, price, k)
    lib.registerMenu({
        id = 'openVehicleActionSaved',
        title = locale("cardealer_vehicle_saved"),
        position = Config.PositioMenu,
        options = {
            { label = locale("cardealer_action_vechile_saved_show"),   close = false },
            { label = locale("cardealer_action_vechile_saved_sell"),   close = true },
            { label = locale("cardealer_action_vechile_saved_return"), close = true }
        },
        onClose = function()
            lib.showMenu('openVehicleSaved')
            if lastSelectedVehicleEntity ~= nil then
                DeleteEntity(lastSelectedVehicleEntity)
            end
        end
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            spawnVehicle(vehicle, "job")
        elseif selected == 2 then
            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer(coords)
            if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                lib.notify({
                    title = locale("px_vehicleshop_notify"),
                    description = "No players nearby",
                    type = 'error',
                    position = 'top',
                })
            else
                local player = GetPlayerServerId(closestPlayer)
                SellVehicle(vehicle, player)
            end
        elseif selected == 3 then
            local alert = lib.alertDialog({
                header = locale("cardealer_alert_return_vehicle_header"),
                content = locale("cardealer_alert_return_vehicle_content"),
                centered = true,
                cancel = true
            })
            if alert == "confirm" then
                TriggerServerEvent('px_vehicleshop:returnVehicle', vehicle, price, k)
                if lastSelectedVehicleEntity ~= nil then
                    DeleteEntity(lastSelectedVehicleEntity)
                end
            else
                return
            end
        end
    end)
    lib.showMenu('openVehicleActionSaved')
end

function SellVehicle(vehicle, player)
    local PlateGenerated = GeneratePlate()
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
    ESX.Game.SpawnVehicle(vehicle, Config.Shops.spawnVehicleBuy, 339.41, function(vehicle)
        local newPlate     = PlateGenerated
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate
        SetVehicleNumberPlateText(vehicle, PlateGenerated)
        TriggerServerEvent('px_vehicleshop:SellVehicle', vehicleProps, "car", price, player)
    end)
    debug(vehicle)
    TriggerServerEvent('px_vehicleshop:deleteVehicle', vehicle)
end