local function openCraftingMenu(player)
	local items = exports.rp_inventory:getPlayerItems(player)
	triggerClientEvent(player,"onPlayerOpenCraftingMenu", player, items)
end
addCommandHandler("craft", openCraftingMenu, false, false)

