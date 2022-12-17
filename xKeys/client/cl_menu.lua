ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local keys = {}
local function getKeys()
    ESX.TriggerServerCallback("xKeys:getCarKeys", function(result) 
        keys = result
    end)
end

local select, stats = {}, {}
local open, key = false, false
local mainMenu = RageUI.CreateMenu("Clé(s)", "Vos véhicules", nil, nil, "root_cause5", "img_orange")
local option = RageUI.CreateSubMenu(mainMenu, "Clé(s)", "Interaction")
mainMenu.Display.Header = true
mainMenu.Closed = function() open = false end option.Closed = function() select = {} key = false end

local function MenuKeys()
    if open then
        open = false
        RageUI.Visible(mainMenu, false)
    else
        open = true
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while open do
                Wait(0)
                RageUI.IsVisible(mainMenu, function()
                    if #keys > 0 then
                        for _,v in pairs(keys) do
                            RageUI.Button(("~o~→~s~ %s"):format(v.model), nil, {RightLabel = ("~o~%s~s~"):format(v.plate)}, true, {
                                onSelected = function()
                                    ESX.TriggerServerCallback("xKeys:getStored", function(result) stats = result end, v.plate)
                                    table.insert(select, {model = v.model, plate = v.plate, other_users = v.other_users})
                                end
                            }, option)
                        end
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Vous n'avez pas de clé.")
                        RageUI.Separator("")
                    end
                end)
                RageUI.IsVisible(option, function()
                    local player, distance = ESX.Game.GetClosestPlayer()
                    for _,v in pairs(select) do
                        RageUI.Separator(("Model: ~o~%s"):format(v.model))
                        RageUI.Separator(("Plaque: ~o~%s"):format(v.plate))
                        RageUI.Line()
                        RageUI.Button("Attribuer/Désattribuer à son job", nil, {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("xKeys:attributJob", v.plate, v.job)
                            end
                        })
                        RageUI.Button("Etat du véhicule", nil, {RightLabel = "→"}, true, {
                            onActive = function()
                                for a,b in pairs(stats) do
                                    if b.stored == 0 then
                                        RageUI.Info("Localisation", {"Etat:"}, {"~r~Fourrière"})
                                    elseif b.stored == 1 then
                                        RageUI.Info("Localisation", {"Etat"}, {"~r~Garage"})
                                    elseif b.stored == 2 then
                                        RageUI.Info("Localisation", {"Etat"}, {"~r~Sortie"})
                                    end
                                end
                            end,
                            onSelected = function()
                                ESX.ShowNotification("(~g~Succès~s~)\nVéhicule mis en fourrière dans 10 minutes.")
                                Wait(xKeys.TimeFourriere * 60000)
                                TriggerServerEvent("xGarage:setFourriere", v.plate)
                            end
                        })
                        RageUI.Button("Donner le double des clés", nil, {RightLabel = "→"}, true, {
                            onActive = function()
                                DrawMarker(0, GetEntityCoords(GetPlayerPed(player)).x, GetEntityCoords(GetPlayerPed(player)).y, GetEntityCoords(GetPlayerPed(player)).z + 1.1, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.2, 0.2, 0.2, xKeys.MarkerColorR, xKeys.MarkerColorG, xKeys.MarkerColorB, xKeys.MarkerOpacite, xKeys.MarkerSaute, true, p19, xKeys.MarkerTourne)
                            end,
                            onSelected = function()
                                if player ~= -1 and distance <= 2.0 then
                                    TriggerServerEvent("xKeys:addKeysForOtherUsers", GetPlayerServerId(player), v.plate)
                                    RageUI.CloseAll()
                                    open = false
                                    select = {}
                                else
                                    ESX.ShowNotification("(~r~Erreur~s~)\nAucun joueur à proximité.")
                                end
                            end
                        })
                        RageUI.Button("Donner les clés", nil, {RightLabel = "→"}, true, {
                            onActive = function()
                                DrawMarker(0, GetEntityCoords(GetPlayerPed(player)).x, GetEntityCoords(GetPlayerPed(player)).y, GetEntityCoords(GetPlayerPed(player)).z + 1.1, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.2, 0.2, 0.2, xKeys.MarkerColorR, xKeys.MarkerColorG, xKeys.MarkerColorB, xKeys.MarkerOpacite, xKeys.MarkerSaute, true, p19, xKeys.MarkerTourne)
                            end,
                            onSelected = function()
                                if player ~= -1 and distance <= 2.0 then
                                    TriggerServerEvent("xKeys:changeOwner", GetPlayerServerId(player), v.plate)
                                    RageUI.CloseAll()
                                    open = false
                                    select = {}
                                else
                                    ESX.ShowNotification("(~r~Erreur~s~)\nAucun joueur à proximité.")
                                end
                            end
                        })
                        RageUI.Checkbox("Voir les personnes ayant les clés", nil, key, {}, {
                            onChecked = function()
                                key = true
                            end,
                            onUnChecked = function()
                                key = false
                            end
                        })
                        if key then
                            local data = json.decode(select[1].other_users)
                            for a,b in pairs(data) do
                                RageUI.Button(("~o~→~s~ %s"):format(b.name), nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, {
                                    onSelected = function()
                                        TriggerServerEvent("xKeys:removeKeysForOtherUsers", b.identifier, v.plate)
                                        RageUI.CloseAll()
                                        open = false
                                        select = {}
                                    end
                                })
                            end
                        end
                    end
                end)
            end
        end)
    end
end

RegisterCommand("menuKeys", function()
    getKeys()
    MenuKeys()
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM