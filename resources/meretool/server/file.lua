local activeTransfers = {} -- [client] = { [filename] = { handle, timer } }
local bandwidth = 1000000
local cooldown = 60000
local antispam = true

addEvent("mereRequestFile", true)
addEventHandler("mereRequestFile", root, function(path)
    cancelTransfer(source, path)
    if not fileExists(path) then
        missingFileMessage()
        triggerLatentClientEvent(source, "mereReceiveFile", bandwidth, false, resourceRoot, path, false)
        return
    end
    local file = fileOpen(path)
    if not file then
        triggerLatentClientEvent(source, "mereReceiveFile", bandwidth, false, resourceRoot, path, false)
        return
    end

    local data = fileRead(file, fileGetSize(file))
    fileClose(file)


    triggerLatentClientEvent(source, "mereReceiveFile", bandwidth, false, resourceRoot, path, data)

    local handles = getLatentEventHandles(source)
    local newHandle = handles[#handles]
    if not newHandle then
        outputDebugString("Failed to get latent handle for: " .. path)
        return
    end


    if not activeTransfers[source] then activeTransfers[source] = {} end
    activeTransfers[source][path] = {
        handle = newHandle
    }

    local player = source
    local timer = setTimer(function()
        if not isElement(player) then return end

        local status = getLatentEventStatus(player, newHandle)
        if not status then
            killTimer(activeTransfers[player][path].timer)
            activeTransfers[player][path] = nil
            return
        end

        triggerClientEvent(player, "onUpdateFileProgress", resourceRoot,
            path, status.percentComplete, status.totalSize)
    end, 500, 0)

    activeTransfers[source][path].timer = timer
end)



addEvent("onClientCancelFile", true)
addEventHandler("onClientCancelFile", root, function(path)
    cancelTransfer(source, path)
end)

function cancelTransfer(source, path)
    if not activeTransfers[source] or not activeTransfers[source][path] then return end
    if activeTransfers[source][path].timer then
        killTimer(activeTransfers[source][path].timer)
        activeTransfers[source][path].timer = nil
    end
    cancelLatentEvent(source, activeTransfers[source][path].handle)
    activeTransfers[source][path] = nil
end

addEventHandler("onPlayerQuit", root, function()
    if activeTransfers[source] then
        for _, data in pairs(activeTransfers[source]) do
            if isTimer(data.timer) then killTimer(data.timer) end
        end
        activeTransfers[source] = nil
    end
end)


function missingFileMessage()
    if antispam then
        mereOutput("There are missing files! use /merereload", root)
        antispam = false
        setTimer(function()
            antispam = true
        end, cooldown, 1)
    end
end

local not_found_file = fileExists("/images/not_found.png") and fileOpen("/images/not_found.png")
local not_found_content = fileRead(not_found_file, fileGetSize(not_found_file))
local not_found_md5 = md5(not_found_content)
fileClose(not_found_file)


function mapFilesRepair(player)
    deleteFilesCache()
    local not_found = 0
    local changed = 0
    if (not not_found_file) then
        mereOutput(" something went wrong!", player)
        return
    end
    for texture_name in pairs(TEXTURES_DATA) do
        for key in pairs(TEXTURES_DATA[texture_name]) do
            local data = TEXTURES_DATA[texture_name][key]["DATA"]
            if (data and data["FILE"]) then
                local content, file_md5 = readPNGFile(MAP_NAME, data["FILE"])
                if (content) then
                    if (file_md5 ~= data["MD5"]) then
                        changed = changed + 1
                        TEXTURES_DATA[texture_name][key]["DATA"]["MD5"] = file_md5;
                    end
                else
                    writePNGFile(MAP_NAME, data["FILE"], not_found_content)
                    not_found = not_found + 1
                    TEXTURES_DATA[texture_name][key]["DATA"]["MD5"] = not_found_md5;
                end
            end
        end
    end

    if (not_found > 0 or changed > 0) then
        mereOutput((not_found + changed) .. " files have been successfully repaired. Use the /meresync.", root)
    else
        mereOutput(" No missing or changed files", player)
    end
end
