QBCore = exports['qb-core']:GetCoreObject()

local function getRandomLoot()
    local loot = {}
    local possibleLoot = Config.Loot
    while #loot < Config.ItemCount do
        local item = possibleLoot[math.random(#possibleLoot)]
        if not table.contains(loot, item) then
            table.insert(loot, item)
        end
    end
    return loot
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local dumpsterCooldowns = {}

RegisterNetEvent('vivify:server:openDumpsterInventory', function(dumpsterName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        exports['qb-inventory']:OpenInventory(src, dumpsterName, {
            maxweight = 1000000,
            slots = 50,
        })
    end
end)

RegisterNetEvent('vivify:server:searchDumpster', function(dumpsterName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local currentTime = os.time()

    if dumpsterCooldowns[dumpsterName] and (currentTime - dumpsterCooldowns[dumpsterName]) < Config.Cooldown then
        local timeLeft = Config.Cooldown - (currentTime - dumpsterCooldowns[dumpsterName])
        TriggerClientEvent('QBCore:Notify', src, "You cannot search this dumpster yet. Try again in " .. timeLeft .. " seconds.", "error")
    else
        dumpsterCooldowns[dumpsterName] = currentTime
        if Player then
            local loot = getRandomLoot()
            for _, item in pairs(loot) do
                local quantity = math.random(Config.ItemQuantity.min, Config.ItemQuantity.max)
                Player.Functions.AddItem(item, quantity)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", quantity)
            end
            TriggerClientEvent('QBCore:Notify', src, "You found some items in the dumpster.", "success")
        end
    end
end)