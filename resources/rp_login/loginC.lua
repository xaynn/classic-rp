DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local loginState = "login"
local isDataSetTimer = false
local music = false

function returnMusic()
	return music
end



function isDataSet()
	if loginState ~= "login" then return end
    local text = exports.rp_library:getEditBoxText("password:editbox")
    if text == "" then
        reciveSavedData()
    else
        killTimer(isDataSetTimer)
    end
end

function getCharData(tbl, key)
	if not tbl then return false end
	if not tbl[key] then return end
    if tbl[key] ~= nil then
        return tbl[key]
    else
        return nil
    end
end
local function stopMusic(key, keyState)
	local isFocused = DGS:dgsGetType(DGS:dgsGetFocusedGUI())
	if isFocused ~= "boolean" and isFocused ~= "nil" then return end
	local state = isSoundPaused(music)
	setSoundPaused(music, not state)
end
bindKey( "SPACE", "down", stopMusic )
function getCharDataFromTable(player, data)
	local stats = getPlayerData(player, "statistics")
	local datac = getCharData(stats, data)

	return datac or false
end

function reciveSavedData()
    local _login, _password = getSavedData()
    if not _login then return false end

    -- exports.rp_library:setEditBoxText("username:editbox", _login)
	-- exports.rp_library:setEditBoxText("password:editbox", _password)

	-- DGS:dgsSetProperty(loginPanelData.checkbox,"state",true)
	setTimer(function() 
	exports.rp_library:setEditBoxText("username:editbox", _login)
	exports.rp_library:setEditBoxText("password:editbox", _password)
	exports.rp_library:setCheckBoxState("checkbox:rememberme", true)
	end, 200, 1)


end

function setSavedData(login, _password)
    local xml = (xmlLoadFile("lgmtadata") or xmlCreateFile("lgmtadata", "savedData"))
    if not xml then return false end
    local loginChild = (xmlFindChild(xml, "login", 0) or xmlCreateChild(xml, "login"))
    local passwordChild = (xmlFindChild(xml, "password", 0) or xmlCreateChild(xml, "password"))
    if not loginChild or not passwordChild then return false end
    if not login or not _password then return false end 
	local crypt = teaEncode(exports.rp_library:getEditBoxText("password:editbox"), "M6SRdED8ass4DckG")
    xmlNodeSetValue(loginChild, login)
    xmlNodeSetValue(passwordChild, crypt) -- crypt
    xmlSaveFile(xml)
    xmlUnloadFile(xml)

end

function getSavedData()
    local xml = xmlLoadFile("lgmtadata", true)
    if not xml then return false end
    local _login = xmlNodeGetValue(xmlFindChild(xml, "login", 0))
    local _password = xmlNodeGetValue(xmlFindChild(xml, "password", 0))
    if not _login or not _password then return false end
	local decryptedPassword = teaDecode ( _password, "M6SRdED8ass4DckG" )

    return _login, decryptedPassword
end

local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont('files/Helvetica.ttf', 15 * scaleValue, false, 'proof') or 'default' -- fallback to default


--basic color #201d30, background - #302b4a, kolor fontow - #faf5f5, przyciski - #e3326e
local loginPanelData = {}


function tryToLogin(button)
    if button == "left" then
	if isTransferBoxActive() then return exports.rp_library:createBox("Poczekaj aż wszystkie zasoby na serwerze się pobiorą.") end
        if source == loginPanelData.buttonLogin then
            setDisabledButton()
			local userlength, passlength = string.len(exports.rp_library:getEditBoxText("username:editbox")),string.len(exports.rp_library:getEditBoxText("password:editbox"))
			if userlength < 4 or passlength < 6 then return exports.rp_library:createBox("Login lub hasło jest za krótkie.") end
			-- local discordID = getPlayerDiscordID()
			-- if discordID == "" or discordID == false then return exports.rp_library:createBox("Discord jest wymagany do gry na serwerze, włącz Discorda i włącz w ustawieniach MTA jeżeli wyłączyłeś oraz zrestartuj MTA przy użyciu administratora, jeżeli błąd występuje dalej to poczekaj do minuty na serwerze, jeżeli wszystkie kroki wykonałeś.") end 
            if loginState == "login" then
                triggerServerEvent("onPlayerTryToLogin",localPlayer,exports.rp_library:getEditBoxText("username:editbox"),exports.rp_library:getEditBoxText("password:editbox"),exports.rp_library:getEditBoxText("password:editbox"),loginState,discordID,exports.rp_admin:getBanID())
                if exports.rp_library:getCheckBoxState("checkbox:rememberme") then--DGS:dgsCheckBoxGetSelected(loginPanelData.checkbox) then
                    setSavedData(exports.rp_library:getEditBoxText("username:editbox"),exports.rp_library:getEditBoxText("password:editbox"))
                end
            elseif loginState == "register" then
                triggerServerEvent("onPlayerTryToLogin",localPlayer,exports.rp_library:getEditBoxText("username:editbox"),exports.rp_library:getEditBoxText("password:editbox"),exports.rp_library:getEditBoxText("password:editboxsecond"),loginState,discordID, exports.rp_admin:getBanID(), exports.rp_library:getEditBoxText("password:editboxverify"))
				setSavedData(exports.rp_library:getEditBoxText("username:editbox"),exports.rp_library:getEditBoxText("password:editbox"))
            end
        end
    end
end







function showPanel(mode)
	if isElement(loginPanelData.usernameEditbox) then
	    removeEventHandler("onDgsMouseClickUp", loginPanelData.buttonLogin, tryToLogin)
		exports.rp_library:destroyEditBox("username:editbox")
		exports.rp_library:destroyEditBox("password:editbox")
		exports.rp_library:destroyCheckbox("checkbox:rememberme")
		exports.rp_library:destroyButton("login:button")
		exports.rp_library:destroyLabel("login:label")
		exports.rp_library:destroyLabel("login:logolabel")
		
	end
	if isElement(loginPanelData.passwordEditboxSecond) then
		exports.rp_library:destroyEditBox("password:editboxsecond")
		exports.rp_library:destroyEditBox("password:editboxverify")
	end

    for k, v in pairs(loginPanelData) do
        if isElement(v) then
            destroyElement(v)
        end
		end
    if mode == "login" then
        loginPanelData.usernameEditbox = exports.rp_library:createEditBox("username:editbox",sx / 2 - 170 * scaleValue,sy / 2 - 30 * scaleValue,340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,25,false,"Podaj login",true,15)--id, x, y, w, h, text, parent, caretHeight, textSize, maxLength, masked, placeHolder, padding, corners
        loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox",sx / 2 - 170 * scaleValue, sy / 2 + 45 * scaleValue, 340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,40,true,"Podaj hasło",true,20) --loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox", 50*scaleValue,290*scaleValue,200*scaleValue,50*scaleValue, "", loginPanelData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, true) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked

        loginPanelData.userIcon = DGS:dgsCreateImage(sx / 2 - 160 * scaleValue,sy / 2 - 10 * scaleValue,32 * scaleValue,32 * scaleValue,"files/user.png",false,nil,tocolor(255, 255, 255, 255))
        DGS:dgsSetPostGUI(loginPanelData.userIcon, true)
        DGS:dgsSetEnabled(loginPanelData.userIcon, false)

        loginPanelData.passwordIcon = DGS:dgsCreateImage(sx / 2 - 160 * scaleValue,sy / 2 + 63 * scaleValue,32 * scaleValue,32 * scaleValue,"files/password.png",false,nil,tocolor(255, 255, 255, 255))

        DGS:dgsSetPostGUI(loginPanelData.passwordIcon, true)
        DGS:dgsSetEnabled(loginPanelData.passwordIcon, false)
        loginPanelData.buttonLogin = exports.rp_library:createButtonRounded("login:button",sx / 2 - 170 * scaleValue,sy / 2 + 125 * scaleValue,340 * scaleValue,45 * scaleValue,"ZALOGUJ SIĘ",_,0.7*scaleValue,15)
        --loginPanelData.buttonLogin = DGS:dgsCreateButton( 50*scaleValue, 400*scaleValue, 200*scaleValue, 30*scaleValue, "Zaloguj się", false, loginPanelData.window, nil, 1, 1, loginPanelData.rectangleButton, loginPanelData.rectangleButtonHoover, loginPanelData.rectangleButtonHoover)
        DGS:dgsSetPostGUI(loginPanelData.buttonLogin, true)
        loginPanelData.eyePasswordShowed = DGS:dgsCreateImage(sx / 2 + 130 * scaleValue,sy / 2 + 60 * scaleValue,32 * scaleValue,32 * scaleValue,"files/eye.png",false,nil,tocolor(111, 97, 209, 255))
        DGS:dgsSetPostGUI(loginPanelData.eyePasswordShowed, true)

        addEventHandler("onDgsMouseClickUp", loginPanelData.buttonLogin, tryToLogin)

        loginPanelData.logoLabel = exports.rp_library:createLabel("login:logolabel", sx / 2 - 30 * scaleValue,sy / 2 - 150 * scaleValue,50 * scaleValue,50 * scaleValue,"#6f61d1Classic RolePlay",_,1 * scaleValue,"center","center",true,true,false)

        loginPanelData.infoLabel = exports.rp_library:createLabel("login:label",sx / 2 - 25 * scaleValue,sy / 2 + 172 * scaleValue,50 * scaleValue,50 * scaleValue,"Nie posiadasz konta? Kliknij #6f61d1tutaj \nKliknij spację aby wyłączyć muzykę.",_,0.6 * scaleValue,"center","center",true,true,false)
        loginPanelData.checkbox = exports.rp_library:createCheckBox( "checkbox:rememberme",sx / 2 + 40 * scaleValue,sy / 2 + 220 * scaleValue,"Zapamiętaj mnie",_,0.5 * scaleValue)
		DGS:dgsSetPostGUI(loginPanelData.infoLabel, true)
		DGS:dgsSetPostGUI(loginPanelData.logoLabel, true)
        showCursor(true)
        isDataSetTimer = setTimer(isDataSet, 50, 1)
    else
		loginPanelData.usernameEditbox = exports.rp_library:createEditBox("username:editbox",sx / 2 - 170 * scaleValue,sy / 2 - 30 * scaleValue,340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,25,false,"Podaj login",true,15)
        loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox",sx / 2 - 170 * scaleValue, sy / 2 + 45 * scaleValue, 340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,40,true,"Podaj hasło",true,20) --loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox", 50*scaleValue,290*scaleValue,200*scaleValue,50*scaleValue, "", loginPanelData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, true) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
        loginPanelData.passwordEditboxSecond = exports.rp_library:createEditBox("password:editboxsecond",sx / 2 - 170 * scaleValue, sy / 2 + 120 * scaleValue, 340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,40,true,"Potwierdz hasło",true,20) --loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox", 50*scaleValue,290*scaleValue,200*scaleValue,50*scaleValue, "", loginPanelData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, true) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked

        loginPanelData.userIcon = DGS:dgsCreateImage(sx / 2 - 160 * scaleValue,sy / 2 - 10 * scaleValue,32 * scaleValue,32 * scaleValue,"files/user.png",false,nil,tocolor(255, 255, 255, 255))
        DGS:dgsSetPostGUI(loginPanelData.userIcon, true)
        DGS:dgsSetEnabled(loginPanelData.userIcon, false)

        loginPanelData.passwordIcon = DGS:dgsCreateImage(sx / 2 - 160 * scaleValue,sy / 2 + 63 * scaleValue,32 * scaleValue,32 * scaleValue,"files/password.png",false,nil,tocolor(255, 255, 255, 255))

        DGS:dgsSetPostGUI(loginPanelData.passwordIcon, true)
        DGS:dgsSetEnabled(loginPanelData.passwordIcon, false)
        loginPanelData.buttonLogin = exports.rp_library:createButtonRounded("login:button",sx / 2 - 170 * scaleValue,sy / 2 + 280 * scaleValue,340 * scaleValue,45 * scaleValue,"ZAREJESTRUJ SIĘ",_,0.7*scaleValue,15)
        DGS:dgsSetPostGUI(loginPanelData.buttonLogin, true)

		loginPanelData.verifyCode = exports.rp_library:createEditBox("password:editboxverify",sx / 2 - 170 * scaleValue, sy / 2 + 195 * scaleValue, 340 * scaleValue,70 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,40,true,"Podaj kod weryfikacyjny",true,20) --loginPanelData.passwordEditbox = exports.rp_library:createEditBox("password:editbox", 50*scaleValue,290*scaleValue,200*scaleValue,50*scaleValue, "", loginPanelData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, true) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
        -- DGS:dgsSetPostGUI(loginPanelData.verifyCode, true)

        addEventHandler("onDgsMouseClickUp", loginPanelData.buttonLogin, tryToLogin)

        loginPanelData.logoLabel = exports.rp_library:createLabel("login:logolabel", sx / 2 - 30 * scaleValue,sy / 2 - 150 * scaleValue,50 * scaleValue,50 * scaleValue,"#6f61d1Classic RolePlay",_,1 * scaleValue,"center","center",true,true,false)

        loginPanelData.infoLabel = exports.rp_library:createLabel("login:label",sx / 2 - 25 * scaleValue,sy / 2 + 320 * scaleValue,50 * scaleValue,50 * scaleValue,"Posiadasz konto? Kliknij #6f61d1tutaj",_,0.6 * scaleValue,"center","center",true,true,false)
		DGS:dgsSetPostGUI(loginPanelData.infoLabel, true)
		DGS:dgsSetPostGUI(loginPanelData.logoLabel, true)
        showCursor(true)
    end
end




function passwordState(state)
    local masked = DGS:dgsEditGetMasked(loginPanelData.passwordEditbox)
    if masked then
        DGS:dgsEditSetMasked(loginPanelData.passwordEditbox, false)
        DGS:dgsImageSetImage(loginPanelData.eyePasswordShowed, "files/hide.png")
    else
        DGS:dgsEditSetMasked(loginPanelData.passwordEditbox, true)
        DGS:dgsImageSetImage(loginPanelData.eyePasswordShowed, "files/eye.png")
    end
end

function destroyLoginPanel()
    if isElement(loginPanelData.usernameEditbox) then
        removeEventHandler("onDgsMouseClickUp", loginPanelData.buttonLogin, tryToLogin)
        exports.rp_library:destroyEditBox("username:editbox")
        exports.rp_library:destroyEditBox("password:editbox")
        exports.rp_library:destroyCheckbox("checkbox:rememberme")
        exports.rp_library:destroyLabel("login:label")
        exports.rp_library:destroyLabel("login:logolabel")
    end
    -- exports.rp_library:destroyButton("login:button")

    if isElement(loginPanelData.passwordEditboxSecond) then
        exports.rp_library:destroyEditBox("password:editboxsecond")
    end
	unbindKey( "SPACE", "down", stopMusic )


    for k, v in pairs(loginPanelData) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    removeEventHandler("onClientClick", root, loginClick)
end




function loginClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button ~= "left" or state ~= "down" then return end

    if loginState == "login" then
        if isMouseInPosition(sx / 2 + 130 * scaleValue, sy / 2 + 60 * scaleValue, 32 * scaleValue, 32 * scaleValue) then
            passwordState()
        elseif isMouseInPosition(sx / 2 - 140 * scaleValue, sy / 2 + 180 * scaleValue, 300 * scaleValue, 30 * scaleValue) then
			dxDrawRectangle (sx / 2 - 25 * scaleValue, sy / 2 + 172 * scaleValue, 50 * scaleValue, 50 * scaleValue, tocolor ( 0, 0, 0, 255), true ) -- Create our black transparent MOTD background Rectangle.
            loginState = "register"
            showPanel("register")
        end
    elseif loginState == "register" then
        if isMouseInPosition(sx / 2 - 140 * scaleValue, sy / 2 + 320 * scaleValue, 300 * scaleValue, 30 * scaleValue) then
            loginState = "login"
            showPanel("login")
        end
    end
end

addEventHandler("onClientClick", root, loginClick)


local disabledButton = false
function setDisabledButton()
    if disabledButton then
        return
    end
    DGS:dgsSetEnabled(loginPanelData.buttonLogin, false)
    setTimer(
        function()
            disabledButton = false
            if isElement(loginPanelData.buttonLogin) then
                DGS:dgsSetEnabled(loginPanelData.buttonLogin, true)
            end
        end,
        3000,
        1
    )
end








showChat(false)
addEventHandler("onClientResourceStart",getRootElement(),function(startedRes)
        if getResourceName(startedRes) == "rp_login" then
            for k, v in pairs(components) do
                setPlayerHudComponentVisible(v, false)
            end
			math.randomseed(os.time())
			music = playSound("files/"..math.random(1,3)..".mp3", true)
			setSoundVolume( music, 0.1 )
			background = DGS:dgsCreateImage(0, 0, sx, sy,"files/bg.png",false,nil,tocolor(255,255,255,255))
			DGS:dgsSetPostGUI(background, false)
			DGS:dgsSetEnabled(background, false)
            showPanel("login")
        end
    end
)



-- destroyLoginPanel()


