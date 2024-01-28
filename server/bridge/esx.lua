local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

lib.callback.register('px_vehicleshop:getPlayerMoney', function(source, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xPlayerBankMoney = xPlayer.getAccount(Config.PaymentSystem).money
    if tonumber(xPlayerBankMoney) >= tonumber(price) then return true else return false end
end)

RegisterServerEvent('px_vehicleshop:setVehicle')
AddEventHandler('px_vehicleshop:setVehicle', function (vehicleProps, vehicleType, price)
    debug(source)
    debug(vehicleProps)
    debug(vehicleType)
    debug(price)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeAccountMoney(Config.PaymentSystem, tonumber(price))
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

lib.callback.register('px_vehicleShop:getSocietyMoney', function(source)
    local money
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account) 
        money = account.money
    end)
    return money
end)
