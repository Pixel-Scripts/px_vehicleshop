local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

lib.callback.register('px_vehicleshop:getPlayerMoney', function(source, price, scroll)
    local PaymentSystem
    if scroll == 1 then PaymentSystem = "money" else PaymentSystem = "bank" end
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerMoney = xPlayer.getAccount(PaymentSystem).money
    if tonumber(xPlayerMoney) >= tonumber(price) then
        xPlayer.removeAccountMoney(PaymentSystem, price)
        return PaymentSystem
    else
        return false
    end
end)

lib.callback.register('px_vehicleShop:getSocietyMoney', function(source, value)
    local money
    for k, v in pairs(Config.Shops) do
        if k == value then
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. v.jobName, function(account)
                money = account.money
            end)
        end
    end
    return money
end)

RegisterServerEvent('px_vehicleshop:setVehicle')
AddEventHandler('px_vehicleshop:setVehicle', function(vehicleProps, vehicleType, price)
    debug(source)
    debug(vehicleProps)
    debug(vehicleType)
    debug(price)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Sync.execute(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
        {
            ['@owner']   = xPlayer.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@stored']  = 1,
            ['type']     = vehicleType
        }, function()
        end)
end)

RegisterServerEvent('px_vehicleshopBuyVehicle')
AddEventHandler('px_vehicleshopBuyVehicle', function(vehicle, price, action, r, g, b)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json")
    if loadFile ~= nil then
        if Config.RemoveMoneyCompany then
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. action, function(account)
                account.removeMoney(price)
            end)
        end
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            debug(extract)
            table.insert(extract, { name = vehicle, price = price, job = action, r = r, g = g, b = b })
            SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json", json.encode(extract, { indent = true }), -1)
        else
            local Table = {}
            table.insert(Table, { name = vehicle, price = price, job = action, r = r, g = g, b = b })
            SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json", json.encode(Table, { indent = true }), -1)
        end
    end
end)

RegisterServerEvent('px_vehicleshop:SellVehicle')
AddEventHandler('px_vehicleshop:SellVehicle', function(vehicleProps, vehicleType, price, player)
    debug(vehicleProps)
    debug(vehicleType)
    local _source = player
    local xPlayer = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
        type = 'success',
        title = locale("px_notify_sell") .. vehicleProps.plate,
        position = 'top',
        description = '',
        5000
    })
    MySQL.Sync.execute(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
        {
            ['@owner']   = xPlayer.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@stored']  = 1,
            ['type']     = vehicleType
        }, function()
        end)
end)

RegisterServerEvent("px_vehicleshop:returnVehicle", function(vehicle, price, k, action)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json ")
    if loadFile ~= nil then
        local returnPrice = price * 50 / 100
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            for _, v in ipairs(extract) do
                if v.name == vehicle then
                    if v.job == action then
                        debug(v.coords)
                        debug(k)
                        table.remove(extract, k)
                        SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json",
                            json.encode(extract, { indent = true }), -1)
                        Wait(100)
                        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. action, function(account)
                            account.addMoney(returnPrice)
                        end)
                    end
                end
            end
        end
    end
end)
