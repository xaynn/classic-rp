browserGUI = nil
browser = nil
local browser_element = nil
local browser_texture_name = nil
local browser_model = nil


addEventHandler("onClientResourceStart", resourceRoot, function()
    local screenWidth, screenHeight = guiGetScreenSize()

    browserGUI                      = guiCreateBrowser(0, 0, screenWidth, screenHeight, true, true)
    browser                         = guiGetBrowser(browserGUI)
    setDevelopmentMode(true, true)

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/tui/index.html")

        -- toggleBrowserDevTools(browser, true)
    end)

    guiSetVisible(browserGUI, false)
end)



function openBrowser(js)
    guiSetVisible(browserGUI, true)
    showCursor(guiGetVisible(browserGUI))
    showChat(false)
    executeBrowserJavascript(browser, js)
    addEventHandler("onClientKey", root, cancelAllKeys)
    guiSetVisible(GUIEditor.window[1], false)
    exports["editor_gui"]:setGUIShowing(false)
    exports["editor_gui"]:setHUDAlpha(0)
end

function closeBrowser(force)
    local getVisible = guiGetVisible(browserGUI)
    if (force and getVisible) then
        mereOutput("Something went wrong, please try again.")
    end
    if (getVisible) then
        loadBrowserURL(browser, "http://mta/local/tui/index.html")
    end
    if (isEventHandlerAdded("onClientKey", root, cancelAllKeys)) then
        removeEventHandler("onClientKey", root, cancelAllKeys)
    end
    guiSetVisible(browserGUI, false)
    showCursor(guiGetVisible(browserGUI))
    showChat(true)
    exports["editor_gui"]:setGUIShowing(true)
    exports["editor_gui"]:setHUDAlpha(100)
end

function setBrowserData(element, texture_name, model)
    browser_element = element
    browser_texture_name = texture_name
    browser_model = model
end

function isBrowserDataEqual(element, texture_name, model)
    return browser_element == element and browser_texture_name == texture_name and browser_model == model
end

addEvent("MereCloseBrowser", true)
addEventHandler("MereCloseBrowser", root,
    function()
        closeBrowser()
    end
)


function cancelAllKeys()
    cancelEvent()
end
