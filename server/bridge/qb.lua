QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

lib.callback.register('px_vehicleshop:getPlayerMoney', function(source, price)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    debug(xPlayer)
    local xPlayerMoney = xPlayer.PlayerData.money[Config.PaymentSystem]
    debug(xPlayerMoney)
    if tonumber(xPlayerMoney) >= tonumber(price) then return true else return false end
end)

RegisterServerEvent('px_vehicleshop:setVehicle')
AddEventHandler('px_vehicleshop:setVehicle', function (vehicle, plate, garage, price)
    debug(source)
    debug(vehicle)
    debug(plate)
    debug(garage)
    debug(price)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    xPlayer.Functions.RemoveMoney(Config.PaymentSystem, price, 'vehicle-bought-in-showroom')
    local cid = xPlayer.PlayerData.citizenid
    debug(xPlayer.PlayerData.license)
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        xPlayer.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        1,
        garage
    })
end)

RegisterServerEvent('px_vehicleshop:SellVehicle')
AddEventHandler('px_vehicleshop:SellVehicle', function (vehicle, plate, garage, player)
    debug(vehicle)
    debug(plate)
    debug(garage)
    debug(player)
    local _source = player
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    TriggerClientEvent('ox_lib:notify', _source, {
        type = 'success',
        title = "The vehicle with the license plate "..plate.." and now your property",
        position = 'top',
        description = '',
        5000
    })
    local cid = xPlayer.PlayerData.citizenid
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        xPlayer.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        1,
        garage
    })
    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', player, plate)
end)

--BossMenu
RegisterServerEvent('px_vehicleshop:returnVehicle')
AddEventHandler('px_vehicleshop:returnVehicle', function (vehicle, price)
    local returnPrice = price * 50 / 100
    exports['qb-banking']:AddMoney(Config.Shops.jobName, returnPrice)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json ")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            for k,v in ipairs(extract) do
                if v.name == vehicle then
                    debug(v.coords)
                    debug(k)
                    table.remove(extract, k)
                    SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json",  json.encode(extract, { indent = true }), -1)
                end
            end
        end
    end
end)

lib.callback.register('px_vehicleshop:getSocietyMoney', function(source, price)
    local hasMoney
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local job = Player.PlayerData.job.name
    debug(job)
    local society = exports['qb-banking']:GetAccountBalance(job)
    if society >= price then
        exports['qb-banking']:RemoveMoney(job, price)
        hasMoney = true
    else
        hasMoney = false
    end

    if hasMoney then
        return true
    else
        return false
    end
end)