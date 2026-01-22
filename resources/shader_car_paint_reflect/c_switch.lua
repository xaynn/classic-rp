--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchCarPaintReflect", root, true )
--
--	To switch off:
--			triggerEvent( "switchCarPaintReflect", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource()),
	function()
		if not (tonumber(dxGetStatus().VideoCardPSVersion) > 2) then 
			outputChatBox('sCarReflect: Shader model 3 not supported',255,0,0)
			return
		end
		-- outputDebugString('/sCarReflect to switch the effect')
		-- triggerEvent( "switchCarPaintReflect", resourceRoot, true )
		-- addCommandHandler( "sCarReflect",
			-- function()
				-- triggerEvent( "switchCarPaintReflect", resourceRoot, not cprEffectEnabled )
			-- end
		-- )
	end
)


--------------------------------
-- Switch effect on or off
--------------------------------
function switchCarPaintReflect( cprOn )
	-- outputDebugString( "switchCarPaintReflect: " .. tostring(cprOn) )
	if cprOn then
		startCarPaintReflect()
	else
		stopCarPaintReflect()
	end
end

-- addEvent( "switchCarPaintReflect", true )
-- addEventHandler( "switchCarPaintReflect", resourceRoot, switchCarPaintReflect )
