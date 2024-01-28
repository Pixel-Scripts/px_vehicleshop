QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

local PlayerJob = QBCore.Functions.GetPlayerData().job

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    PlayerJob = QBCore.Functions.GetPlayerData().job

    local menu = lib.getOpenMenu()
    if menu ~= nil then
        lib.hideMenu(menu)
    end
    FreezeEntityPosition(cache.ped, false)
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
end)

local lastSelectedVehicleEntity = nil
local time = Config.TestDriveTime
local inTestDrive = false
local buy = false

Citizen.CreateThread(function()
    while true do
        local PlayerCoords = GetEntityCoords(cache.ped)
        local distance = #(Config.Shops.showcase - PlayerCoords)
        if distance > 10.0 then
            sleep = 1500
        else
            sleep = 0
            DrawMarker(2, Config.Shops.showcase.x, Config.Shops.showcase.y, Config.Shops.showcase.z, 0.0, 0.0, 0.0, 0.0,
            180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
            if distance < 2.0 and not inCam then
                exports['qb-core']:DrawText(locale('interact_marker'), 'left')
                exports['qb-core']:HideText()
                if IsControlJustPressed(0, 38) then
                    CamON('showRoom')
                end
            else
                exports['qb-core']:HideText()
            end
        end
        Wait(sleep)
    end
end)

function OpenVehicleShop(job)
    debug('Open vehicle shop')
    local options = {}
    for _, v in pairs(Config.Categories) do
        debug(v.label)
        options[#options + 1] = {
            label = v.label, args = { category = v.name }
        }
    end
    lib.registerMenu({
        id = 'openVehicleShop',
        title = locale("px_vehicleshop_vehicle_categories"),
        position = Config.PositioMenu,
        options = options,
        onClose = function()
            CamOFF()
        end,
    }, function(selected, scrollIndex, args)
        local c = args.category
        if selected then
            OpenVehicleList(c, job)
        end
    end)
    lib.showMenu('openVehicleShop')
end

function OpenVehicleList(c, job)
    local options = {}
    local selectedCategory = c
    for _, v in pairs(Config.Vehicles) do
        if v.category == selectedCategory then
            options[#options + 1] = {
                label = string.upper(string.sub(v.label, 1, 1)) ..
                    string.sub(v.label, 2) .. " - " .. "Price: " .. v.price .. "$",
                args = { name = v.label, price = v.price },
                icon =
                    "nui://px_vehicleshop/img/cars/" .. v.label .. ".png",
                close = true
            }
        end
    end
    lib.registerMenu({
        id = 'openVehicleList',
        title = locale("px_vehicleshop_vehicle_list"),
        position = Config.PositioMenu,
        options = options,
        onClose = function()
            if lastSelectedVehicleEntity ~= nil then
                DeleteEntity(lastSelectedVehicleEntity)
                lastSelectedVehicleEntity = nil
            end
            lib.showMenu('openVehicleShop')
        end,
        onSelected = function(selected, secondary, args)
            if not buy and not inTestDrive then
                local vehicle = args.name
                spawnVehicle(vehicle)
            end
        end,
    }, function(selected, scrollIndex, args)
        local vehicle = args.name
        local price = args.price
        if selected then
            OpenVehicleInfo(vehicle, price, vehicleData, job)
        end
    end)
    lib.showMenu('openVehicleList')
end

function OpenVehicleInfo(vehicle, price, vehicleData, job)
    debug(job)
    local options = {
        { label = locale("px_vehicleshop_vehicle_info"), icon = "nui://px_vehicleshop/img/icon/info.png" },
        {label = locale("px_vehicleshop_test_drive"), icon = "nui://px_vehicleshop/img/icon/timer.png", close = false}
    }

    if Config.Shops.requiredJob == true and PlayerJob.name == Config.Shops.jobName and job ~= "showRoom" then
        options[#options + 1] = {
            label = locale("px_vehicleshop_buy_vehicle"), icon = "nui://px_vehicleshop/img/icon/money.png", args = { price = price }, close = false
        }
    elseif Config.Shops.requiredJob == false then
        options[#options + 1] = {
            label = locale("px_vehicleshop_buy_vehicle"), icon = "nui://px_vehicleshop/img/icon/money.png", args = { price = price }, close = false
        }
    end
    Wait(50)
    lib.registerMenu({
        id = 'openVehicleInfo',
        title = locale("px_vehicleshop_vehicle_info"),
        position = Config.PositioMenu,
        options = options,
        onClose = function()
            if lastSelectedVehicleEntity ~= nil then
                DeleteEntity(lastSelectedVehicleEntity)
                lastSelectedVehicleEntity = nil
            end
            lib.showMenu('openVehicleList')
        end,
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            ShowInfoVehicle(vehicleData)
        elseif selected == 2 then
            if Config.TestDrive then
                if job ~= "job" then
                    DoScreenFadeOut(650)
                    Wait(1000)
                    StartTestDrive(vehicle)
                end
            else
                lib.notify({
                    title = locale("px_vehicleshop_notify"),
                    description = locale("px_vehicleshop_notify_test_drive"),
                    type = 'error',
                    position = 'top',
                })
            end
        elseif selected == 3 then
            local price = args.price
            debug('Vehicle Price: ' .. price)
            if job == "job" then
                lib.callback('px_vehicleshop:getSocietyMoney', false, function(data)
                    debug(data)
                    if data then
                        buy = true
                        CamOFF()
                        lib.hideMenu('openVehicleInfo')
                        TriggerServerEvent('px_vehicleshopBuyVehicle', vehicle, price)
                    else
                        lib.notify({
                            title = locale("px_vehicleshop_notify"),
                            description = locale("px_vehicleshop_no_money"),
                            type = 'error',
                            position = 'top',
                        })
                    end
                end, price)
            else
                lib.callback('px_vehicleshop:getPlayerMoney', false, function(data)
                    if data then
                        buy = true
                        lib.hideMenu('openVehicleInfo')
                        local input = lib.inputDialog(locale("px_vehicleshop_select_color"), {
                            { type = 'color', label = locale("px_vehicleshop_select_color"), format = 'rgb', default = '#eb4034' }
                        })
                        if not input then
                            OpenVehicleInfo(vehicle, price, vehicleData)
                            return
                        end
                        color = input[1]
                        local r, g, b = string.match(color, "rgb%((%d+), (%d+), (%d+)%)")
                        r = tonumber(r)
                        g = tonumber(g)
                        b = tonumber(b)
                        if input then
                            CamOFF()
                            BuyVehicle(vehicle, r, g, b, price)
                        end
                    else
                        lib.notify({
                            title = locale("px_vehicleshop_notify"),
                            description = locale("px_vehicleshop_no_money"),
                            type = 'error',
                            position = 'top',
                        })
                    end
                end, price)
            end
        end
    end)
    lib.showMenu('openVehicleInfo')
end

function GetVehicleInfo()
    local vehicleData = {}
    vehicleData.traction = GetVehicleMaxTraction(lastSelectedVehicleEntity)
    vehicleData.breaking = GetVehicleMaxBraking(lastSelectedVehicleEntity)
    vehicleData.maxSpeed = GetVehicleEstimatedMaxSpeed(lastSelectedVehicleEntity)
    vehicleData.acceleration = GetVehicleAcceleration(lastSelectedVehicleEntity)
    return vehicleData
end

function StartTestDrive(vehicle)
    local lastCoordsPlayer = GetEntityCoords(cache.ped)
    inTestDrive = true
    lib.hideMenu('openVehicleInfo')
    CamOFF()
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
    -- local hash = GetHashKey(vehicle)

    local model = lib.requestModel(vehicle)

    if not model then return end

    local vehicleTestDrive = CreateVehicle(model, Config.TestDriveCoords, 100.0, 0, 1)
    debug('Creato')
    SetEntityCoords(cache.ped, Config.TestDriveCoords)
    debug('Tippato')
    SetPedIntoVehicle(cache.ped, vehicleTestDrive, -1)
    Wait(1000)
    DoScreenFadeIn(650)
    StartTimer()
    Citizen.CreateThread(function()
        while inTestDrive do
            Wait(5)
            if time > 0 then
                lib.showTextUI(locale("px_vehicleshop_textui_test_drive"):format(time), {
                    position = "top-center",
                    icon = 'fa-solid fa-stopwatch-20',
                    style = {
                        borderRadius = 5,
                        backgroundColor = '#282828',
                        color = 'white',
                    }
                })
            else
                inTestDrive = false
                local isOpen, text = lib.isTextUIOpen()
                if isOpen then
                    lib.hideTextUI()
                end
                DoScreenFadeOut(650)
                Wait(1000)
                DeleteVehicle(vehicleTestDrive)
                Wait(100)
                time = Config.TestDriveTime
                SetEntityCoords(cache.ped, lastCoordsPlayer)
                Wait(1000)
                DoScreenFadeIn(650)
            end
        end
    end)
end

function StartTimer()
    Citizen.CreateThread(function()
        while inTestDrive do
            if time > 0 then
                time = time - 1
            end
            debug("Time: " .. time)
            Wait(1000)
        end
    end)
end

function ShowInfoVehicle(vehicleData)
    debug(vehicleData)
    local info = GetVehicleInfo(vehicleData)
    debug(info)
    lib.registerMenu({
        id = 'showVehicleInfo',
        title = locale("px_vehicleshop_vehicle_info"),
        position = Config.PositioMenu,
        options = {
            { label = locale("px_vehicleshop_traction"),     progress = info.traction * 10,        icon = "nui://px_vehicleshop/img/icon/trasmission.png", close = false},
            { label = locale("px_vehicleshop_brakes"),       progress = info.breaking * 80,        icon = "nui://px_vehicleshop/img/icon/brakes.png", close = false},
            { label = locale("px_vehicleshop_maxspeed"),     progress = info.maxSpeed / 300 * 100, icon = "nui://px_vehicleshop/img/icon/speed.png", close = false},
            { label = locale("px_vehicleshop_acceleration"), progress = info.acceleration * 150,   icon = "nui://px_vehicleshop/img/icon/engine.png", close = false}
        },
        onClose = function()
            lib.showMenu('openVehicleInfo')
        end,
    }, function(selected, scrollIndex, args)
    end)
    lib.showMenu('showVehicleInfo')
end

function spawnVehicle(vehicle, job)
    local model = lib.requestModel(vehicle)

    if not model then return end


    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end

    if job == "job" then
        lastSelectedVehicleEntity = CreateVehicle(model, Config.Shops.spawnShowCase, true, 1)
    else
        lastSelectedVehicleEntity = CreateVehicle(model, Config.Shops.spawnShowCase, false, 1)
    end
    local heading = GetEntityHeading(lastSelectedVehicleEntity)
    Citizen.CreateThread(function()
        while inCam do
            Wait(0)
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 30, true) -- D
            if IsControlPressed(0, 9) then    -- Right
                heading = heading + 5
                SetEntityHeading(lastSelectedVehicleEntity, heading)
            elseif IsControlPressed(0, 63) then -- Left
                heading = heading - 5
                SetEntityHeading(lastSelectedVehicleEntity, heading)
            end
        end
    end)
end

function BuyVehicle(vehicle, r, g, b, price)
    local PlateGenerated = GeneratePlate()
    local name = vehicle
    QBCore.Functions.SpawnVehicle(vehicle, function(vehi)
        print('Vehicle: ', name)
        local veh = NetToVeh(netId)
        local newPlate = PlateGenerated
        ClearVehicleCustomPrimaryColour(vehi)
        SetVehicleCustomPrimaryColour(vehi, r, g, b)
        SetVehicleExtraColours(vehi, 0, 0)
        SetVehicleNumberPlateText(vehi, newPlate)
        SetEntityHeading(veh, 339.41)
        SetPedIntoVehicle(cache.ped, vehi, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
        TriggerServerEvent('px_vehicleshop:setVehicle', name, newPlate, "Pillbox Garage Parking", price)
        buy = false
    end, Config.Shops.spawnVehicleBuy, true)
end

function CamON(job)
    OpenVehicleShop(job)
    inCam = true
    Citizen.CreateThread(function()
        while inCam do
            Wait(1)
            InfoKeybind()
        end
    end)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(cache.ped, true)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(cam, Config.Shops.camCoords.x, Config.Shops.camCoords.y, Config.Shops.camCoords.z + 1.2)
        SetCamRot(cam, -10.0, 0.0, 230.0)
    else
        CamOFF()
        Wait(500)
        CamON()
    end
end

function CamOFF()
    FreezeEntityPosition(PlayerPedId(), false)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    inCam = false
end

--CarDealer Actions

Citizen.CreateThread(function()
    while true do
        local PlayerCoords = GetEntityCoords(cache.ped)
        local distance = #(Config.Shops.actionjob - PlayerCoords)
        if distance > 10.0 then
            sleep = 1500
        else
            sleep = 0
            if distance < 1.0 and not inCam and PlayerJob.name == Config.Shops.jobName and Config.Shops.requiredJob then
                exports['qb-core']:DrawText(locale('interact_marker'), 'left')
                DrawMarker(2, Config.Shops.actionjob.x, Config.Shops.actionjob.y, Config.Shops.actionjob.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if IsControlJustPressed(0, 38) then
                    OpenActionCardealer()
                end
            else
                exports['qb-core']:HideText()
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
            local closestPlayer, distance = QBCore.Functions.GetClosestPlayer(coords)
            if closestPlayer == -1 or distance > 3.0 then
                lib.notify({
                    title = locale("px_vehicleshop_notify"),
                    description = "No players nearby",
                    type = 'error',
                    position = 'top',
                })
            else
                local player = GetPlayerServerId(closestPlayer)
                print(player)
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
    print('Veicolo Venduto')
    print(player)
    local PlateGenerated = GeneratePlate()
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
    local PlateGenerated = GeneratePlate()
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        local newPlate = PlateGenerated
        SetVehicleNumberPlateText(veh, newPlate)
        SetEntityHeading(veh, 339.41)
        TriggerServerEvent('px_vehicleshop:SellVehicle', vehicle, newPlate, "Pillbox Garage Parking", player)
    end, vehicle, Config.Shops.spawnVehicleBuy, true)
    debug(vehicle)
    TriggerServerEvent('px_vehicleshop:deleteVehicle', vehicle)
end

--Boss Menu

Citizen.CreateThread(function()
    while true do
        local PlayerCoords = GetEntityCoords(cache.ped)
        local distance = #(Config.Shops.bossMenu - PlayerCoords)
        if distance > 10.0 then
            sleep = 1500
        else
            sleep = 0
            if distance < 1.0 and not inCam and PlayerJob.name == Config.Shops.jobName and PlayerJob.grade.name == Config.Shops.gradeBoss and Config.Shops.requiredJob then
                exports['qb-core']:DrawText(locale('interact_marker'), 'left')
                DrawMarker(2, Config.Shops.bossMenu.x, Config.Shops.bossMenu.y, Config.Shops.bossMenu.z, 0.0, 0.0, 0.0,
                    0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if IsControlJustPressed(0, 38) then
                    OpenBossMenu()
                end
            else
                exports['qb-core']:HideText()
            end
        end
        Wait(sleep)
    end
end)

function OpenBossMenu()
    TriggerServerEvent('qb-bossmenu:server:openMenu')
end