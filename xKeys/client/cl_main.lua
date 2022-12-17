ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand("doorCar", function()
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local closecar = nil

    if IsPedInAnyVehicle(PlayerPedId(),  false) then closecar = GetVehiclePedIsIn(PlayerPedId(), false) else closecar = GetClosestVehicle(x, y, z, 4.0, 0, 71) end
    ESX.TriggerServerCallback("xKeys:getKeys", function(result)
        if result then
			if GetVehicleDoorLockStatus(closecar) == 1 or GetVehicleDoorLockStatus(closecar) == 0 then -- if unlocked
				SetVehicleDoorsLocked(closecar, 2)
				PlayVehicleDoorCloseSound(closecar, 1)
                ESX.ShowNotification("(~g~Succès~s~)\nVous avez verouillé votre véhicule.")
			elseif GetVehicleDoorLockStatus(closecar) == 2 then -- if locked
				SetVehicleDoorsLocked(closecar, 1)
				PlayVehicleDoorOpenSound(closecar, 0)
                ESX.ShowNotification("(~g~Succès~s~)\nVous avez déverouillé votre véhicule.")
			end
        else
            ESX.ShowNotification("(~r~Erreur~s~)\nVous avez pas les clés de ce véhicule.")
        end
    end, GetVehicleNumberPlateText(closecar))
    
end)
RegisterKeyMapping("doorCar", "Touche pour ouvrir/fermer vos véhicules", "keyboard", "U")

--- Xed#1188 | https://discord.gg/HvfAsbgVpM