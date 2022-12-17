ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("xKeys:getKeys", function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT identifier, other_users FROM xkeys WHERE plate = @plate", {
        ["@plate"] = plate
    }, function(result)
        for _,v in pairs(result) do
            if v.identifier == xPlayer.getIdentifier() then cb(true) end
            local data = json.decode(result[1].other_users)
            for a,b in pairs(data) do
                if b.identifier == xPlayer.getIdentifier() then
                    cb(true)
                end
            end
        end
    end)
end)

RegisterNetEvent("xKeys:addKeys")
AddEventHandler("xKeys:addKeys", function(plate, model)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.execute("INSERT INTO xkeys (identifier, plate, model) VALUES (@identifier, @plate, @model)", {
        ["@identifier"] = xPlayer.getIdentifier(),
        ["@plate"] = plate,
        ["@model"] = model
    }, function(result)
        if result ~= nil then
            TriggerClientEvent('esx:showNotification', xPlayer.source, ('(~g~Succès~s~)\nVous avez reçu les clés du véhicule ~r~%s~s~.'):format(plate))
        end
    end)
end)

RegisterNetEvent("xKeys:addKeysForTarget")
AddEventHandler("xKeys:addKeysForTarget", function(target, plate, model)
    local source = target
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.execute("INSERT INTO xkeys (identifier, plate, model) VALUES (@identifier, @plate, @model)", {
        ["@identifier"] = xPlayer.getIdentifier(),
        ["@plate"] = plate,
        ["@model"] = model
    }, function(result)
        if result ~= nil then
            TriggerClientEvent('esx:showNotification', source, ('(~g~Succès~s~)\nVous avez reçu les clés du véhicule ~r~%s~s~.'):format(plate))
        end
    end)
end)

RegisterNetEvent("xKeys:addKeysForOtherUsers")
AddEventHandler("xKeys:addKeysForOtherUsers", function(target, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end if (not tPlayer) then return end
    MySQL.Async.fetchAll("SELECT other_users FROM xkeys WHERE plate = @plate", {
        ["@plate"] = plate
    }, function(result)
        for _,v in pairs(result) do
            local data = json.decode(result[1].other_users)
            table.insert(data, {identifier = tPlayer.getIdentifier(), name = tPlayer.getName()})
            MySQL.Async.execute("UPDATE xkeys SET other_users = @other_users WHERE plate = @plate", {
                ["@other_users"] = json.encode(data),
                ["@plate"] = plate
            }, function(result2)
                if result2 ~= nil then
                    TriggerClientEvent('esx:showNotification', target, ('(~y~Information~s~)\nVous avez reçu le double des clés du véhicule ~r~%s~s~.'):format(plate))
                    TriggerClientEvent('esx:showNotification', xPlayer.source, ('(~g~Succès~s~)\nVous avez donné le double des clés du véhicule ~r~%s~s~ à ~r~%s~s~.'):format(plate, tPlayer.getName()))
                end
            end)
        end
    end)
end)

RegisterNetEvent("xKeys:removeKeysForOtherUsers")
AddEventHandler("xKeys:removeKeysForOtherUsers", function(identifier, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT other_users FROM xkeys WHERE plate = @plate", {
        ["@plate"] = plate
    }, function(result)
        for _,v in pairs(result) do
            local data = json.decode(result[1].other_users)
            for k, j in pairs(data) do
                if j.identifier == identifier then
                    table.remove(data, k)
                    MySQL.Async.execute("UPDATE xkeys SET other_users = @other_users WHERE plate = @plate", {
                        ["@other_users"] = json.encode(data),
                        ["@plate"] = plate
                    }, function(result2)
                        if result2 ~= nil then
                            TriggerClientEvent('esx:showNotification', xPlayer.source, ('(~g~Succès~s~)\nVous avez repris le double des clés du véhicule ~r~%s~s~.'):format(plate))
                        end
                    end)
                end
            end
        end
    end)
end)

RegisterNetEvent("xKeys:changeOwner")
AddEventHandler("xKeys:changeOwner", function(target, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    if (not xPlayer) then return end if (not tPlayer) then return end
    MySQL.Async.execute("UPDATE xkeys SET identifier = @identifier, other_users = @other_users WHERE plate = @plate", {
        ["@identifier"] = tPlayer.getIdentifier(),
        ["@other_users"] = json.encode({}),
        ["@plate"] = plate
    }, function(result)
        if result ~= nil then TriggerClientEvent('esx:showNotification', xPlayer.source, ('(~g~Succès~s~)\nVous avez donné les clés du véhicule ~r~%s~s~.'):format(plate)) end
    end)
end)

ESX.RegisterServerCallback("xKeys:getCarKeys", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT plate, model, other_users FROM xkeys WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.getIdentifier()
    }, function(result) if result ~= nil then cb(result) end end)
end)

RegisterNetEvent("xKeys:attributJob")
AddEventHandler("xKeys:attributJob", function(plate, job)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    if job == nil then
        MySQL.Async.execute("UPDATE owned_vehicles SET job = @job WHERE plate = @plate", { ["@job"] = xPlayer.getJob().name, ["@plate"] = plate }, function()end)
        MySQL.Async.execute("UPDATE xkeys SET job = @job WHERE plate = @plate", { ["@job"] = xPlayer.getJob().name, ["@plate"] = plate }, function(result) TriggerClientEvent('esx:showNotification', xPlayer.source, '(~g~Succès~s~)\nVéhicule attribué au job.') end)
    else
        MySQL.Async.execute("UPDATE owned_vehicles SET job = @job WHERE plate = @plate", { ["@job"] = nil, ["@plate"] = plate }, function()end)
        MySQL.Async.execute("UPDATE xkeys SET job = @job WHERE plate = @plate", { ["@job"] = nil, ["@plate"] = plate }, function(result) TriggerClientEvent('esx:showNotification', xPlayer.source, '(~g~Succès~s~)\nVéhicule désattribuer du job.') end)
    end
end)

ESX.RegisterServerCallback("xKeys:getStored", function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    MySQL.Async.fetchAll("SELECT stored FROM owned_vehicles WHERE plate = @plate", { ["@plate"] = plate }, function(result) cb(result) end)
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM