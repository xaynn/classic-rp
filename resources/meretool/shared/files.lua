local files_cache = {}


defaultMapName = "editor_dump"


function generateFilename(texture_name)
    local timestamp = getRealTime().timestamp
    return texture_name .. "_" .. timestamp .. "_" .. math.random(1, 100)
end

function getPath(mapName, fileName)
    mapName = mapName or defaultMapName
    return string.format("maps/%s/%s.png", mapName, fileName)
end

function readPNGFile(mapName, fileName)
    mapName = mapName or defaultMapName
    local path = getPath(mapName, fileName)
    if isInCache(fileName) then
        local content, _md5, size = getFromCache(fileName)
        return content, _md5, size
    end
    local file = fileExists(path) and fileOpen(path) or false
    if not file then return false end

    local size = fileGetSize(file)
    local content = fileRead(file, size)
    fileClose(file)
    local _md5 = md5(content)
    addToCache(fileName, content, _md5, size)
    return content, _md5, size
end

function writePNGFile(mapName, fileName, content)
    mapName = mapName or defaultMapName
    local path = getPath(mapName, fileName)

    if fileExists(path) then
        fileDelete(path)
    end

    local file = fileCreate(path)
    if not file then return false end

    fileWrite(file, content)
    fileClose(file)

    addToCache(fileName, content, md5(content), #content)
    return true
end

function deletePNGFile(mapName, fileName)
    mapName = mapName or defaultMapName
    local path = getPath(mapName, fileName)

    if fileExists(path) then
        deleteFromCache(fileName)
        return fileDelete(path)
    end
    return false
end

function deleteFilesCache()
    files_cache = {}
end

function fillFilesCache()
    local missing_files = false
    for _, textures in pairs(TEXTURES_DATA) do
        for _, data in pairs(textures) do
            if (data and data["DATA"] and data["DATA"]["FILE"]) then
                local content = readPNGFile(MAP_NAME, data["DATA"]["FILE"])
                if (not content) then
                    missing_files = true
                end
            end
        end
    end
    if (missing_files) then
        mereOutput("There are some missing files in this map use /merereload #ff0000!!!", root)
    end
end

function isInCache(filename)
    return files_cache[filename] ~= nil
end

function addToCache(filename, content, _md5, size)
    files_cache[filename] = { content, _md5, size }
end

function deleteFromCache(filename)
    files_cache[filename] = nil
end

function getFromCache(filename)
    return files_cache[filename][1], files_cache[filename][2], files_cache[filename][3]
end

function getCacheFilesSize()
    local files_count = 0
    local total_size = 0

    for _, data in pairs(files_cache) do
        files_count = files_count + 1
        total_size = total_size + data[3]
    end

    return files_count, total_size
end
