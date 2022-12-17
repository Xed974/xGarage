RegisterNetEvent("xGarage:getFourriere")
AddEventHandler("xGarage:getFourriere", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local car = {}

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE stored = 0", {}, function(result)
        if #result > 0 then
            for _,v in pairs(result) do
                if v.owner == xPlayer.getIdentifier() then 
                    table.insert(car, {owner = v.owner, job = v.job, plate = v.plate, vehicle = v.vehicle, stored = v.stored})
                elseif v.job == xPlayer.getJob().name then 
                    table.insert(car, {owner = v.owner, job = v.job, plate = v.plate, vehicle = v.vehicle, stored = v.stored})
                end
            end
            TriggerClientEvent("xGarage:receiveFourriere", xPlayer.source, car)
        end
    end)
end)

RegisterNetEvent("xGarage:setFourriere")
AddEventHandler("xGarage:setFourriere", function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 0 WHERE plate = @plate", { ["@plate"] = plate }, function(result)end)
end)

ESX.RegisterServerCallback("xGarage:payFourriere", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    if xPlayer.getMoney() >= Config.PriceFourriere then
        xPlayer.removeMoney(Config.PriceFourriere)
        TriggerClientEvent('esx:showNotification', source, '(~g~Succès~s~)\nFourrière payé.')
        cb(true)
    else
        cb(false)
    end
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM