--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchDynamicSky", root, true )
--
--	To switch off:
--			triggerEvent( "switchDynamicSky", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
-- Auto switch on at start
--------------------------------



--------------------------------
-- Switch effect on or off
--------------------------------
function switchDynamicSky( dsOn )
	-- outputDebugString( "switchDynamicSky: " .. tostring(dsOn) )
	if dsOn then
		startDynamicSky()
	else
		stopDynamicSky()
	end
end

addEvent( "switchDynamicSky", true )
addEventHandler( "switchDynamicSky", resourceRoot, switchDynamicSky )

--------------------------------
-- onClientResourceStop
-- Stop the resource
--------------------------------
addEventHandler( "onClientResourceStop", getResourceRootElement( getThisResource()),stopDynamicSky)
