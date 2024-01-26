lib.callback.register('px_vehicleshop:getPlayerMoney', function(source, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.PaymentSystem == "bank" then
        local xPlayerBankMoney = xPlayer.getAccount('bank').money
        if tonumber(xPlayerBankMoney) >= tonumber(price) then
            return true
        else
            return false
        end
    else
        local xPlayerMoney = xPlayer.getMoney()
        if tonumber(xPlayerMoney) >= tonumber(price) then
            return true
        else
            return false
        end
    end
end)

lib.callback.register('px_vehicleshop:getSocietyMoney', function(source, price)
    local hasMoney
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account)
        debug(account.money)
        debug(price)
        if account.money >= price then
            account.removeMoney(tonumber(price))
            hasMoney = true
        else
            hasMoney = false
        end
    end)
    if hasMoney then
        return true
    else
        return false
    end
end)

RegisterServerEvent('px_vehicleshop:setVehicle')
AddEventHandler('px_vehicleshop:setVehicle', function (vehicleProps, vehicleType, price)
    debug(source)
    debug(vehicleProps)
    debug(vehicleType)
    debug(price)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    if Config.PaymentSystem == "bank" then
        xPlayer.removeAccountMoney("bank", tonumber(price))
    else
        xPlayer.removeAccountMoney("money", tonumber(price))
    end
    MySQL.Sync.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
    {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored']  = 1,
        ['type'] = vehicleType
    }, function ()
    end)
end)

RegisterServerEvent('px_vehicleshop:SellVehicle')
AddEventHandler('px_vehicleshop:SellVehicle', function (vehicleProps, vehicleType, price, player)
    debug(vehicleProps)
    debug(vehicleType)
    local _source = player
	local xPlayer = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
        type = 'success',
        title = "The vehicle with the license plate "..vehicleProps.plate.." and now your property",
        position = 'top',
        description = '',
        5000
    })
    MySQL.Sync.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
    {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored']  = 1,
        ['type'] = vehicleType
    }, function ()
    end)
end)

RegisterServerEvent('px_vehicleshopBuyVehicle')
AddEventHandler('px_vehicleshopBuyVehicle', function (vehicle, price)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            debug(extract)
            table.insert(extract, {name = vehicle, price = price})
            SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json",  json.encode(extract, { indent = true }), -1)
        else
            local Table = {}
            table.insert(Table, {name = vehicle, price = price})
            SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json",  json.encode(Table, { indent = true }), -1)
        end
    end
end)

RegisterServerEvent('px_vehicleshop:returnVehicle')
AddEventHandler('px_vehicleshop:returnVehicle', function (vehicle, price)
    local returnPrice = price * 50 / 100
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account)
        account.addMoney(returnPrice)
    end)
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

RegisterServerEvent('px_vehicleshop:deleteVehicle')
AddEventHandler('px_vehicleshop:deleteVehicle', function (vehicle, price)
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

lib.callback.register('px_vehicleShop:getAllVehicle', function(source)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json")
    if loadFile then
        local extract = json.decode(loadFile)
        if not extract[1] then
            return false
        else
            return extract
        end
    end
end)