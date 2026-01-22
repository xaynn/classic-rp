utility = {}

function utility.getPositionFromElementOffset(element, offX, offY, offZ) 
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2] 
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3] 
    return x, y, z
end

function utility.findValueInTable(table, element)
	for _, v in pairs(table) do
		if v == element then 
			return true 
		end
	end
	return false
end

function utility.findKeyInTable(table, element)
	for k, _ in pairs(table) do
		if k == element then 
			return true 
		end
	end
	return false
end

function utility.getDistanceBetweenElements(arg1, arg2)
	local element1 = Vector3(getElementPosition(arg1))
	local element2 = Vector3(getElementPosition(arg2))
	local distance = getDistanceBetweenPoints3D(element1, element2)
	return distance
end

function utility.animation(player, animName, category, freezeLastFrame, loop)
    local loop = loop or false
    local freezeLastFrame = freezeLastFrame or false
    setPedAnimation(player, category, animName, -1, loop, false, false, freezeLastFrame)
end

return utility
