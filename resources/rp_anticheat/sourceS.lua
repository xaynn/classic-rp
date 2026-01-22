-- local banPunishment = false

local punishmentCodes = {
["Event Spam"] = {code = "#01", description = "Event Spam"},
["Manipulate Event"] = {code = "#02", description = "Manipulate Event"},
["Weapon Spawner"] = {code = "#03", description = "Weapon Spawner"},
["Created Projectile"] = {code = "#04", description = "Created Projectile"},
["Manipulate Vehicle"] = {code = "#05", description = "Manipulate Vehicle"},
["Invalid Event"] = {code = "#06", description = "Invalid Event"},
["onExplosion"] = {code = "#07", description = "onExplosion"},
["Armor"] = {code = "#08", description = "onPlayerDamageArmor"},
["SpecialWorldProperty"] = {code = "#09", description = "onPlayerChangesWorldSpecialProperty"},
["ElementData"] = {code = "#10", description = "Changing Element Data"},
["SpoofBlacklist"] = {code = "#11", description = "Trying to spoof blacklist"},
}


-- setServerConfigSetting( "max_player_triggered_events_per_interval", "50", true )



function onPlayerTriggerInvalidEvent(eventName, isAdded, isRemote)
	local playerName = getPlayerName(source)
	local eventAdded = isAdded and "yes" or "no"
	local eventRemote = isRemote and "yes" or "no"
	local eventLogText = playerName.." triggered invalid event: "..eventName.." | event added: "..eventAdded.." | event remote: "..eventRemote.."."
	banPlayerAC(source,"Invalid Event", "onPlayerTriggerInvalidEvent: "..eventLogText)
end
addEventHandler("onPlayerTriggerInvalidEvent", root, onPlayerTriggerInvalidEvent)



function sendWebhook(info)
    local request, failReason = exports.rp_webhook:sendToURL(
        "linkdowebhooka",
        {
            title = "AntiCheat",
            description = info,
            timestamp = "now",
            color = 0xFF0000FF,
        }
    )
end


addEventHandler("onPlayerTeleport", root, function()
	local isLoggedPlayer = exports.rp_login:isLoggedPlayer(source)
	if not isLoggedPlayer then return end
	local admins = exports.rp_admin:getAdmins()
	for k,v in pairs(admins) do
		exports.rp_chat:sendChatOOC(k, "[FLYHACK] "..getPlayerName(source).." ("..exports.rp_utils:getPlayerRealName(source)..") [ ID: "..exports.rp_login:getPlayerData(source,"playerID").."] ", 255, 0, 0)
	end
end)

function processPlayerTriggerEventThreshold(event)
	banPlayerAC(source, "Event Spam", "onPlayerTriggerEventThreshold "..event)
end
addEventHandler("onPlayerTriggerEventThreshold", root, processPlayerTriggerEventThreshold)

function banPlayerAC(player, reason, location)
    local logged, accountID, playState = exports.rp_login:isLoggedPlayer(player)
    local playerName = getPlayerName(player)
    if logged then
        local timestamp = getRealTime().timestamp + 86400 * 999
        exports.rp_db:query("UPDATE users SET ban_reason = ?, ban_timestamp = ? WHERE id = ?", reason, timestamp, accountID)
		exports.rp_admin:renderPenalty(exports.rp_utils:getPlayerICName(player).." ("..getPlayerName(player)..")", "AntiCheat", reason, 3, "999d")
        -- banPlayer(player, true, false, true, "[AntiCheat]", "Malicious activity " .. punishmentCodes[reason].code)
		kickPlayer(player, "[AntiCheat]", "Malicious activity " .. punishmentCodes[reason].code)
    else
        banPlayer(player, true, false, true, "[AntiCheat]", "Malicious activity " .. punishmentCodes[reason].code)
    end
    sendWebhook(playerName .. " został zbanowany przez anticheat: Malicious activity " .. punishmentCodes[reason].code .. " [" .. punishmentCodes[reason].description .. "] [Event: " .. location .. "]")
end


function playerConnect(playerNick, playerIP, playerUsername, playerSerial)
    fetchRemote(
        "https://ipinfo.io/widget/demo/" .. playerIP,
        function(responseData, errno)
            if errno == 0 then
                -- Przetwarzanie odpowiedzi serwera (responseData)
                outputDebugString("Dane z API: " .. responseData)
                local data = fromJSON(responseData)
                local vpn = data["data"]["privacy"]["vpn"] == "true" or data["data"]["privacy"]["proxy"] == "true"
                if vpn then
                    cancelEvent(true, "Wyłącz VPN'a przed wejściem na serwer")
                end
            else
                outputDebugString("Błąd pobierania danych: " .. errno)
            end
        end
    )
end



-- addEventHandler("onPlayerConnect", root, playerConnect)
local cheats = {
    ["hovercars"] = true,
    ["aircars"] = true,
    ["extrabunny"] = true,
    ["extrajump"] = true
}

addEventHandler("onPlayerChangesWorldSpecialProperty", root,
    function(property, enabled)
        if not cheats[property] then
            return
        end

        if not enabled then
            return
        end

		banPlayerAC(source, "SpecialWorldProperty", "onPlayerChangesWorldSpecialProperty")
    end
)

-- function checkChange(theKey, oldValue)
	-- if getElementType(client) == "player" then
		-- iprint(theKey, oldValue)
		-- banPlayerAC(client, "ElementData", "onElementDataChange")
		-- if isElement(source) then setElementData(source, theKey, oldValue) end -- Set back the original value
	-- end
-- end
-- addEventHandler("onElementDataChange", root, checkChange)
function processPlayerElementDataHack()
    banPlayerAC(source, "ElementData", "onElementDataChange")
end
addEventHandler("onPlayerChangesProtectedData", root, processPlayerElementDataHack)
setServerConfigSetting("unoccupied_vehicle_syncer_distance", "0", true)
setServerConfigSetting("vehicle_contact_sync_radius", "0", true)
 
 
 for _,ban in ipairs(getBans())do
    if getBanSerial(ban) == "BB00B07575F429F2510EDD60F650A953" then
        removeBan(ban)
    end
end