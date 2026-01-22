function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function capitalizeFirstLetter(text)
    return text:sub(1, 1):upper() .. text:sub(2)
end


components = {"ammo", "clock", "money", "radar", "weapon", "health", "armour"}
