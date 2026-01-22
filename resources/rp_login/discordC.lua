local app_id = "11111111111"
local nameData
-- function setDiscordRichPresence(name)
    -- if setDiscordApplicationID(app_id) then
        -- setDiscordRichPresenceState("W grze")
        -- local players = getElementsByType("player")
        -- setDiscordRichPresenceDetails("jako " .. name .. " " .. #players .. "/100")
        -- setDiscordRichPresenceStartTime(1)
		-- else
			-- print("error setting discord rich presence.")
    -- end
-- end

function setDiscordRichPresence(name)
   setDiscordApplicationID(app_id)
   if isDiscordRichPresenceConnected() then
	  local players = getElementsByType("player")
	-- setDiscordRichPresenceAsset("my_logo", "-")
	setDiscordRichPresenceButton(1, "Przejdź do discorda", "https://discord.gg/kmmFnzUasY")
	setDiscordRichPresenceButton(2, "Dołącz do gry", "mtasa://192.168.18.78:22003")
	setDiscordRichPresenceState("Zwiedza San Andreas")
	setDiscordRichPresenceDetails("Zalogowano jako: "..name)
	
	setDiscordRichPresencePartySize(#players,100)
	setDiscordRichPresenceStartTime(1)	  
   else
      iprint("RPC: Discord RPC failed to connect")
   end
end

function updatePlayers()
    local players = getElementsByType("player")
    setDiscordRichPresencePartySize(#players,100)
end

function onQuitGameDiscord(reason)
    if setDiscordApplicationID(app_id) then
        updatePlayers()
    end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onQuitGameDiscord)

function onJoinGameDiscord()
    if setDiscordApplicationID(app_id) then
        updatePlayers()
    end
end
addEventHandler("onClientPlayerJoin", getRootElement(), onJoinGameDiscord)

function getPlayerDiscordID()
    if setDiscordApplicationID(app_id) and isDiscordRichPresenceConnected() then
        local id = getDiscordRichPresenceUserID()
        return id
    else
        return false
    end
end


addCommandHandler("getmyuserid",
    function ()
        if isDiscordRichPresenceConnected() then
            local id = getDiscordRichPresenceUserID() 
            if id == "" then 
                outputChatBox("You didn't allow consent to share Discord data! Grant permission in the settings!")
            else 
                outputChatBox("Your Discord userid: "..id)
            end 
        end 
    end
)