RegisterNetEvent("xGarage:setStats")
AddEventHandler("xGarage:setStats", function(plate, stored, properties)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if (not xPlayer) then return end
    MySQL.Async.fetchAll("UPDATE owned_vehicles SET stored = @stored, vehicle = @vehicle WHERE plate = @plate", { ["@stored"] = stored, ["@vehicle"] = json.encode(properties), ["@plate"] = plate }, function()end)
end)

ESX.RegisterServerCallback("xGarage:getVehicles", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local car = {}

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE stored = 1", {}, function(result)
        if (result) then
            for _,v in pairs(result) do
                if v.owner == xPlayer.getIdentifier() then
                    table.insert(car, {owner = v.owner, job = v.job, plate = v.plate, vehicle = v.vehicle, stored = v.stored, pos = v.lieu})
                elseif v.job == xPlayer.getJob().name then 
                    table.insert(car, {owner = v.owner, job = v.job, plate = v.plate, vehicle = v.vehicle, stored = v.stored, pos = v.lieu})
                end
            end
            cb(car)
        end
    end)
end)

ESX.RegisterServerCallback("xGarage:stockCar", function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", { ["@plate"] = plate }, function(result)
        if #result > 0 then
            for _,v in pairs(result) do
                if v.owner == xPlayer.getIdentifier() then 
                    cb(true) 
                elseif v.job == xPlayer.getJob().name then 
                    cb(true)
                else
                    cb(false)
                end
            end
        else
            cb(false)
        end
    end)
end)

-- SavePos = true

RegisterNetEvent("xGarage:setStats_SavePos")
AddEventHandler("xGarage:setStats_SavePos", function(plate, stored, properties, pos)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if (not xPlayer) then return end
    MySQL.Async.fetchAll("UPDATE owned_vehicles SET stored = @stored, vehicle = @vehicle, lieu = @lieu WHERE plate = @plate", { ["@stored"] = stored, ["@vehicle"] = json.encode(properties), ["@plate"] = plate, ["@lieu"] = json.encode(pos) }, function()end)
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM