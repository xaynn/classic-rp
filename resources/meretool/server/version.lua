function versionCheck()
    if hasObjectPermissionTo(resource, "function.callRemote") then
        callRemote("http://community.mtasa.com/mta/resources.php", handleVersionCheck, "version", "meretool")
    end
end

function handleVersionCheck(resName, commVer, commId)
    local thisVer = getResourceInfo(getThisResource(), "version")
    if commId and current_version ~= commVer then
        outputChatBox("meretool" ..
            " is outdated. Your version: " .. thisVer .. " | Current: " .. commVer)
        outputChatBox(
            "Please download the update @ http://community.multitheftauto.com/index.php?p=resources&s=details&id=" ..
            commId)
    end
end

versionCheck()
