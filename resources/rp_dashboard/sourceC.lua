local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont('files/Helvetica.ttf', 13 * scaleValue, false, 'proof') or 'default' -- fallback to default
local font2 = dxCreateFont('files/Helvetica.ttf', 10 * scaleValue, false, 'proof') or 'default' -- fallback to default
local settingsLoaded = false

DGS = exports.dgs

local settings = {
    ["headmove ja"] = true,
    ["headmove inni"] = true,
	["Widoczny swój nick"] = true,
	["Refleksje samochodu"] = true,
	["Depth of Field"] = false,
	["Dynamiczne niebo"] = true,
	["Customowe dźwięki"] = true,
	
	

}
local settingOrder = {
    "headmove ja",
    "headmove inni",
    "Widoczny swój nick",
    "Refleksje samochodu",
    "Depth of Field",
    "Dynamiczne niebo",
	"Customowe dźwięki",
}


local settingCallbacks = {
    ["headmove ja"] = function(state)
        headmove.enable(state) -- lub headmove.enable(state, false)
    end,
    ["headmove inni"] = function(state)
        -- np. headmove.enable(state, true)
		headmove.enable(nil, state)
    end,
	["Widoczny swój nick"] = function(state)
	exports.rp_nicknames:togme(state)
	end,
	["Refleksje samochodu"] = function(state)
	exports.shader_car_paint_reflect:switchCarPaintReflect(state)
	end,
	["Depth of Field"] = function(state)
	exports.shader_depth_of_field:switchDoF(state)
	end,
	["Dynamiczne niebo"] = function(state)
		triggerEvent( "switchDynamicSky", root, state )
	end,
	["Customowe dźwięki"] = function(state)
		enableCustomSounds(state)
	end,
}

function saveSettingsToFile()
    local jsonData = toJSON(settings, true) 
    local file = fileCreate("@settings.cfg")
    if file then
        fileWrite(file, jsonData)
        fileClose(file)
    else
        -- outputDebugString("Nie udało się stworzyć pliku settings.cfg")
    end
end


function loadSettingsFromFile()
    if settingsLoaded then return end

    if fileExists("@settings.cfg") then
        local file = fileOpen("@settings.cfg")
        if file then
            local size = fileGetSize(file)
            local content = fileRead(file, size)
            fileClose(file)

            local loadedSettings = fromJSON(content)
            if type(loadedSettings) == "table" then
                settings = loadedSettings
                for k, v in pairs(settings) do
                    if settingCallbacks[k] then
                        settingCallbacks[k](v)
                    end
                end
                settingsLoaded = true
            end
        end
    else
        saveSettingsToFile()
        for k, v in pairs(settings) do
            if settingCallbacks[k] then
                settingCallbacks[k](v)
            end
        end
        settingsLoaded = true
    end
end



function loadDashboardSettings(name)
    exports.rp_hud:initHud(true)
    exports.rp_chat:enableOOC(true)
    if name then
        exports.rp_login:setDiscordRichPresence(name)
    end
    exports.rp_nicknames:loadPlayerNicknames()
    -- exports.rp_inventory:loadFastSlots()
	loadSettingsFromFile()
end
addEvent("onPlayerLoadedDashboardSettings", true)
addEventHandler("onPlayerLoadedDashboardSettings", root, loadDashboardSettings)
local suppressCheckboxEvent = false


local dashboardData = {}

function dashboardClosed()
	dashboardData.showed = false
	removeEventHandler("onDgsCheckBoxChange", root, onSettingsCheckboxChange)
end
local delay = 100-- ms

function openDashboard(data)
	if dashboardData.showed then return end
	dashboardData.showed = true
	dashboardData.window = exports.rp_library:createWindow("dashboardWindow",1 / 2 - 350 * scaleValue,1 / 2 - 250 * scaleValue,600 * scaleValue,500 * scaleValue,"Dashboard",5,0.55 * scaleValue,true)
	local rectangle = DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {6,false}, {6,false} }, tocolor(26, 29, 38,255) )
    dashboardData.tabPanel = DGS:dgsCreateTabPanel(5 * scaleValue,1 * scaleValue,590 * scaleValue,450 * scaleValue,false,dashboardData.window,_,rectangle)
    DGS:dgsCenterElement(dashboardData.window)
    dashboardData.tab1 = DGS:dgsCreateTab("Główna", dashboardData.tabPanel)
	dashboardData.tab2 = DGS:dgsCreateTab("Ustawienia", dashboardData.tabPanel)
	DGS:dgsSetProperty(dashboardData.tab1, "font", font)
	DGS:dgsSetProperty(dashboardData.tab2, "font", font)
	addEventHandler("onDgsWindowClose", dashboardData.window, dashboardClosed)
	-- dashboardData.characterName = exports.rp_library:createLabel("dashboard:name",5*scaleValue,10*scaleValue * scaleValue,50 * scaleValue,data.characterName,dashboardData.tab1,1 * scaleValue,"left","top",true,true,false)
    dashboardData.characterName = exports.rp_library:createLabel("dashboard:name",5 * scaleValue,10 * scaleValue,50 * scaleValue,50 * scaleValue,"Nazwa postaci: "..data.characterName.." (CID: "..data.characterID..")",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
    dashboardData.premium = exports.rp_library:createLabel("dashboard:premium",5 * scaleValue,40 * scaleValue,50 * scaleValue,50 * scaleValue,"Premium: #d4a60f"..data.premium,dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
	local playtimeInHours = math.floor(data.playtime / 3600)
	local playtimeInMinutes = math.floor((data.playtime % 3600) / 60) 
	dashboardData.playtime = exports.rp_library:createLabel("dashboard:playtime",5 * scaleValue,70 * scaleValue,50 * scaleValue,50 * scaleValue,"Czas gry: "..playtimeInHours.."h, "..playtimeInMinutes.."m",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
--gridlista z intkami, pojazdami, paski z sila, kondycja.
	dashboardData.bankMoney = exports.rp_library:createLabel("dashboard:bankmoney",5 * scaleValue,98 * scaleValue,50 * scaleValue,50 * scaleValue,"Bank: #038509"..data.bankMoney.."$",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)


	dashboardData.gridlistVehicles = exports.rp_library:createGridList("vehiclesGridListdashboard",10 * scaleValue,120 * scaleValue,200*scaleValue,200*scaleValue,dashboardData.tab1,nil,1*scaleValue)
	dashboardData.vehiclecolumn = DGS:dgsGridListAddColumn( dashboardData.gridlistVehicles, "Nazwa pojazdu", 1 )
	DGS:dgsGridListSetColumnFont(dashboardData.gridlistVehicles, dashboardData.vehiclecolumn, font2)
	--id, x, y, width, height, parent, columnHeight, scale
	dashboardData.gridlistInteriors = exports.rp_library:createGridList("interiorGridListdashboard",380 * scaleValue,120 * scaleValue,200*scaleValue,200*scaleValue,dashboardData.tab1,nil,1*scaleValue)
	dashboardData.interiorcolumn = DGS:dgsGridListAddColumn( dashboardData.gridlistInteriors, "Nazwa interioru", 1 )
	DGS:dgsGridListSetColumnFont(dashboardData.gridlistInteriors, dashboardData.interiorcolumn, font2)
	DGS:dgsSetProperty(dashboardData.gridlistVehicles,"leading",5)
	
	
	        DGS:dgsSetPostGUI(dashboardData.characterName, true)
        DGS:dgsSetPostGUI(dashboardData.premium, true)
        DGS:dgsSetPostGUI(dashboardData.playtime, true)
        DGS:dgsSetPostGUI(dashboardData.bankMoney, true)

	
	
	
	dashboardData.scroll = DGS:dgsCreateScrollPane(200 * scaleValue, 10* scaleValue, 300 * scaleValue, 300 * scaleValue, false, dashboardData.tab2)
	dashboardData.y = 6
	dashboardData.settingsCheckboxes = {}
for index, key in ipairs(settingOrder) do
    setTimer(function()
        local value = settings[key]
        local checkboxID = "checkbox:settings" .. key

        dashboardData.settingsCheckboxes[key] = exports.rp_library:createCheckBox(
            checkboxID,
            4 * scaleValue,
            dashboardData.y,
            key,
            dashboardData.scroll,
            0.5 * scaleValue
        )
		suppressCheckboxEvent = true
        exports.rp_library:setCheckBoxState(checkboxID, value)
		suppressCheckboxEvent = false
        dashboardData.y = dashboardData.y + 20
    end, delay * (index - 1), 1) -- odliczamy opóźnienie dla każdego indexu
end

	addEventHandler("onDgsCheckBoxChange", root, onSettingsCheckboxChange)

	
	for k,v in pairs(data.vehicles) do
	local id = exports.rp_vehicles:getVehicleData(v,"uid")
	local vehName = exports.rp_vehicles:getVehicleData(v,"vehicleName")
	local row = DGS:dgsGridListAddRow ( dashboardData.gridlistVehicles )
	DGS:dgsGridListSetItemText ( dashboardData.gridlistVehicles, row, dashboardData.vehiclecolumn, vehName.." (ID: "..id..")" )
	DGS:dgsGridListSetItemFont ( dashboardData.gridlistVehicles, row, dashboardData.vehiclecolumn, font2 )

	end
	
	for k,v in pairs(data.interiors) do
	local row = DGS:dgsGridListAddRow ( dashboardData.gridlistInteriors )
	DGS:dgsGridListSetItemText ( dashboardData.gridlistInteriors, row, dashboardData.vehiclecolumn, v )
	DGS:dgsGridListSetItemFont ( dashboardData.gridlistInteriors, row, dashboardData.vehiclecolumn, font2 )

	end
	DGS:dgsSetProperty(dashboardData.gridlistInteriors,"leading",5)
	dashboardData.strength = exports.rp_library:createLabel("dashboard:strength",10 * scaleValue,335 * scaleValue,50 * scaleValue,50 * scaleValue,"Siła:",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
    dashboardData.strenghtBar = DGS:dgsCreateProgressBar(100 * scaleValue, 330 * scaleValue, 150 * scaleValue, 34 * scaleValue, false, dashboardData.tab1)


	DGS:dgsProgressBarSetProgress(dashboardData.strenghtBar, math.floor(data.strength))  -- silka
	dashboardData.labelpercent = exports.rp_library:createLabel("dashboard:strengthpercent",260 * scaleValue,335 * scaleValue,50 * scaleValue,50 * scaleValue,DGS:dgsGetProperty(dashboardData.strenghtBar,"progress").."/100".."%",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)

	dashboardData.fitness = exports.rp_library:createLabel("dashboard:fitness",10 * scaleValue,385 * scaleValue,50 * scaleValue,50 * scaleValue,"Kondycja:",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
    dashboardData.strenghtBarFitness = DGS:dgsCreateProgressBar(100 * scaleValue, 380 * scaleValue, 150 * scaleValue, 34 * scaleValue, false, dashboardData.tab1)
	
	DGS:dgsProgressBarSetProgress(dashboardData.strenghtBarFitness, math.floor(data.fitness)) --
	dashboardData.labelpercentfitness = exports.rp_library:createLabel("dashboard:fitnesslabel",260 * scaleValue,385 * scaleValue,50 * scaleValue,50 * scaleValue,DGS:dgsGetProperty(dashboardData.strenghtBarFitness,"progress").."/100".."%",dashboardData.tab1,0.6 * scaleValue,"left","top",true,true,false)
	DGS:dgsSetPostGUI(dashboardData.strength, true)
    DGS:dgsSetPostGUI(dashboardData.labelpercent, true)
	DGS:dgsSetPostGUI(dashboardData.fitness, true)
    DGS:dgsSetPostGUI(dashboardData.labelpercentfitness, true)

end
addEvent("onPlayerOpenDashboard", true)
addEventHandler("onPlayerOpenDashboard", getRootElement(), openDashboard)

function onSettingsCheckboxChange(state)
    if suppressCheckboxEvent then return end

    for k, checkbox in pairs(dashboardData.settingsCheckboxes) do
        if source == checkbox then
            settings[k] = state
            saveSettingsToFile()
            if settingCallbacks[k] then
                settingCallbacks[k](state)
            end
            break
        end
    end
end

removeWorldModel(1283, 99999, 1921.2431640625,-1751.322265625,13.3828125)