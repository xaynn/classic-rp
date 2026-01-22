local createdObjects = {
    ["world"] = { ["id"] = 0 }
} 

---- schemat tej tabeli: (gdzie IDobiektu to jest ID utworzone dla kazdego obiektu w interiorze)
-- local createdObjects = 
--     [IDinterioru] = {
--         [IDobiektu] = obiekt
--      }

-- temp to instrukcje tymczasowe

--createdObjects["world"] = {} -- W miejsce worlda bedzie id posesji (interiora) -- temp

local InteriorID = "world" -- temp


function objCreationHandler ( objectID, x_pos, y_pos, z_pos, x_rot, y_rot, z_rot, x_scale )
    if objectID and x_pos and y_pos and z_pos then
        createdObjects[InteriorID]["id"] = createdObjects[InteriorID]["id"] + 1
        local objectServerID = tostring(createdObjects[InteriorID]["id"])
        createdObjects[InteriorID][objectServerID] = createObject(objectID, x_pos, y_pos, z_pos)
        setElementRotation(createdObjects[InteriorID][objectServerID], x_rot, y_rot, z_rot)
        setObjectScale(createdObjects[InteriorID][objectServerID], x_scale)
    end
end

-- gdy gracz zakonczy tworzenie objektow po kliencie klika save i wykonuje sie to
function saveObj ( objectID, pos, rot, textureImageA, textureImageB)

		exports.rp_interiors:addObjectToInterior(client, objectID, pos, rot, textureImageA, textureImageB)
end

function getNewObjectID(table)
    return countDictionary(table) + 1
end

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
 end

function updateObj(lastID, rot, pos, textureImageA, textureImageB, creating)
	iprint(lastID, rot, pos, textureImageA, textureImageB)
	exports.rp_interiors:editObjectFromInterior(client, lastID, pos, rot, textureImageA, textureImageB)
			outputChatBox("zapisano")
end

-- eventy
addEvent( "createObj", true )
addEventHandler( "createObj", root, saveObj )

addEvent( "updateObj", true )
addEventHandler( "updateObj", root, updateObj )

-- Utility functions

function getElementServerID(element)
    for k, v in pairs(createdObjects) do
        for k2, v2 in pairs(v) do
            if v2 == element then return k,k2 end
        end
    end
end

function countDictionary(d)
    local n = 0
    for _, v in pairs(d) do
        n = n + 1
    end
    return n
end

function test()
    print("CREATED OBJECTS:")
    iprint(createdObjects)
end
addEvent( "test", true )
addEventHandler( "test", root, test )