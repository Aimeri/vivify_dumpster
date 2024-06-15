QBCore = exports['qb-core']:GetCoreObject()

local dumpsters = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_3a`,
    `prop_dumpster_4a`,
    `prop_dumpster_4b`,
    `prop_bin_02a`,
    `prop_bin_01a`
}

Citizen.CreateThread(function()
    for _, model in pairs(dumpsters) do
        exports['qb-target']:AddTargetModel(model, {
            options = {
                {
                    event = "vivify:client:openDumpster",
                    icon = "fas fa-dumpster",
                    label = "Open Dumpster",
                    num = 1
                },
                {
                    event = "vivify:client:searchDumpster",
                    icon = "fas fa-search",
                    label = "Search Dumpster",
                    num = 2
                }
            },
            distance = 2.5
        })
    end
end)

RegisterNetEvent('vivify:client:openDumpster', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestDumpster = nil
    local closestDistance = 2.5

    for _, model in pairs(dumpsters) do
        local dumpster = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, model, false, false, false)
        if dumpster ~= 0 then
            local dumpsterCoords = GetEntityCoords(dumpster)
            local distance = #(coords - dumpsterCoords)
            if distance < closestDistance then
                closestDistance = distance
                closestDumpster = dumpster
            end
        end
    end

    if closestDumpster then
        local dumpsterCoords = GetEntityCoords(closestDumpster)
        local dumpsterName = 'dumpster_' .. math.floor(dumpsterCoords.x) .. '_' .. math.floor(dumpsterCoords.y) .. '_' .. math.floor(dumpsterCoords.z)
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('vivify:server:openDumpsterInventory', dumpsterName)
            else
                QBCore.Functions.Notify("Failed to open Dumpster!", "error")
            end
        end, 2, 20)
        
    end
end)

RegisterNetEvent('vivify:client:searchDumpster', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestDumpster = nil
    local closestDistance = 2.5

    for _, model in pairs(dumpsters) do
        local dumpster = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, model, false, false, false)
        if dumpster ~= 0 then
            local dumpsterCoords = GetEntityCoords(dumpster)
            local distance = #(coords - dumpsterCoords)
            if distance < closestDistance then
                exports['ps-ui']:Circle(function(success)
                    if success then
                        closestDistance = distance
                        closestDumpster = dumpster
                    else
                        QBCore.Functions.Notify("Failed to search Dumpster!", "error")
                    end
                end, 2, 10)
            end
        end
    end

    if closestDumpster then
        QBCore.Functions.Progressbar("searching_dumpster", "Searching Dumpster...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            local dumpsterCoords = GetEntityCoords(closestDumpster)
            local dumpsterName = 'dumpster_' .. math.floor(dumpsterCoords.x) .. '_' .. math.floor(dumpsterCoords.y) .. '_' .. math.floor(dumpsterCoords.z)
            TriggerServerEvent('vivify:server:searchDumpster', dumpsterName)
        end, function()
            QBCore.Functions.Notify("Cancelled", "error")
        end)
    end
end)
