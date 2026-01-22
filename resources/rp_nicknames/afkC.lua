local lastClick = getTickCount()


addEventHandler( "onClientRestore", getRootElement(),
	function ()
		lastClick = getTickCount ()
		exports.rp_login:setPlayerData(localPlayer,"afk", false)
		triggerServerEvent("onPlayerGotAFK", localPlayer, false)
	end
)

addEventHandler( "onClientMinimize", getRootElement(),
	function ()
		exports.rp_login:setPlayerData(localPlayer,"afk", true)
		triggerServerEvent("onPlayerGotAFK", localPlayer, true)
	end
)
addEventHandler( "onClientCursorMove", getRootElement( ),
    function ( x, y )
		lastClick = getTickCount ()
		if exports.rp_login:getPlayerData(localPlayer,"afk") then
			exports.rp_login:setPlayerData(localPlayer,"afk", false)
			triggerServerEvent("onPlayerGotAFK", localPlayer, false)
		end
    end
)

addEventHandler("onClientKey", getRootElement(), 
	function ()
		lastClick = getTickCount ()
		if exports.rp_login:getPlayerData(localPlayer,"afk") then
			exports.rp_login:setPlayerData(localPlayer,"afk", false)
			triggerServerEvent("onPlayerGotAFK", localPlayer, false)
		end
	end
)


addEventHandler ("onClientRender",getRootElement(),
	function ()
		local cTick = getTickCount ()
		if cTick-lastClick >= 45000 then
		if not exports.rp_login:getPlayerData(localPlayer,"afk") then
			exports.rp_login:setPlayerData(localPlayer,"afk", true)
			triggerServerEvent("onPlayerGotAFK", localPlayer, true)
			end
		end
	end
)