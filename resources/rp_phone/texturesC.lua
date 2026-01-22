phone = {}
phone.startX, phone.startY = exports.rp_scale:getScreenStartPositionFromBox(369 * scaleValue, 507 * scaleValue, offsetX, offsetY, "right", "bottom")
phone.homeButtonTexture = dxCreateTexture("files/home.png")
phone.backGroundTexture = dxCreateTexture("files/bg1.jpg", "argb", true, "wrap")
phone.rejectCallTexture = dxCreateTexture("files/rejectcall.png")
phone.answerCallTexture = dxCreateTexture("files/answer.png")
phone.cellphoneTexture = dxCreateTexture("files/cellphone.png", "argb", true, "wrap")
phone.batteryTexture = dxCreateTexture("files/battery.png", "argb", true, "wrap")
phone.talkingTime = 0
phone.showTime = 0
phone.hiding = false
phone.currentApp = "home"
phone.ringtoneSetting = false
phone.data = {}

phone.apps = {
    {name = "Ustawienia", id = "settings"},
    -- {name = "Portfel", id = "payments"},
    {name = "Notatki", id = "notes"},
    {name = "Kontakty", id = "messages"},
    -- {name = "Aparat", id = "camera"},
    -- {name = "Zdjęcia", id = "photos"},
    -- {name = "Telegram", id = "telegram"},
	-- {name = "FaceTime", id = "facetime"},
}


function assignCallbacksToSettings()
    local callbacks = {
        ["Zastrzeż numer"] = {
            max = nil,
            callback = function(state)
                -- triggerServerEvent("onPlayerChangeSettingPhone", localPlayer, "withold", state)
            end
        },
        ["Wycisz telefon"] = {
            max = nil,
            callback = function(state)
                -- triggerServerEvent("onPlayerChangeSettingPhone", localPlayer, "mute", state)
            end
        },
        ["Dzwonek"] = {
            max = 3,
            callback = function(state)
                if isElement(phone.ringtoneSetting) then
                    destroyElement(phone.ringtoneSetting)
                end
                if isTimer(ringTimer) then
                    killTimer(ringTimer)
                end
                ringTimer = setTimer(function()
                    if isElement(phone.ringtoneSetting) then
                        destroyElement(phone.ringtoneSetting)
                    end
                end, 10000, 1)
                phone.ringtoneSetting = playSound("files/ringtones/" .. state .. ".mp3")
                setSoundVolume(phone.ringtoneSetting, 0.2)
            end
        },
        ["Tło telefonu"] = {
            max = 4,
            callback = function(state)
                if isElement(phone.backGroundTexture) then
                    destroyElement(phone.backGroundTexture)
                end
                phone.backGroundTexture = dxCreateTexture("files/bg"..state..".jpg", "argb", true, "wrap")
            end
        }
    }
    
    for i, setting in ipairs(phone.settings) do
        if callbacks[setting.name] then
            setting.onChange = callbacks[setting.name].callback
            setting.max = callbacks[setting.name].max -- Przypisz max
        end
    end
end

phone.contacts = {

    {
        name = "Nazwa goscia",
        phoneNumber = 492192321,
		messages = {}, -- to bedzie dzialac tak, messages [numer] = {messages}
    },

}



function loadPhoneData(data)
    local phoneData = data
    
    if not phoneData then
        phoneData = {
            settings = {
                {name = "Zastrzeż numer", state = false},
                {name = "Wycisz telefon", state = false},
                {name = "Dzwonek", state = 1, max = 3},
                {name = "Tło telefonu", state = 1, max = 4}
            },
            contacts = {},
            messages = {},
            number = nil
        }
    end

    phone.settings = phoneData.settings or {}
    phone.contacts = phoneData.contacts or {}
    phone.messages = phoneData.messages or {}
    phone.number = phoneData.number

    assignCallbacksToSettings()
    
    iprint("Załadowano dane:", phone.settings, phone.contacts, phone.messages, phone.number)
end

function getNameNumber(number)
	local returnText = number
    for k, contact in pairs(phone.contacts) do
        if tonumber(contact.phoneNumber) == tonumber(number) then
			returnText = contact.name
			break
        end
    end
    return returnText
end
function savePhoneData()
    local phoneData = {
        settings = phone.settings,
        contacts = phone.contacts,
        messages = phone.messages,
        number = phone.number, -- Zapisz też numer
    }
    
    -- iprint("Zapisywane dane:", phoneData)
	-- iprint(phoneData.settings)
    triggerServerEvent("onPlayerChangePhoneSettings", localPlayer, phoneData)
end

function getMessagesForNumber(phoneNumber)
    for k, v in ipairs(phone.contacts) do
        if v.phoneNumber == phoneNumber then
            return v.messages or {}
        end
    end
    return {}
end

function addMessageToContact(phoneNumber, messageData)
    for k, v in ipairs(phone.contacts) do
        if v.phoneNumber == phoneNumber then
            if not v.messages then
                v.messages = {}
            end
            table.insert(v.messages, messageData)
            return true
        end
    end
    return false
end