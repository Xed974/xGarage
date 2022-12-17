CreateThread(function()
    while true do
        local wait = 1000
        for k in pairs(Config.Position.Garage) do
            local pos = Config.Position.Garage
            local pPos = GetEntityCoords(PlayerPedId())
            local dst = Vdist(pPos.x, pPos.y, pPos.z, pos[k].x, pos[k].y, pos[k].z)

            if dst <= Config.MarkerDistance then
                wait = 0
                DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)
            end
            if dst <= 2.0 then
                wait = 0
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour intéragir.")
                if IsControlJustPressed(1, 51) then
                    FreezeEntityPosition(PlayerPedId(), true)
                    openMenuGarage(pos[k])
                end
            end
        end
        for k in pairs(Config.Position.Fourriere) do
            local pos = Config.Position.Fourriere
            local pPos = GetEntityCoords(PlayerPedId())
            local dst = Vdist(pPos.x, pPos.y, pPos.z, pos[k].x, pos[k].y, pos[k].z)

            if dst <= Config.MarkerDistance then
                wait = 0
                DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)
            end
            if dst <= 2.0 then
                wait = 0
                ESX.ShowHelpNotification(("Appuyez sur ~INPUT_CONTEXT~ pour intéragir. (~g~%s$~s~)"):format(Config.PriceFourriere))
                if IsControlJustPressed(1, 51) then
                    FreezeEntityPosition(PlayerPedId(), true)
                    TriggerServerEvent("xGarage:getFourriere")
                    openMenuFourriere()
                end
            end
        end
        Wait(wait)
    end
end)

--- Xed#1188 | https://discord.gg/HvfAsbgVpM