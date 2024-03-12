RegisterServerEvent('px_vehicleshop:deleteVehicle')
AddEventHandler('px_vehicleshop:deleteVehicle', function(vehicle, price)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json ")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            for k, v in ipairs(extract) do
                if v.name == vehicle then
                    debug(v.coords)
                    debug(k)
                    table.remove(extract, k)
                    SaveResourceFile(GetCurrentResourceName(), "vehicleSaved.json",
                        json.encode(extract, { indent = true }), -1)
                end
            end
        end
    end
end)

RegisterServerEvent("px_vehicleshop:returnVehicle", function(vehicle, price, k, action)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicleSaved.json ")
    if loadFile ~= nil then
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
                            account.addMoney(price)
                        end)
                    end
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
