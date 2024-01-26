RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

lastSelectedVehicleEntity = nil
local time = Config.TestDriveTime
local inTestDrive = false
local buy = false

Citizen.CreateThread(function()
    local pxBlip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(pxBlip, Config.Blip.id)
    SetBlipDisplay(pxBlip, 4)
    SetBlipScale(pxBlip, Config.Blip.scale)
    SetBlipColour(pxBlip, Config.Blip.color)
    SetBlipAsShortRange(pxBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.title)
    EndTextCommandSetBlipName(pxBlip)
end)

Citizen.CreateThread(function()
    while true do
        local PlayerCoords = GetEntityCoords(cache.ped)
        local distance = #(Config.Shops.showcase - PlayerCoords)
        if distance > 10.0 then
            sleep = 500
        else
            sleep = 0
            if distance < 1.0 and not inCam then
                ESX.ShowHelpNotification(locale('interact_marker'))
                if IsControlJustPressed(0, 38) then
                    CamON('showRoom')
                end
            end
        end
        DrawMarker(2, Config.Shops.showcase.x, Config.Shops.showcase.y, Config.Shops.showcase.z, 0.0, 0.0, 0.0, 0.0,
            180.0, 0.0, 0.5, 0.5, 0.5, 255, 128, 0, 50, false, true, 2, nil, nil, false)
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

    if Config.Shops.requiredJob == true and ESX.PlayerData.job.name == Config.Shops.jobName and job ~= "showRoom" then
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
    local hash = GetHashKey(vehicle)

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(10)
        end
    end
    local vehicleTestDrive = CreateVehicle(hash, Config.TestDriveCoords, 100.0, 0, 1)
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
                ESX.Game.DeleteVehicle(vehicleTestDrive)
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

function ShowInfoVehicle()
    debug(vehicleData)
    local info = GetVehicleInfo()
    debug(info)
    lib.registerMenu({
        id = 'showVehicleInfo',
        title = locale("px_vehicleshop_vehicle_info"),
        position = Config.PositioMenu,
        options = {
            { label = locale("px_vehicleshop_traction"),     progress = info.traction * 10,        icon = "nui://px_vehicleshop/img/icon/trasmission.png" },
            { label = locale("px_vehicleshop_brakes"),       progress = info.breaking * 80,        icon = "nui://px_vehicleshop/img/icon/brakes.png" },
            { label = locale("px_vehicleshop_maxspeed"),     progress = info.maxSpeed / 300 * 100, icon = "nui://px_vehicleshop/img/icon/speed.png" },
            { label = locale("px_vehicleshop_acceleration"), progress = info.acceleration * 150,   icon = "nui://px_vehicleshop/img/icon/engine.png" }
        },
        onClose = function()
            lib.showMenu('openVehicleInfo')
        end,
    }, function(selected, scrollIndex, args)
    end)
    lib.showMenu('showVehicleInfo')
end

function spawnVehicle(vehicle, job)
    local hash = GetHashKey(vehicle)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
    end

    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end

    if job == "job" then
        lastSelectedVehicleEntity = CreateVehicle(hash, Config.Shops.spawnShowCase, true, 1)
    else
        lastSelectedVehicleEntity = CreateVehicle(hash, Config.Shops.spawnShowCase, false, 1)
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
    ESX.Game.SpawnVehicle(vehicle, Config.Shops.spawnVehicleBuy, 339.41, function(vehicle)
        local newPlate     = PlateGenerated
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate
        ClearVehicleCustomPrimaryColour(vehicle)
        SetVehicleCustomPrimaryColour(vehicle, r, g, b)
        SetVehicleExtraColours(vehicle, 0, 0)
        SetVehicleNumberPlateText(vehicle, PlateGenerated)
        SetPedIntoVehicle(cache.ped, vehicle, -1)

        TriggerServerEvent('px_vehicleshop:setVehicle', vehicleProps, "car", price)
    end)
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
