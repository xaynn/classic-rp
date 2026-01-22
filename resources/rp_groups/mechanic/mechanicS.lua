function calculateVehicleRepairCost(vehicle)
    local damageCost = {
        [0] = 0,    -- Brak uszkodzeń
        [1] = 50,   -- Lekkie uszkodzenia
        [2] = 100,  -- Średnie uszkodzenia
        [3] = 200   -- Ciężkie uszkodzenia
    }
    
    local hpCostPerUnit = 2
    
    local totalCost = 0
    local damagedPanels = 0
    local maxDamageLevel = 0
    local missingHP = 0
    local currentHP = 0

    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end

    for panel = 0, 6 do
        local state = getVehiclePanelState(vehicle, panel)
        if state then
            maxDamageLevel = math.max(maxDamageLevel, state)
            totalCost = totalCost + (damageCost[state] or 0)
            damagedPanels = damagedPanels + (state > 0 and 1 or 0)
        end
    end

    currentHP = math.max(getElementHealth(vehicle), 350)
    missingHP = 1000 - currentHP
    totalCost = totalCost + (missingHP * hpCostPerUnit)

    return {
        totalCost = math.floor(totalCost),
        damagedPanels = damagedPanels,
        maxDamage = maxDamageLevel,
        vehicleHP = currentHP,
        missingHP = missingHP,
        hpRepairCost = missingHP * hpCostPerUnit
    }
end


-- local repairData = calculateVehicleRepairCost(vehicle)
-- if repairData then
    -- outputChatBox(string.format([[
        -- Koszt całkowity: $%d
        -- - Uszkodzenia karoserii: $%d (%d paneli)
        -- - Naprawa podwozia: $%d (brakuje %d HP)
        -- Aktualne HP: %d/1000
    -- ]], 
    -- repairData.totalCost,
    -- repairData.totalCost - repairData.hpRepairCost,
    -- repairData.damagedPanels,
    -- repairData.hpRepairCost,
    -- repairData.missingHP,
    -- repairData.vehicleHP))
-- end