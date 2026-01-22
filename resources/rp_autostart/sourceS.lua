local customResources = {"object_preview", "dgs", "pAttach", "cpicker", "shader_car_paint_reflect", "shader_depth_of_field", "shader_dynamic_sky", "wide_corona_fix_shader", "realdriveby"}
local resourcesToDisable = {"scoreboard", "ip2c"}
local dbResourceStarted = false 

function startAllResources(res)
    if getThisResource() == res then

    local resources = getResources()
    local rpResources = {}

    for _, resource in ipairs(resources) do
        local resourceName = getResourceName(resource)

        for _, customName in ipairs(customResources) do
            if string.find(resourceName, customName) then
                startResource(resource)
                outputDebugString("[Classic RolePlay] Custom resource started: " .. resourceName)
            end
        end

        if string.find(resourceName, "rp_") then
            if resourceName == "rp_db" then
                startResource(resource)
                outputDebugString("[Classic RolePlay] rp_db resource started")
                dbResourceStarted = true
            else
                table.insert(rpResources, resource) 
            end
        end
    end

    if dbResourceStarted then
        for _, rpResource in ipairs(rpResources) do
            startResource(rpResource)
            outputDebugString("[Classic RolePlay] Resource loaded: " .. getResourceName(rpResource))
        end
    else
        outputDebugString("[Classic RolePlay] Error: rp_db not found, other rp_ resources not started")
    end

    for _, disableResource in ipairs(resourcesToDisable) do
        local res = getResourceFromName(disableResource)
        if res and getResourceState(res) == "running" then
            stopResource(res)
            outputDebugString("[Classic RolePlay] Resource disabled: " .. disableResource)
        end
    end
end
end

addEventHandler("onResourceStart", root, startAllResources)
