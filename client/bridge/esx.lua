local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    CreateBossMenuMarker()
    CreateMarkerCardealerAction()
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
    CreateBossMenuMarker()
    CreateMarkerCardealerAction()
end)

AddEventHandler('onResourceStart', function(resourceName)
    CreateBossMenuMarker()
    CreateMarkerCardealerAction()
end)

local lastSelectedVehicleEntity = nil
local vehicleTestDrive = nil
local valueAction = nil
local time = Config.TestDriveTime
local inTestDrive = false
local buy = false

Citizen.CreateThread(function()
    for k, v in pairs(Config.Shops) do
        lib.points.new({
            coords   = v.showcase,
            distance = Config.MarkerDistance,
            onEnter  = function(self)
                lib.showTextUI(locale("px_textUiShowRoom"), {
                    position = "right-center",
                    icon = 'hand',
                })
            end,
            onExit   = function(self)
                lib.hideTextUI()
            end,
            nearby   = function(self)
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0,
                    0.0, 0.0,
                    180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if IsControlJustReleased(0, 38) then
                    valueAction = k
                    print(valueAction)
                    lib.hideTextUI()
                    CamON('showRoom')
                end
            end,
        })
    end
end)

function OpenVehicleShop(job)
    local options = {}
    for k, v in pairs(Config.Categories) do
        if k == valueAction then
            for _, l in pairs(v) do
                options[#options + 1] = {
                    label = l.label,
                    action = function()
                        OpenVehicleList(l.name, job)
                    end
                }
            end
        end
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
        local option = options[selected]
        if option then
            if option.action then
                option.action()
            end
        end
    end)
    lib.showMenu('openVehicleShop')
end

function OpenVehicleList(c, job)
    local options = {}
    local selectedCategory = c
    for _, v in pairs(Config.Vehicles) do
        if v.category == selectedCategory then
            if v.dealership == valueAction then
                options[#options + 1] = {
                    label = string.upper(string.sub(v.name, 1, 1)) ..
                        string.sub(v.name, 2) .. " - " .. "Price: " .. v.price .. "$",
                    args = { name = v.model, price = v.price },
                    icon = "car",
                    close = true
                }
            end
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
        {
            label = locale("px_vehicleshop_vehicle_info"),
            icon = "nui://px_vehicleshop/img/icon/info.png",
            close = true,
            action = function()
                ShowInfoVehicle(vehicle)
            end
        }
    }

    if Config.TestDrive then
        if job ~= "cardealer" then
            options[#options + 1] = {
                label = locale("px_vehicleshop_test_drive"),
                icon = "nui://px_vehicleshop/img/icon/timer.png",
                close = true,
                action = function()
                    DoScreenFadeOut(650)
                    Wait(1000)
                    StartTestDrive(vehicle)
                end
            }
        end
    end

    for k, v in pairs(Config.Shops) do
        if k == valueAction then
            if v.requiredJob == false or (v.requiredJob == true and ESX.PlayerData.job.name == v.jobName and job == "cardealer") then
                options[#options + 1] = {
                    label = locale("px_vehicleshop_buy_vehicle"),
                    icon = "nui://px_vehicleshop/img/icon/money.png",
                    close = true,
                    action = function()
                        debug('Vehicle Price: ' .. price)
                        if job == "cardealer" then
                            debug(job)
                            lib.callback("px_vehicleShop:getSocietyMoney", false, function(data)
                                debug(data)
                                if data then
                                    buy = true
                                    CamOFF()
                                    lib.hideMenu('openVehicleInfo')
                                    if lastSelectedVehicleEntity ~= nil then
                                        DeleteEntity(lastSelectedVehicleEntity)
                                        lastSelectedVehicleEntity = nil
                                    end
                                    local input = lib.inputDialog(locale("px_vehicleshop_select_color"), {
                                        { type = 'color', label = locale("px_vehicleshop_select_color"), format = 'rgb', default = '#eb4034' }
                                    })
                                    if not input then
                                        buy = false
                                        CamOFF()
                                        return
                                    end
                                    color = input[1]
                                    local r, g, b = string.match(color, "rgb%((%d+), (%d+), (%d+)%)")
                                    r = tonumber(r)
                                    g = tonumber(g)
                                    b = tonumber(b)
                                    TriggerServerEvent('px_vehicleshopBuyVehicle', vehicle, price, valueAction, r, g,
                                        b)
                                    buy = false
                                else
                                    lib.notify({
                                        title = locale("px_vehicleshop_notify"),
                                        description = locale("px_vehicleshop_no_money"),
                                        type = 'error',
                                        position = 'top',
                                    })
                                end
                            end, valueAction)
                        else
                            SelectPaymentSystem(vehicle, price)
                        end
                    end
                }
            end
        end
    end
    Wait(50)
    lib.registerMenu({
        id = 'openVehicleInfo',
        title = locale("px_vehicleshop_vehicle_info"),
        position = Config.PositioMenu,
        options = options,
        onClose = function()
            if not buy then
                lib.showMenu('openVehicleList')
            end
        end,
    }, function(selected, scrollIndex, args)
        local option = options[selected]
        if option then
            if option.action then
                option.action()
            end
        end
    end)
    lib.showMenu('openVehicleInfo')
end

function SelectPaymentSystem(vehicle, price)
    lib.registerMenu({
        id = 'SelectPaymentSystem',
        title = locale("px_payVehicle"),
        position = Config.PositioMenu,
        options = {
            {
                label = locale("px_selectPayamentSystem"),
                icon = "fa-solid fa-wallet",
                values = { locale("px_money"), locale("px_bank") },
            }
        },
        onClose = function()
            if not buy then
                OpenVehicleInfo(vehicle, price, vehicleData)
            end
        end,
    }, function(selected, scrollIndex, args)
        local data = lib.callback.await('px_vehicleshop:getPlayerMoney', false, price, scrollIndex)
        if data then
            buy = true
            lib.hideMenu('SelectPaymentSystem')
            local input = lib.inputDialog(locale("px_vehicleshop_select_color"), {
                { type = 'color', label = locale("px_vehicleshop_select_color"), format = 'rgb', default = '#eb4034' }
            })
            if not input then
                buy = false
                SelectPaymentSystem(vehicle, price)
                return
            end
            color = input[1]
            local r, g, b = string.match(color, "rgb%((%d+), (%d+), (%d+)%)")
            r = tonumber(r)
            g = tonumber(g)
            b = tonumber(b)
            if input then
                CamOFF()
                if lastSelectedVehicleEntity ~= nil then
                    DeleteEntity(lastSelectedVehicleEntity)
                    lastSelectedVehicleEntity = nil
                end
                Wait(100)
                BuyVehicle(vehicle, r, g, b, price)
            end
        else
            SelectPaymentSystem(vehicle, price)
            lib.notify({
                title = locale("px_vehicleshop_notify"),
                description = locale("px_vehicleshop_no_money"),
                type = 'error',
                position = 'top',
            })
        end
    end)
    lib.showMenu('SelectPaymentSystem')
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
    CamOFF()
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end

    local model = lib.requestModel(vehicle)

    if not model then return end

    for k,v in pairs(Config.Shops) do
        if k == valueAction then
            vehicleTestDrive = CreateVehicle(model, v.TestDriveCoords, 100.0, 0, 1)
            debug('Created')
            SetVehicleNumberPlateText(vehicleTestDrive, "TEST")
            SetEntityCoords(cache.ped, v.TestDriveCoords)
            debug('Tippato')
            SetPedIntoVehicle(cache.ped, vehicleTestDrive, -1)
            Wait(1000)
            DoScreenFadeIn(650)
            StartTimer()
        end
    end
    Citizen.CreateThread(function()
        while inTestDrive do
            Wait(5)
            if time > 0 then
                DisableControlAction(0, 75, true)
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
                ESX.Game.DeleteVehicle(vehicleTestDrive)
                Wait(100)
                time = Config.TestDriveTime
                vehicleTestDrive = nil
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

function ShowInfoVehicle()
    debug(vehicleData)
    local info = GetVehicleInfo()
    debug(info)
    lib.registerMenu({
        id = 'showVehicleInfo',
        title = locale("px_vehicleshop_vehicle_info"),
        position = Config.PositioMenu,
        options = {
            { label = locale("px_vehicleshop_traction"),     progress = info.traction * 10,        icon = "nui://px_vehicleshop/img/icon/trasmission.png", close = false },
            { label = locale("px_vehicleshop_brakes"),       progress = info.breaking * 80,        icon = "nui://px_vehicleshop/img/icon/brakes.png",      close = false },
            { label = locale("px_vehicleshop_maxspeed"),     progress = info.maxSpeed / 300 * 100, icon = "nui://px_vehicleshop/img/icon/speed.png",       close = false },
            { label = locale("px_vehicleshop_acceleration"), progress = info.acceleration * 150,   icon = "nui://px_vehicleshop/img/icon/engine.png",      close = false }
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

    for k, v in pairs(Config.Shops) do
        if k == valueAction then
            lastSelectedVehicleEntity = CreateVehicle(model, v.spawnShowCase.x, v.spawnShowCase.y, v.spawnShowCase.z,
                v.spawnShowCase.w,
                false, 1)
            DisableVehicleWorldCollision(lastSelectedVehicleEntity)
            FreezeEntityPosition(lastSelectedVehicleEntity, true)
        end
    end
    local heading = GetEntityHeading(lastSelectedVehicleEntity)
    Citizen.CreateThread(function()
        while inCam do
            Wait(0)
            if IsControlPressed(0, 9) then -- Right
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
    for k, v in pairs(Config.Shops) do
        if k == valueAction then
            ESX.Game.SpawnVehicle(vehicle, v.spawnVehicleBuy, 339.41, function(vehicle)
                local newPlate     = PlateGenerated
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                vehicleProps.plate = newPlate
                ClearVehicleCustomPrimaryColour(vehicle)
                SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                SetVehicleExtraColours(vehicle, 0, 0)
                SetVehicleNumberPlateText(vehicle, PlateGenerated)
                SetPedIntoVehicle(cache.ped, vehicle, -1)
                TriggerServerEvent('px_vehicleshop:setVehicle', vehicleProps, "car", price)
                buy = false
            end)
        end
    end
end

function CamON(job)
    OpenVehicleShop(job)
    inCam = true
    Citizen.CreateThread(function()
        while inCam do
            Wait(1)
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 30, true) -- D
            InfoKeybind()
        end
    end)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 250, 1, 0)
        for k, v in pairs(Config.Shops) do
            if k == valueAction then
                SetCamCoord(cam, v.camCoords.x, v.camCoords.y, v.camCoords.z + 1.2)
                PointCamAtCoord(cam, v.spawnShowCase.x, v.spawnShowCase.y, v.spawnShowCase.z)
                return
            end
        end
    else
        CamOFF()
        Wait(500)
        CamON()
    end
end

function CamOFF()
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    inCam = false
end

--CarDealer Actions

function CreateMarkerCardealerAction()
    for k, v in pairs(Config.Shops) do
        if v.requiredJob and not inCam and ESX.PlayerData.job.name == v.jobName then
            lib.points.new({
                coords   = v.actionjob,
                distance = Config.MarkerDistance,
                onEnter  = function(self)
                    lib.showTextUI(locale("px_textUiCardealer"), {
                        position = "right-center",
                        icon = 'hand',
                    })
                end,
                onExit   = function(self)
                    lib.hideTextUI()
                end,
                nearby   = function(self)
                    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0,
                        0.0, 0.0,
                        180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                    if IsControlJustReleased(0, 38) then
                        valueAction = k
                        lib.hideTextUI()
                        OpenActionCardealer()
                    end
                end,
            })
        end
    end
end

function OpenActionCardealer()
    local options = {
        {
            label = locale("cardealer_buy_vehicle"),
            icon = "nui://px_vehicleshop/img/icon/money.png",
            action = function()
                CamON("cardealer")
            end
        },
        {
            label = locale("cardealer_vehicle_purschased"),
            icon = "nui://px_vehicleshop/img/icon/garage.png",
            action = function()
                OpenVehicleSaved()
            end
        },
    }

    Wait(100)
    lib.registerMenu({
        id = 'openActionCardealer',
        title = locale("cardealer_action_cardealer"),
        position = Config.PositioMenu,
        options = options,
    }, function(selected, scrollIndex, args)
        local option = options[selected]
        if option then
            if option.action then
                option.action()
            end
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
                if v.job == valueAction then
                    options[#options + 1] = {
                        label = string.upper(string.sub(v.name, 1, 1)) ..
                            string.sub(v.name, 2),
                        args = { vehicle = v.name, price = v.price, k = k, red = v.r, green = v.g, blue = v.b }
                    }
                end
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
                OpenActionVehicleSaved(args.vehicle, args.price, args.k, args.red, args.green, args.blue)
            end
        end)
        lib.showMenu('openVehicleSaved')
    else
        lib.notify({
            title = locale("px_vehicleshop_notify"),
            description = locale("px_notify_noVehicle"),
            type = 'error',
            position = 'top',
        })
    end
end

function OpenActionVehicleSaved(vehicle, price, k, red, green, blue)
    local options = {
        {
            label = locale("cardealer_action_vechile_saved_show"),
            close = false,
            action = function()
                spawnVehicle(vehicle, "cardealer")
            end
        },
        {
            label = locale("cardealer_action_vechile_saved_sell"),
            close = true,
            action = function()
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
                    SellVehicle(vehicle, player, red, green, blue)
                end
            end
        },
        {
            label = locale("cardealer_action_vechile_saved_return"),
            close = true,
            action = function()
                local alert = lib.alertDialog({
                    header = locale("cardealer_alert_return_vehicle_header"),
                    content = locale("cardealer_alert_return_vehicle_content"),
                    centered = true,
                    cancel = true
                })
                if alert == "confirm" then
                    TriggerServerEvent('px_vehicleshop:returnVehicle', vehicle, price, k, valueAction)
                    if lastSelectedVehicleEntity ~= nil then
                        DeleteEntity(lastSelectedVehicleEntity)
                    end
                else
                    return
                end
            end
        }
    }
    lib.registerMenu({
        id = 'openVehicleActionSaved',
        title = locale("cardealer_vehicle_saved"),
        position = Config.PositioMenu,
        options = options,
        onClose = function()
            lib.showMenu('openVehicleSaved')
            if lastSelectedVehicleEntity ~= nil then
                DeleteEntity(lastSelectedVehicleEntity)
            end
        end
    }, function(selected, scrollIndex, args)
        local option = options[selected]
        if option then
            if option.action then
                option.action()
            end
        end
    end)
    lib.showMenu('openVehicleActionSaved')
end

function SellVehicle(vehicle, player, red, green, blue)
    local PlateGenerated = GeneratePlate()
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
    for k, v in pairs(Config.Shops) do
        if k == valueAction then
            ESX.Game.SpawnVehicle(vehicle, v.spawnVehicleBuy, 339.41, function(vehicle)
                local newPlate     = PlateGenerated
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                vehicleProps.plate = newPlate
                SetVehicleNumberPlateText(vehicle, PlateGenerated)
                ClearVehicleCustomPrimaryColour(vehicle)
                SetVehicleCustomPrimaryColour(vehicle, red, green, blue)
                TriggerServerEvent('px_vehicleshop:SellVehicle', vehicleProps, "car", price,
                    player)
            end)
            debug(vehicle)
            TriggerServerEvent('px_vehicleshop:deleteVehicle', vehicle)
        end
    end
end

--Boss Menu

function CreateBossMenuMarker()
    for k, v in pairs(Config.Shops) do
        if v.requiredJob and not inCam and ESX.PlayerData.job.name == v.jobName then
            lib.points.new({
                coords   = v.bossMenu,
                distance = Config.MarkerDistance,
                onEnter  = function(self)
                    lib.showTextUI(locale("px_textUiBossMenu"), {
                        position = "right-center",
                        icon = 'hand',
                    })
                end,
                onExit   = function(self)
                    lib.hideTextUI()
                end,
                nearby   = function(self)
                    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0,
                        0.0, 0.0,
                        180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                    if not inCam and ESX.PlayerData.job.name == v.jobName and ESX.PlayerData.job.grade_name == v.gradeBoss and v.requiredJob then
                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()
                            OpenBossMenu(v .. jobName)
                        end
                    end
                end,
            })
        end
    end
end

--PlayerJob.grade.name

function OpenBossMenu(k)
    TriggerEvent('esx_society:openBossMenu', k, function(data, menu)
        menu.close()
    end, { wash = false })
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    local menu = lib.getOpenMenu()
    if menu ~= nil then
        lib.hideMenu(menu)
    end
    FreezeEntityPosition(cache.ped, false)
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
end)
