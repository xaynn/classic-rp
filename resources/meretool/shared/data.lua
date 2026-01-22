-- TYPE_DATA = 0 {RED,GREEN,BLUE,ALPHA,MD5,TIMESTAMP} -- overlay
-- TYPE_DATA = 1 {RED,GREEN,BLUE,ALPHA,THRESHOLD,FILE,TRANSPARENT,WIDTH,HEIGHT,MD5,TIMESTAMP} -- one color textures
-- TYPE_DATA = 2 {FILE,MD5,TIMESTAMP} -- edited by image editor


all_key = "EVERYTHING"

-- rename to TEXTURES_DATA
TEXTURES_DATA = {
    --[texture_name] = {
    --  [TEXTURE_MD5] = {TYPE,SHADER,DATA,SIZE,ELEMENTS_IDS = {}}
    --}
}

ELEMENTS_DATA = {
    --[ELEMENT_ID] = {[TEXTURE_NAME] = TEXTURE_MD5}
}


function getMD5Key(type_, data)
    if (type_ == 0) then
        return md5(data.RED .. ',' .. data.GREEN .. ',' .. data.BLUE .. ',' .. data.ALPHA)
    elseif (type_ == 1 or type_ == 2) then
        return md5(data.pixels .. "_" .. data.time)
    end
end

function processData(element, type_, textures, data, additional_data, everything)
    if type_ == 0 then
        local key = everything and all_key or
            getMD5Key(type_, { RED = data.RED, GREEN = data.GREEN, BLUE = data.BLUE, ALPHA = data.ALPHA })
        for _, name in ipairs(textures) do
            addData(element, type_, key, name, data, nil, 0, everything)
        end
    elseif type_ == 1 or type_ == 2 then
        for _, v in ipairs(additional_data) do
            local key = everything and all_key or
                getMD5Key(type_, { ["pixels"] = v['PIXELS'], ["time"] = data["TIMESTAMP"] })
            local new_data = copy(data)
            if (type_ == 1 and additional_data) then
                -- add all the needed data for type 1 from the additional data
                new_data["TRANSPARENT"] = v["TRANSPARENT"]
                new_data["FILE"] = v["FILE"]
                new_data["WIDTH"] = v["WIDTH"]
                new_data["HEIGHT"] = v["HEIGHT"]
                new_data["MD5"] = md5(v["PIXELS"])
            end
            addData(element, type_, key, v['NAME'], new_data, v['PIXELS'], v['SIZE'], everything)
        end
    end
end

function addData(element, type_, texture_key, texture_name, data, content, size, everything)
    local element_id = everything and ''
        or getElementID(element)
    if (element_id == nil) then return end;
    clearData(element_id, texture_name, everything)
    if (not TEXTURES_DATA[texture_name]) then
        TEXTURES_DATA[texture_name] = {}
    end
    if (not TEXTURES_DATA[texture_name][texture_key]) then
        TEXTURES_DATA[texture_name][texture_key] = {
            ["TYPE"] = type_,
            ["DATA"] = data,
            ["ELEMENTS_IDS"] = {},
            ["SIZE"] = size or 0,
            ["SHADER"] = false,
        }
        if (data.FILE and content) then
            writePNGFile(MAP_NAME, data.FILE, content)
        end
    end
    if (not everything) then
        TEXTURES_DATA[texture_name][texture_key]["ELEMENTS_IDS"][element_id] = true;
    end
    if (not everything and not ELEMENTS_DATA[element_id]) then
        ELEMENTS_DATA[element_id] = {}
    end
    if (not everything) then
        ELEMENTS_DATA[element_id][texture_name] = texture_key
    end
    if (isClient()) then
        -- Two data may have same md5 key so old data will be ignored with different file name , in this case we pass the old data to the applyShader
        local current_data = TEXTURES_DATA[texture_name][texture_key]["DATA"]
        applyShader(element, type_, texture_name, current_data, everything)
        if (element and isElement(element)) then
            changeLodDistnace(getElementModel(element))
        end
    end
end

function clearData(element_id, texture_name, everything)
    local texture_data = (ELEMENTS_DATA[element_id] or {})
    if (texture_data[texture_name] or everything) then
        if (TEXTURES_DATA[texture_name]) then
            local texture_md5
            if (everything) then
                texture_md5 = all_key
            else
                texture_md5 = texture_data[texture_name]
            end
            local shader = false
            if (TEXTURES_DATA[texture_name][texture_md5]) then
                shader = TEXTURES_DATA[texture_name][texture_md5]["SHADER"]
                if (not everything) then
                    TEXTURES_DATA[texture_name][texture_md5]['ELEMENTS_IDS'][element_id] = nil
                end
                local filename = TEXTURES_DATA[texture_name][texture_md5]['DATA']['FILE']
                if (tableSize(TEXTURES_DATA[texture_name][texture_md5]['ELEMENTS_IDS']) == 0) then
                    TEXTURES_DATA[texture_name][texture_md5] = nil
                    if (filename) then
                        deletePNGFile(MAP_NAME, filename)
                        if (isClient() and isRequesting(MAP_NAME, filename)) then
                            requestCancel(MAP_NAME, filename)
                        end
                    end
                end
                if (tableSize(TEXTURES_DATA[texture_name]) == 0) then
                    TEXTURES_DATA[texture_name] = nil
                end
            end


            if (isClient() and shader) then
                if (everything) then
                    engineRemoveShaderFromWorldTexture(shader, texture_name, nil)
                else
                    engineRemoveShaderFromWorldTexture(shader, texture_name, getElementByID(element_id))
                end
            end

            if (not everything) then
                ELEMENTS_DATA[element_id][texture_name] = nil
                if (tableSize(ELEMENTS_DATA[element_id]) == 0) then
                    ELEMENTS_DATA[element_id] = nil
                end
            end
        end
    end
end

function copyToElements(master, elements, textures_names)
    local master_id = getElementID(master);
    if (ELEMENTS_DATA[master_id]) then
        for name in pairs(textures_names) do
            local texture_key = ELEMENTS_DATA[master_id][name]
            if (texture_key) then
                local data = TEXTURES_DATA[name][texture_key];
                if (data) then
                    for _, v in ipairs(elements) do
                        local element = v["element"]
                        if (element ~= master) then
                            -- (element, type_, texture_key, texture_name, data, content, size, everything)
                            local type_ = data["TYPE"]
                            local DATA = data["DATA"]
                            local SIZE = data["SIZE"]
                            addData(element, type_, texture_key, name, DATA, nil, SIZE, false)
                        end
                    end
                end
            end
        end
    end
end

--- CLIENT ONLY FUNCTIONS
function applyShader(element, type_, texture_name, data, everything)
    local shader = false -- not loaded yet
    local texture_key = everything and all_key or ELEMENTS_DATA[getElementID(element)][texture_name]
    local shader_priority = everything and 1 or 0

    if (not everything) then
        local hasShader = TEXTURES_DATA[texture_name][texture_key]["SHADER"]
        if (hasShader) then
            if (getSetting("shaders")) then
                applyShaderToElement(hasShader, texture_name, element, everything)
            end
            return;
        end
    end


    if (type_ == 0) then
        shader = dxCreateShader(shaders[1], shader_priority, 0, false, 'all')
        dxSetShaderValue(shader, 'red', data.RED / 255)
        dxSetShaderValue(shader, 'green', data.GREEN / 255)
        dxSetShaderValue(shader, 'blue', data.BLUE / 255)
        dxSetShaderValue(shader, 'alpha', data.ALPHA / 255)
        if (getSetting("shaders")) then
            applyShaderToElement(shader, texture_name, element, everything)
        end
    elseif (type_ == 1 or type_ == 2) then
        local texture, _md5 = readPNGFile(MAP_NAME, data.FILE)
        local file_md5 = TEXTURES_DATA[texture_name][texture_key]["DATA"]["MD5"]
        if (texture and file_md5 == _md5) then
            shader = dxCreateShader(shaders[2], shader_priority, 0, false, 'all')
            dxSetShaderValue(shader, "tex", dxCreateTexture(texture, "argb", false, "wrap"))
            if (getSetting("shaders")) then
                applyShaderToElement(shader, texture_name, element, everything)
            end
        else
            requestPNGFile(MAP_NAME, data.FILE, texture_key, texture_name)
        end
    end
    TEXTURES_DATA[texture_name][texture_key]["SHADER"] = shader
end

function applyShaderToElement(shader, texture_name, element, everything)
    if (everything) then
        engineApplyShaderToWorldTexture(shader, texture_name, nil, true)
    else
        engineApplyShaderToWorldTexture(shader, texture_name, element, true)
    end
end
