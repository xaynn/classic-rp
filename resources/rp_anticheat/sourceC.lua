local createdEvents = {}

function onGotEvents(table)
	createdEvents = table
	-- iprint(createdEvents)
end
addEvent ( "onGotEvents", true )
addEventHandler ( "onGotEvents", root, onGotEvents )


function getCreatedEvents()
	return createdEvents
end

function onClientExplosion(x, y, z, theType)
	cancelEvent()
end
addEventHandler("onClientExplosion", root, onClientExplosion)

--local events = exports.rp_anticheat:getCreatedEvents()
-- events["onPlayerTryToLogin"] = event
-- local events = exports.rp_anticheat:getCreatedEvents()
-- print(events["onPlayerTryToLogin"])
-- print(createdEvents["onPlayerCreateCharacter"])



-- function tset()
-- iprint(createdEvents["onPlayerCreateCharacter"])
-- local events = exports.rp_anticheat:getCreatedEvents()
-- iprint(events["onPlayerTryToLogin"])
-- end
-- addCommandHandler("eventy", tset, false, false)
