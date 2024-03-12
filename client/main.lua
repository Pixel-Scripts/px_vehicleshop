Citizen.CreateThread(function()
    for k, v in pairs(Config.Shops) do
        local pxBlip = AddBlipForCoord(v.coords)
        SetBlipSprite(pxBlip, v.id)
        SetBlipDisplay(pxBlip, 4)
        SetBlipScale(pxBlip, v.scale)
        SetBlipColour(pxBlip, v.color)
        SetBlipAsShortRange(pxBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.title)
        EndTextCommandSetBlipName(pxBlip)
    end
end)
