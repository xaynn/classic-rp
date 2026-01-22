COLOR_CODE = "#FFA500"  -- Orange color for Meretool prefix
COLOR_WHITE = "#FFFFFF" -- White color for messages


function tableSize(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function split(input, sep)
    local result = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(result, str)
    end
    return result
end

function rgbaToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

function hexToRgba(hex)
    hex = hex:gsub("#", "")
    if #hex < 6 then
        return nil, nil, nil
    end
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    return r, g, b
end

function mergeTables(t1, t2)
    local merged = {}
    for i, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for i, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end

function formatFileSize(bytes)
    if bytes < 1024 then
        return bytes .. " bytes"
    elseif bytes < 1024 * 1024 then
        return string.format("%.2f KB", bytes / 1024)
    else
        return string.format("%.2f MB", bytes / (1024 * 1024))
    end
end

function vectorCompare(v1, v2)
    if not v1 or not v2 then return false end
    return math.abs(v1[1] - v2[1]) < 0.01 and
        math.abs(v1[2] - v2[2]) < 0.01 and
        math.abs(v1[3] - v2[3]) < 0.01
end

function padRight(text, totalLength)
    local visibleLength = utf8.len(text)
    local pad = totalLength - visibleLength
    return text .. string.rep(" ", pad > 0 and pad or 0)
end

function isClient()
    return isElement(localPlayer)
end

function mereOutput(text, element)
    if (isClient()) then
        outputChatBox(COLOR_CODE .. "Meretool : " .. COLOR_WHITE .. text, 255, 255, 255,
            true)
    else
        outputChatBox(COLOR_CODE .. "Meretool : " .. COLOR_WHITE .. text, element, 255, 255, 255,
            true)
    end
end

function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
    if type(sEventName) == 'string' and isElement(pElementAttachedTo) and type(func) == 'function' then
        local aAttachedFunctions = getEventHandlers(sEventName, pElementAttachedTo)
        if type(aAttachedFunctions) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs(aAttachedFunctions) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function base64Size(base64)
    local clean = base64:gsub("^data:.-;base64,", "")

    local padding = 0
    if clean:sub(-2) == "==" then
        padding = 2
    elseif clean:sub(-1) == "=" then
        padding = 1
    end

    local size = (#clean * 3) / 4 - padding
    return size
end

function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

keyTable = {
    mouse1 = true,
    mouse2 = true,
    mouse3 = true,
    mouse4 = true,
    mouse5 = true,
    mouse_wheel_up = true,
    mouse_wheel_down = true,
    arrow_l = true,
    arrow_u = true,
    arrow_r = true,
    arrow_d = true,
    ["0"] = true,
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
    a = true,
    b = true,
    c = true,
    d = true,
    e = true,
    f = true,
    g = true,
    h = true,
    i = true,
    j = true,
    k = true,
    l = true,
    m = true,
    n = true,
    o = true,
    p = true,
    q = true,
    r = true,
    s = true,
    t = true,
    u = true,
    v = true,
    w = true,
    x = true,
    y = true,
    z = true,
    num_0 = true,
    num_1 = true,
    num_2 = true,
    num_3 = true,
    num_4 = true,
    num_5 = true,
    num_6 = true,
    num_7 = true,
    num_8 = true,
    num_9 = true,
    num_mul = true,
    num_add = true,
    num_sep = true,
    num_sub = true,
    num_div = true,
    num_dec = true,
    num_enter = true,
    F1 = true,
    F2 = true,
    F3 = true,
    F4 = true,
    F5 = true,
    F6 = true,
    F7 = true,
    F8 = true,
    F9 = true,
    F10 = true,
    F11 = true,
    F12 = true,
    escape = true,
    backspace = true,
    tab = true,
    lalt = true,
    ralt = true,
    enter = true,
    space = true,
    pgup = true,
    pgdn = true,
    end_ = true,
    home = true,
    insert = true,
    delete = true,
    lshift = true,
    rshift = true,
    lctrl = true,
    rctrl = true,
    ["["] = true,
    ["]"] = true,
    pause = true,
    capslock = true,
    scroll = true,
    [";"] = true,
    [","] = true,
    ["-"] = true,
    ["."] = true,
    ["/"] = true,
    ["#"] = true,
    ["\\"] = true,
    ["="] = true
}
