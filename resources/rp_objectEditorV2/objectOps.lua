objectOps = {}

function addToEditedObjects(object)
    for _, v in ipairs(createdObjects) do
        if v[1] == object then 
            return false
        end
    end

    for _, v in ipairs(editedObjects) do
        if v["Object"] == object then 
            return false
        end
    end

    local x, y, z = getElementPosition(object)
    local rx, ry, rz = getElementRotation(object)
    local xscale, yscale, zscale = getObjectScale(object)

    table.insert(editedObjects, {
        ["Delete"] = false,
        ["Object"] = object,
        ["Position"] = {x, y, z},
        ["Rotation"] = {rx, ry, rz},
        ["Size"] = xscale
    })

    undoUpdate(false, false, object)
    return true
end

function objectOps.selectObject(object)
    addToEditedObjects(object)
    setElementFrozen (object, true)
    return object
end

function objectOps.deSelectObject(object)
    setElementFrozen (object, false)
    return nil
end

function objectOps.getObjectCFrame(object)
    local x, y, z = getElementPosition(object)
    local rx, ry, rz = getElementRotation(object)
    local xscale, yscale, zscale = getObjectScale(object)

    return x, y, z, rx, ry, rz, xscale
end

function objectOps.setObjectCFrame(object, x, y, z, rx, ry, rz, scale)
    setElementPosition(object, x, y, z)
    setElementRotation(object, rx, ry, rz)
    setObjectScale(object, scale)
end

function objectOps.packCreatedObject(object)
    local xPos, yPos, zPos, xRot, yRot, zRot, scale = objectOps.getObjectCFrame(object)
    local objectID = getElementModel(object)
    return { ["ObjectID"] = objectID, ["Position"] = {xPos, yPos, zPos}, ["Rotation"] = {xRot, yRot, zRot}, ["Size"] = scale }
end

function objectOps.packEditedObject(object, delete)
    local xPos, yPos, zPos, xRot, yRot, zRot, scale = objectOps.getObjectCFrame(object)
    return { ["Delete"] = delete, ["Object"] = object, ["Position"] = {xPos, yPos, zPos}, ["Rotation"] = {xRot, yRot, zRot}, ["Size"] = scale }
end

function objectOps.cloneObject(object)
    local x, y, z, rx, ry, rz, scale = objectOps.getObjectCFrame(object)
    local objectID = getElementModel(object)

    local newObject = createObject(objectID, x, y, z)
    objectOps.setObjectCFrame(newObject, x, y, z, rx, ry, rz, scale)
    return newObject
end

return objectOps