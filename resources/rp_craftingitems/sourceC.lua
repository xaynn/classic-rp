local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs

local startX, startY = sx/2 - 150 * scaleValue, sy/2 - 100 * scaleValue
local size = 100
local padding = 10
local slots = {}
local playerItems = {}
local slotData = {}

local function openCraftMenu(items)
    for _, element in ipairs(slots) do
        if isElement(element) then
            destroyElement(element)
        end
    end
    slots = {}
    slotData = {}

    for _, element in ipairs(playerItems) do
        if isElement(element) then
            destroyElement(element)
        end
    end
    playerItems = {}

    for row = 0, 2 do
        for col = 0, 2 do
            local x = startX + (size + padding) * col
            local y = startY + (size + padding) * row
            local slot = DGS:dgsCreateButton(x, y, size, size, "", false)
            table.insert(slots, slot)

            local index = row * 3 + col + 1
            slotData[slot] = nil

            addEventHandler("onDgsDrag", slot, function()
                local sData = slotData[slot]
                if sData then
                    DGS:dgsSendDragNDropData({itemID = sData.itemID, itemType = sData.itemType})
                end
            end, false)

            addEventHandler("onDgsDrop", slot, function(data)
                if type(data) == "table" and data.itemID and data.itemType then
                    for otherSlot, sData in pairs(slotData) do
                        if sData and sData.itemID == data.itemID then
                            DGS:dgsSetProperty(otherSlot, "text", "")
                            slotData[otherSlot] = nil
                            break
                        end
                    end

                    DGS:dgsSetProperty(slot, "text", data.itemType)
                    slotData[slot] = data

                    for i, itemButton in ipairs(playerItems) do
                        if DGS:dgsGetProperty(itemButton, "text") == data.itemType then
                            destroyElement(itemButton)
                            table.remove(playerItems, i)
                            break
                        end
                    end
                end
            end, false)
        end
    end

    local leftPanelX = startX - size - 5 * padding
    local leftPanelY = startY
    local panelWidth = size + 20 * scaleValue
    local panelHeight = (size + padding) * 4

    local leftPanel = DGS:dgsCreateScrollPane(leftPanelX, leftPanelY, panelWidth, panelHeight, false)

    local index = 0
    for id, v in pairs(items) do
        local itemY = (size + padding) * index
        local itemButton = DGS:dgsCreateButton(0, itemY, size, size, v.name, false, leftPanel)
        table.insert(playerItems, itemButton)

        addEventHandler("onDgsDrag", itemButton, function()
            DGS:dgsSendDragNDropData({itemID = id, itemType = v.name})
        end, false)

        index = index + 1
    end

    local trashX = startX + (size + padding) * 4
    local trashY = startY
    local trash = DGS:dgsCreateButton(trashX, trashY, size, size, "Trash", false)

    addEventHandler("onDgsDrop", trash, function(data)
        if type(data) == "table" and data.itemID and data.itemType then
            for _, slot in ipairs(slots) do
                local sData = slotData[slot]
                if sData and sData.itemID == data.itemID then
                    DGS:dgsSetProperty(slot, "text", "")
                    slotData[slot] = nil

                    local itemY = (size + padding) * #playerItems
                    local itemButton = DGS:dgsCreateButton(0, itemY, size, size, data.itemType, false, leftPanel)
                    table.insert(playerItems, itemButton)

                    addEventHandler("onDgsDrag", itemButton, function()
                        DGS:dgsSendDragNDropData({itemID = data.itemID, name = data.name, itemType = data.itemType})
                    end, false)

                    break
                end
            end
        end
    end, false)
end

addEvent("onPlayerOpenCraftingMenu", true)
addEventHandler("onPlayerOpenCraftingMenu", getRootElement(), openCraftMenu)
