local animationList = {} -- UPDATE POSITION TYLKO DLA ANIMACJI CHODZACYCH
local animations = {}
function animations.loadAnimCommands()
    local how = 0
    for i, v in ipairs(animationList) do
        if v.customAnim == true then
            addCommandHandler(
                "/" .. v.commandName,
                function(player, cmd)
					if exports.rp_login:getPlayerData(player,"hasPackage") then return end
                    animations.customAnimApplyDefault(player, v.commandName, v.updatePosition)
                end
            )
        else
            addCommandHandler(
                "/" .. v.commandName,
                function(player, cmd)
					if exports.rp_login:getPlayerData(player,"hasPackage") then return end
                    animations.applyDefault(player, v.block, v.anim, v.loop, v.updatePosition, v.commandName)
					
                end
            )
        end

        how = how + 1
    end
    outputDebugString("Załadowano " .. how .. " animacji.")
    --iprint(animationList)
end



function animations.onStart() -- xml i tak jak da sie false to zamienia na string, trzeba zimenic
   local how = 1
   local file = xmlLoadFile("files/animlist.xml")
   if file then
      local xmlNodes = xmlNodeGetChildren( file )
      for i,v in ipairs(xmlNodes) do
         local name = xmlNodeGetAttribute( v, "commandName" )
         local block = xmlNodeGetAttribute( v, "block" )
         local anim = xmlNodeGetAttribute( v, "anim" )
         local loop = xmlNodeGetAttribute( v, "isLoop" )
         local category = xmlNodeGetAttribute( v, "category" )
         local id = xmlNodeGetAttribute( v, "id" )
         local updatePosition = xmlNodeGetAttribute( v, "updatePosition" )
         local customAnim = xmlNodeGetAttribute( v, "customAnim" )
         if loop == "false" then loop = false else loop = true end
         if updatePosition == "false" then updatePosition = false else updatePosition = true end
         if customAnim == "false" then customAnim = false else customAnim = true end
         table.insert(animationList, {commandName = name, block = block, anim = anim, loop = loop, category = category, updatePosition = updatePosition, customAnim = customAnim, id = id})
      end
   end
   xmlUnloadFile(file)
   animations.loadAnimCommands()
end

addEventHandler( "onResourceStart", resourceRoot, animations.onStart )


function animations.apply(block, name, loop, updatePosition, commandName) -- event
    if exports.rp_bw:hasPlayerBW(client) then return end

    toggleAllControls(client, true, true, false)
    toggleControl(client, "fire", false)
    setPedAnimation(client, block, name, -1, loop, updatePosition, false)

    if exports.rp_login:getPlayerData(client, "animation->custom") then
        exports.rp_login:setPlayerData(client, "animation->custom", false)
    end

    local _, _, rz = getElementRotation(client)
    exports.rp_login:setPlayerData(client, "animation->default", {commandName, rz, true})

    triggerClientEvent(client, "animations->EnableRender", client, true, updatePosition)
end
addEvent("animations->applyAnim", true)
addEventHandler("animations->applyAnim", getRootElement(), animations.apply)
function animations.applyDefault(player, block, name, loop, updatePosition, commandName) -- event
    if exports.rp_bw:hasPlayerBW(player) then return end

    toggleAllControls(player, true, true, false)
    toggleControl(player, "fire", false)
    setPedAnimation(player, block, name, -1, loop, updatePosition, false)

    if exports.rp_login:getPlayerData(player, "animation->custom") then
        exports.rp_login:setPlayerData(player, "animation->custom", false)
    end

    local _, _, rz = getElementRotation(player)
    exports.rp_login:setPlayerData(player, "animation->default", {commandName, rz, true})

    triggerClientEvent(player, "animations->EnableRender", player, true, updatePosition)
end



function animations.customAnimApplyDefault(player, commandName, updatePosition)
    if exports.rp_bw:hasPlayerBW(player) then return end

    toggleControl(player, "fire", false)
    toggleAllControls(player, true, true, false)

    local _, _, rz = getElementRotation(player)

    if exports.rp_login:getPlayerData(player, "animation->custom") then
        exports.rp_login:setPlayerData(player, "animation->custom", false)
    end

    exports.rp_login:setPlayerData(player, "animation->custom", {commandName, rz, true})
    triggerClientEvent(player, "animations->EnableRender", player, true, updatePosition)
end

function animations.customAnimApply(commandName, updatePosition)
    if exports.rp_bw:hasPlayerBW(client) then return end
	if exports.rp_login:getPlayerData(client,"hasPackage") then return end

    toggleControl(client, "fire", false)
    toggleAllControls(client, true, true, false)

    local _, _, rz = getElementRotation(client)

    if exports.rp_login:getPlayerData(client, "animation->custom") then
        exports.rp_login:setPlayerData(client, "animation->custom", false)
    end

    exports.rp_login:setPlayerData(client, "animation->custom", {commandName, rz, true})
    triggerClientEvent(client, "animations->EnableRender", client, true, updatePosition)
end
addEvent("animations->customAnimApply", true)
addEventHandler("animations->customAnimApply", getRootElement(), animations.customAnimApply)


function animations.applyData(data, type)
	if exports.rp_login:getPlayerData(client,"hasPackage") then return end
	local dataxd = exports.rp_login:getPlayerData(client, "animation->custom") or exports.rp_login:getPlayerData(client, "animation->default")
	if not dataxd then return end
	if not next(data) then return end
	local tmpTable = data
	if type == 1 then
		exports.rp_login:setPlayerData(client, "animation->default", tmpTable)
	elseif type == 2 then
		exports.rp_login:setPlayerData(client, "animation->custom", tmpTable)
	end
end
addEvent("onPlayerCorrectPosAnimation", true)
addEventHandler("onPlayerCorrectPosAnimation", getRootElement(), animations.applyData)


function animations.stopAnim()
    setPedAnimation(client)
    toggleAllControls(client, true, true, false)

    if not isPedInVehicle(client) then
        setElementCollisionsEnabled(client, true)
    end

    if exports.rp_login:getPlayerData(client, "animation->custom") then
        exports.rp_login:setPlayerData(client, "animation->custom", false)
    end

    if exports.rp_login:getPlayerData(client, "animation->default") then
        exports.rp_login:setPlayerData(client, "animation->default", false)
    end
end
addEvent("animations->stopAnim", true)
addEventHandler("animations->stopAnim", getRootElement(), animations.stopAnim)


function animations.disableCollisions()
    setElementCollisionsEnabled(client, false)

    local animData = exports.rp_login:getPlayerData(client, "animation->default")
    if animData then
        exports.rp_login:setPlayerData(client, "animation->default", {animData[1], animData[2], false})
    end

    local customData = exports.rp_login:getPlayerData(client, "animation->custom")
    if customData then
        exports.rp_login:setPlayerData(client, "animation->custom", {customData[1], customData[2], false})
    end
end
addEvent("animations->disableCollision", true)
addEventHandler("animations->disableCollision", getRootElement(), animations.disableCollisions)


function animations.animCommand(player)
    local logged = exports.rp_login:isLoggedPlayer(player)
    if not logged then
        return
    end
    triggerClientEvent(player, "animations->showGui", player, true)
end
addCommandHandler("anim", animations.animCommand, false, false)


function playerJoinedAnim()
    bindKey(source, "insert", "down", animations.animCommand)
end
addEventHandler("onPlayerJoin", root, playerJoinedAnim)


function wastedAnim(ammo, attacker, weapon, bodypart)
    setPedAnimation(source)

    if not isPedInVehicle(source) then
        setElementCollisionsEnabled(source, true)
    end

    if exports.rp_login:getPlayerData(source, "animation->custom") then
        exports.rp_login:setPlayerData(source, "animation->custom", false)
    end

    if exports.rp_login:getPlayerData(source, "animation->default") then
        exports.rp_login:setPlayerData(source, "animation->default", false)
    end

    triggerClientEvent(source, "animations->Dead", source)
end
addEventHandler("onPlayerWasted", root, wastedAnim)


