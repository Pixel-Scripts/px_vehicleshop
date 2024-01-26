lib.callback.register('px_vehicleShop:getSocietyMoney', function(source)
    local money
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account) 
        money = account.money
    end)
    return money
end)

RegisterNetEvent('px_vehicleShop:ActionBossMenu')
AddEventHandler('px_vehicleShop:ActionBossMenu', function(value, action, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if action == "withdraw" then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account)
            account.removeMoney(tonumber(value))
        end)
    elseif action == "deposit" then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..Config.Shops.jobName, function(account)
            account.addMoney(tonumber(value))
        end)
    end
end)

lib.callback.register('px_vehicleShop:getSocietyEmployees', function(source)
    local employees = {}
    local results = MySQL.query.await('SELECT `identifier`, `firstname`, `lastname`, `job`, `job_grade` FROM `users` WHERE `job` = ?', {
        Config.Shops.jobName
    })
    for i=1, #results, 1 do
        table.insert(employees, {
            identifier = results[i].identifier,
            firstname = results[i].firstname,
            lastname = results[i].lastname,
            grade = results[i].job_grade,
        })
    end
    return employees
end)

lib.callback.register('px_vehicleShop:getAllSocietyRank', function(source)
    local rank = MySQL.prepare.await('SELECT `label`, `grade` FROM `job_grades` WHERE `job_name` = ?', {
        Config.Shops.jobName
    })
    return rank
end)