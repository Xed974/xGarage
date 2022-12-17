local vehicles = {}
local function getVehicles() vehicles = {} ESX.TriggerServerCallback("xGarage:getVehicles", function(result) vehicles = result end) end

local open = false
local mainMenu = RageUI.CreateMenu("Garage", "Interaction", nil, nil, "root_cause5", "img_red")
local show_car = RageUI.CreateSubMenu(mainMenu, "Garage", "Interaction")
mainMenu.Display.Header = true
mainMenu.Closed = function() open = false FreezeEntityPosition(PlayerPedId(), false) end

function openMenuGarage(pos)
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
                    if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
                        RageUI.Button("Ranger votre véhicule", nil, {RightLabel = "→→"}, false, {})
                    else
                        RageUI.Button("Ranger votre véhicule", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                if not Config.SavePos then
                                    ESX.TriggerServerCallback("xGarage:stockCar", function(can)
                                        if can then
                                            TriggerServerEvent("xGarage:setStats", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), 1, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)))
                                            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            RageUI.CloseAll()
                                            open = false
                                        else
                                            ESX.ShowNotification("(~r~Erreur~s~)\nVous ne pouvez pas ranger ce véhicule.")
                                        end
                                    end, GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
                                else
                                    ESX.TriggerServerCallback("xGarage:stockCar", function(can)
                                        if can then
                                            TriggerServerEvent("xGarage:setStats_SavePos", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), 1, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)), pos)
                                            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            RageUI.CloseAll()
                                            open = false
                                        else
                                            ESX.ShowNotification("(~r~Erreur~s~)\nVous ne pouvez pas ranger ce véhicule.")
                                        end
                                    end, GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
                                end
                            end
                        })
                    end
                    RageUI.Line()
                    RageUI.Button("Liste véhicules", nil, {RightBadge = RageUI.BadgeStyle.Star}, true, { onSelected = function() getVehicles() end }, show_car)
                end)
                RageUI.IsVisible(show_car, function()
                    if #vehicles > 0 then
                        for _,v in pairs(vehicles) do
                            if not Config.SavePos then
                                RageUI.Button(("~r~→~s~ %s [~r~%s~s~]"):format(GetDisplayNameFromVehicleModel(json.decode(v.vehicle).model), v.plate), nil, {RightBadge = RageUI.BadgeStyle.Car}, true, {
                                    onSelected = function()
                                        if not ESX.Game.IsSpawnPointClear(GetEntityCoords(PlayerPedId()), 1) then ESX.ShowNotification("(~r~Erreur~s~)\nEspace insuffisant pour sortir votre véhicule.") end
                                        if not IsModelInCdimage(json.decode(v.vehicle).model) then return end
                                            RequestModel(json.decode(v.vehicle).model)
                                        while not HasModelLoaded(json.decode(v.vehicle).model) do
                                        Citizen.Wait(10)
                                        end
                                        local car = CreateVehicle(json.decode(v.vehicle).model, GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, GetEntityHeading(PlayerPedId()), true, false)
                                        ESX.Game.SetVehicleProperties(car, v.vehicle)
                                        SetVehicleNumberPlateText(car, v.plate)
                                        SetPedIntoVehicle(PlayerPedId(), car, -1)
                                        TriggerServerEvent("xGarage:setStats", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), 2, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)))
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        RageUI.CloseAll()
                                        open = false
                                    end
                                })
                            else
                                RageUI.Button(("~r~→~s~ %s [~r~%s~s~]"):format(GetDisplayNameFromVehicleModel(json.decode(v.vehicle).model), v.plate), nil, {RightLabel = ("~r~%s~s~"):format(GetNameOfZone(json.decode(v.pos.x), json.decode(v.pos.y), json.decode(v.pos.z)))}, true, {
                                    onSelected = function()
                                        if v.pos == json.encode(pos) then
                                            if not ESX.Game.IsSpawnPointClear(GetEntityCoords(PlayerPedId()), 1) then ESX.ShowNotification("(~r~Erreur~s~)\nEspace insuffisant pour sortir votre véhicule.") end
                                            if not IsModelInCdimage(json.decode(v.vehicle).model) then return end
                                                RequestModel(json.decode(v.vehicle).model)
                                            while not HasModelLoaded(json.decode(v.vehicle).model) do
                                            Citizen.Wait(10)
                                            end
                                            local car = CreateVehicle(json.decode(v.vehicle).model, GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, GetEntityHeading(PlayerPedId()), true, false)
                                            ESX.Game.SetVehicleProperties(car, v.vehicle)
                                            SetVehicleNumberPlateText(car, v.plate)
                                            SetPedIntoVehicle(PlayerPedId(), car, -1)
                                            TriggerServerEvent("xGarage:setStats_SavePos", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), 1, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)), pos)
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            RageUI.CloseAll()
                                            open = false
                                        else
                                            ESX.ShowNotification("(~r~Erreur~s~)\nVous n'êtes pas au bon garage.")
                                        end
                                    end
                                })
                            end
                        end
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Aucun véhicule dans le garage.~s~")
                        RageUI.Separator("")
                    end
                end)
            end
        end)
    end
end

--- Xed#1188 | https://discord.gg/HvfAsbgVpM