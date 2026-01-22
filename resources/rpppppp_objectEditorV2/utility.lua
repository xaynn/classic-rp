utility = {}

function utility.findRotation3D(x1, y1, z1, x2, y2, z2)
    local rotx = math.atan2 (z2 - z1, getDistanceBetweenPoints2D (x2, y2, x1, y1))
    rotx = math.deg(rotx)
    local rotz = -math.deg(math.atan2(x2 - x1, y2 - y1))
    rotz = rotz < 0 and rotz + 360 or rotz
    return rotx, 0, rotz
end

function utility.isMouseInPosition ( x, y, width, height )
    if ( not isCursorShowing( ) ) then
        return false
    end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    
    return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function utility.countDictionary(d)
    local n = 0
    for _, v in pairs(d) do
        n = n + 1
    end
    return n
end

function utility.removeFromTable(table, value)
    for i, v in ipairs(table) do
        if v == value then
            table[i] = nil
            return true
        end
    end
    return false
end

function utility.findIndex(table, value)
    for i, v in ipairs(table) do
        if v == value then return i end
    end
    return false
end

return utility