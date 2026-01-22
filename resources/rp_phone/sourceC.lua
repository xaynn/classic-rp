scaleValue = exports.rp_scale:returnScaleValue()
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
local font = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof") or "default" -- fallback to default
local font2 = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof") or "default" -- fallback to default

local phoneFunc = {}
local iconSize = 64 * scaleValue
local padding = 20 * scaleValue
local marginX = 5 * scaleValue
local marginY = 30 * scaleValue
local labelHeight = 15 * scaleValue
local columns = 3
local globAppsX, globAppsY
local ebElements = {
    createElement("dxDrawEditbox"),
    createElement("dxDrawEditbox"),
	createElement("dxDrawEditbox"),
	createElement("dxDrawEditbox"),
	createElement("dxDrawEditbox")
}
local contactLastName, contactLastNumber
function phoneFunc.render()
    local now = getTickCount()
    local elapsedTime = now - phone.showTime
    local duration = phone.endTime - phone.showTime
    local progress = elapsedTime / duration
    
    progress = math.min(progress, 1)
    
    local x, y
    
    if phone.hiding then
        local x1, y1 = phone.startX, phone.startY
        local x2, y2 = phone.startX, phone.startY + 600 * scaleValue
        x, y = interpolateBetween( 
            x1, y1, 0,
            x2, y2, 0, 
            progress, "Linear"
        )
    else
        local x1, y1 = phone.startX, phone.startY + 600 * scaleValue
        local x2, y2 = phone.startX, phone.startY
        x, y = interpolateBetween( 
            x1, y1, 0,
            x2, y2, 0, 
            progress, "Linear"
        )
    end
    
    globAppsX = x
    globAppsY = y
    
    dxDrawImage(x, y, 369 * scaleValue, 507 * scaleValue, phone.cellphoneTexture, 0, 0, 0, tocolor(255,255,255,255), true)
    dxDrawImage(x + 65 * scaleValue, y + 10 * scaleValue, 240 * scaleValue, 470 * scaleValue, phone.backGroundTexture)
    
    dxDrawImage(x + 260 * scaleValue, y + 20 * scaleValue, 16 * scaleValue, 8 * scaleValue, phone.batteryTexture)
    
    local timehour, timeminute = getTime()
    timeminute = timeminute + 2
    dxDrawText(timehour..":"..timeminute, x + 81 * scaleValue, y + 16 * scaleValue, x, y, tocolor(0, 0, 0,255), 1, font, "left", "top")
    dxDrawText(timehour..":"..timeminute, x + 80 * scaleValue, y + 15 * scaleValue, x, y, tocolor(255,255,255,255), 1, font, "left", "top")

    dxDrawImage(x + 130 * scaleValue, y + 460 * scaleValue, 116 * scaleValue, 8 * scaleValue, phone.homeButtonTexture)
    if isMouseInPosition(x + 130 * scaleValue, y + 460 * scaleValue, 116 * scaleValue, 8 * scaleValue) then
        dxDrawImage(x + 130 * scaleValue, y + 460 * scaleValue, 116 * scaleValue, 8 * scaleValue, phone.homeButtonTexture)
    end
    
    -- rysowanie aplikacji
    if phone.currentApp == "home" then
        for k, v in ipairs(phone.apps) do
            local row = math.floor((k - 1) / columns)
            local col = (k - 1) % columns
            local appX = x + marginX + col * (iconSize + padding) 
            local appY = y + marginY + row * (iconSize + padding)

            local texturePath = "files/" .. v.id .. ".png"
            local colorApps = tocolor(255,255,255,255)
            
            if isMouseInPosition(appX + 68 * scaleValue, appY + 20 * scaleValue, iconSize, iconSize) then
                colorApps = tocolor(200, 200, 200, 255)
            end
            
            dxDrawImage(appX + 68 * scaleValue, appY + 20 * scaleValue, iconSize, iconSize, texturePath, 0, 0, 0, colorApps)
            
            local textX = appX + 100 * scaleValue
            local textY = appY + 97 * scaleValue
            
            dxDrawText(v.name, textX, textY, textX, textY, tocolor(0, 0, 0,255), 1, font, "center", "center")
            dxDrawText(v.name, textX, textY - 2 * scaleValue, textX, textY - 2 * scaleValue, tocolor(255,255,255,255), 1, font, "center", "center")
        end
        
    elseif phone.currentApp == "settings" then
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 50 * scaleValue, 210 * scaleValue, 110 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))

        local startY = y + 55 * scaleValue
        local startX = x + 85 * scaleValue
        local offset = 0
        dxDrawText("Numer telefonu: "..phone.data.number, startX, startY+80*scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")

        for k, v in ipairs(phone.settings) do
            local txtWidth = dxGetTextWidth(v.name .. ":", 1, font, false)
            local rectX = startX + txtWidth * scaleValue + 10 * scaleValue
            local rectY = startY + offset
            local textY = rectY + 8 * scaleValue
            
            dxDrawText(v.name .. ":", startX, rectY, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
            dxDrawRoundedRectangle(rectX, rectY, 50 * scaleValue, 15 * scaleValue, 5 * scaleValue, tocolor(40, 40, 40, 255))
            
            local txt, color
            
            if type(v.state) == "number" then
                txt = tostring(v.state)
                if v.name == "Dzwonek" then
                    color = tocolor(100, 150, 255, 255)  -- Niebieski dla dzwonka
                else
                    color = tocolor(255, 200, 100, 255)  -- Pomarańczowy dla głośności
                end
            else
                txt = v.state and "TAK" or "NIE"
                color = v.state and tocolor(100, 255, 100, 255) or tocolor(255, 100, 100, 255)
            end
            
            dxDrawText(txt, rectX, textY, rectX + 50 * scaleValue, textY, color, 1, font, "center", "center")
            
            offset = offset + 20 * scaleValue
        end
        
    elseif phone.currentApp == "messages" then
        phone.contactScroll = phone.contactScroll or 0
        local maxVisibleContacts = 7 
        
        dxDrawText("Moje kontakty", x + 80 * scaleValue, y + 40 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font2, "left", "top")
        
        if isMouseInPosition(x + 260 * scaleValue, y + 40 * scaleValue, 20*scaleValue, 20*scaleValue) then
            dxDrawText("+", x + 260 * scaleValue, y + 40 * scaleValue, x, y, tocolor(59, 123, 227, 255), 1, font2, "left", "top")
        else
            dxDrawText("+", x + 260 * scaleValue, y + 40 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font2, "left", "top")
        end
        
        local maxScroll = math.max(0, #phone.contacts - maxVisibleContacts)
        if phone.contactScroll > maxScroll then
            phone.contactScroll = maxScroll
        end
        
        local offset = 0
        for i = phone.contactScroll + 1, math.min(phone.contactScroll + maxVisibleContacts, #phone.contacts) do
            local v = phone.contacts[i]
            local contactY = y + 100 + offset * scaleValue
            
            dxDrawRoundedRectangle(x + 80 * scaleValue, contactY, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
            
            dxDrawText(v.name.." ("..v.phoneNumber..")", 
                x + 85 * scaleValue, contactY + 5 * scaleValue, 
                x + 270 * scaleValue, contactY + 25 * scaleValue, 
                tocolor(255, 255, 255, 255), 1, font, "left", "center", true)
            
            if isMouseInPosition(x + 80 * scaleValue, contactY, 200 * scaleValue, 30 * scaleValue) then
                dxDrawRoundedRectangle(x + 80 * scaleValue, contactY, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
                dxDrawText(v.name.." ("..v.phoneNumber..")", 
                    x + 85 * scaleValue, contactY + 5 * scaleValue, 
                    x + 270 * scaleValue, contactY + 25 * scaleValue, 
                    tocolor(255, 255, 255, 255), 1, font, "left", "center", true)
            end
            
            offset = offset + 40
        end
        
        if #phone.contacts > maxVisibleContacts then
            local scrollAreaHeight = maxVisibleContacts * 40 * scaleValue
            local scrollBarHeight = (maxVisibleContacts / #phone.contacts) * scrollAreaHeight
            local scrollPosition = (phone.contactScroll / maxScroll) * (scrollAreaHeight - scrollBarHeight)
            
            dxDrawRectangle(x + 285 * scaleValue, y + 100 * scaleValue, 3 * scaleValue, scrollAreaHeight, tocolor(60, 60, 60, 200))
            
            dxDrawRectangle(x + 285 * scaleValue, y + 100 * scaleValue + scrollPosition, 3 * scaleValue, scrollBarHeight, tocolor(150, 150, 150, 200))
            
            local arrowColorUp = (phone.contactScroll > 0) and tocolor(59, 123, 227, 255) or tocolor(100, 100, 100, 150)
            local arrowColorDown = (phone.contactScroll < maxScroll) and tocolor(59, 123, 227, 255) or tocolor(100, 100, 100, 150)
            
            dxDrawText("▲", x + 273 * scaleValue, y + 75 * scaleValue, x + 300 * scaleValue, y + 95 * scaleValue, arrowColorUp, 1, font, "center", "center")
            
            dxDrawText("▼", x + 273 * scaleValue, y + 100 * scaleValue + scrollAreaHeight + 5 * scaleValue, x + 300 * scaleValue, y + 100 * scaleValue + scrollAreaHeight + 25 * scaleValue, arrowColorDown, 1, font, "center", "center")
        end
        
        dxDrawText("Kontakty: " .. #phone.contacts, x + 80 * scaleValue, y + 400 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        
    elseif phone.currentApp == "CallOrTextContact" then
        -- dwa editboxy, nazwa, numer, przyciski Zadzwon, wyslij wiadomosc, usun kontakt, zapisz kontakt, anuluj
        dxDrawText("Nazwa", x + 80 * scaleValue, y + 85 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        dxDrawEditBox(contactLastName, x+80*scaleValue, y+100*scaleValue, 200*scaleValue, 25*scaleValue, ebElements[3], tocolor(255, 255, 255, 255), 20, false, font, true)
        dxDrawText("Numer telefonu", x + 80 * scaleValue, y + 140 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        dxDrawEditBox(contactLastNumber, x+80*scaleValue, y+160*scaleValue, 200*scaleValue, 25*scaleValue, ebElements[4], tocolor(255, 255, 255, 255), 20, false, font, true)
        
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 280 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 320 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 240 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))

        dxDrawText("Zadzwoń",x + 180 * scaleValue, y + 295 * scaleValue, x + 180 * scaleValue, y + 295 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        dxDrawText("Napisz wiadomość",x + 180 * scaleValue, y + 335 * scaleValue, x + 180 * scaleValue, y + 335 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        dxDrawText("Zapisz",x + 180 * scaleValue, y + 375 * scaleValue, x + 180 * scaleValue, y + 375 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        dxDrawText("Anuluj",x + 180 * scaleValue, y + 415 * scaleValue, x + 180 * scaleValue, y + 415 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        dxDrawText("Usuń kontakt",x + 180 * scaleValue, y + 255 * scaleValue, x + 180 * scaleValue, y + 255 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        
        if isMouseInPosition(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        elseif isMouseInPosition(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        elseif isMouseInPosition(x + 80 * scaleValue, y + 280 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 280 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        elseif isMouseInPosition(x + 80 * scaleValue, y + 320 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 320 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        elseif isMouseInPosition(x + 80 * scaleValue, y + 240 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 240 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        end
        
    elseif phone.currentApp == "calling" then
        dxDrawText("Dzwonisz do: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 87 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(0, 0, 0, 255), 1, font, "center", "center", false, true)
        dxDrawText("Dzwonisz do: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 85 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, true)
        dxDrawImage(x + 150 * scaleValue, y + 300 * scaleValue, 64*scaleValue, 64*scaleValue, phone.rejectCallTexture, 0, 0, 0, tocolor(255,255,255,255))
        
    elseif phone.currentApp == "answering" then
        dxDrawText("Dzwoni do ciebie: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 87 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(0, 0, 0, 255), 1, font, "center", "center", false, true)
        dxDrawText("Dzwoni do ciebie: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 85 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, true)
        dxDrawImage(x + 95 * scaleValue, y + 300 * scaleValue, 64*scaleValue, 64*scaleValue, phone.rejectCallTexture, 0, 0, 0, tocolor(255,255,255,255))
        dxDrawImage(x + 210 * scaleValue, y + 300 * scaleValue, 64*scaleValue, 64*scaleValue, phone.answerCallTexture, 0, 0, 0, tocolor(255,255,255,255))
        
    elseif phone.currentApp == "talking" then
        dxDrawText("Rozmawiasz z: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 87 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(0, 0, 0, 255), 1, font, "center", "center", false, true)
        dxDrawText("Rozmawiasz z: "..getNameNumber(phone.callingTo), x + 80 * scaleValue, y + 85 * scaleValue, x + 280 * scaleValue, y + 150 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, true)
        dxDrawText(formatCallTime(), x + 180 * scaleValue, y + 130 * scaleValue,  x + 180 * scaleValue, y + 160 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center")
        dxDrawImage(x + 150 * scaleValue, y + 300 * scaleValue, 64*scaleValue, 64*scaleValue, phone.rejectCallTexture, 0, 0, 0, tocolor(255,255,255,255))
elseif phone.currentApp == "newMessage" then
    phone.messageScroll = phone.messageScroll or 0
    
    dxDrawText(getNameNumber(phone.messageRecipient), x + 80 * scaleValue, y + 40 * scaleValue, 50*scaleValue, y, tocolor(255, 255, 255, 255), 1, font, "left", "top", false, true)
    
    dxDrawText("Wiadomość:", x + 80 * scaleValue, y + 345 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
    dxDrawEditBox("", x + 80 * scaleValue, y + 370 * scaleValue, 200 * scaleValue, 25 * scaleValue, ebElements[5], tocolor(255, 255, 255, 255), 30, false, font, true)
    
    dxDrawRoundedRectangle(x + 80 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
    dxDrawRoundedRectangle(x + 185 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
    
    dxDrawText("Wyślij", x + 127.5 * scaleValue, y + 395 * scaleValue, x + 127 * scaleValue, y + 455 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center")
    dxDrawText("Anuluj", x + 232.5 * scaleValue, y + 395 * scaleValue, x + 232 * scaleValue, y + 455 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center")
    
    if isMouseInPosition(x + 80 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        dxDrawText("Wyślij", x + 127.5 * scaleValue, y + 395 * scaleValue, x + 127 * scaleValue, y + 455 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center")
    elseif isMouseInPosition(x + 185 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
        dxDrawRoundedRectangle(x + 185 * scaleValue, y + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        dxDrawText("Anuluj", x + 232.5 * scaleValue, y + 395 * scaleValue, x + 232 * scaleValue, y + 455 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center")
    end
    
    local contactMessages = getMessagesForNumber(phone.messageRecipient)
    if contactMessages and #contactMessages > 0 then
        dxDrawText("Historia wiadomości:", x + 80 * scaleValue, y + 80 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        
        local messageHeights = {}
        local totalHeight = 0
        local maxMessageWidth = 130 * scaleValue 
        
        for i, msg in ipairs(contactMessages) do
            local textWidth, textHeight = dxGetTextSize(msg.text, maxMessageWidth - 10 * scaleValue, 0.8, 0.8, font, true)
            local messageHeight = math.max(25 * scaleValue, textHeight + 15 * scaleValue) 
            messageHeights[i] = messageHeight
            totalHeight = totalHeight + messageHeight
        end
        
        local availableHeight = 220 * scaleValue  
        local maxScroll = math.max(0, totalHeight - availableHeight)
        if phone.messageScroll > maxScroll then
            phone.messageScroll = maxScroll
        end
        
        dxSetRenderTarget()
        dxSetBlendMode("modulate_add")
        
        local messagesStartY = y + 110 * scaleValue
        local messagesEndY = messagesStartY + availableHeight
        
        local currentY = messagesStartY - phone.messageScroll
        local visibleMessages = 0
        
        for i = 1, #contactMessages do
            local msg = contactMessages[i]
            local msgHeight = messageHeights[i]
            
            if currentY + msgHeight > messagesStartY and currentY < messagesEndY then
                local msgY = math.max(messagesStartY, currentY)  
                local clippedMsgHeight = msgHeight
                
                if currentY < messagesStartY then
                    clippedMsgHeight = clippedMsgHeight - (messagesStartY - currentY)
                end
                
                if currentY + msgHeight > messagesEndY then
                    clippedMsgHeight = messagesEndY - msgY
                end
                
                if clippedMsgHeight > 5 * scaleValue then  
                    if msg.sender == phone.number then
                        dxDrawRoundedRectangle(x + 150 * scaleValue, msgY, maxMessageWidth, clippedMsgHeight, 5 * scaleValue, tocolor(59, 123, 227, 200))
                        dxDrawText(msg.text, 
                            x + 155 * scaleValue, msgY + 5 * scaleValue, 
                            x + 150 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + clippedMsgHeight - 5 * scaleValue, 
                            tocolor(255, 255, 255, 255), 0.8, font, "left", "top", true, true)
                        dxDrawText("Ja", 
                            x + 150 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + 5 * scaleValue, 
                            x + 150 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + clippedMsgHeight - 5 * scaleValue, 
                            tocolor(200, 200, 200, 255), 0.6, font, "right", "top")
                    else
                        dxDrawRoundedRectangle(x + 80 * scaleValue, msgY, maxMessageWidth, clippedMsgHeight, 5 * scaleValue, tocolor(60, 60, 60, 200))
                        dxDrawText(msg.text, 
                            x + 85 * scaleValue, msgY + 5 * scaleValue, 
                            x + 80 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + clippedMsgHeight - 5 * scaleValue, 
                            tocolor(255, 255, 255, 255), 0.8, font, "left", "top", true, true)
                        dxDrawText(getNameNumber(msg.sender), 
                            x + 80 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + 5 * scaleValue, 
                            x + 80 * scaleValue + maxMessageWidth - 5 * scaleValue, msgY + clippedMsgHeight - 5 * scaleValue, 
                            tocolor(200, 200, 200, 255), 0.6, font, "right", "top")
                    end
                end
                
                visibleMessages = visibleMessages + 1
            end
            
            currentY = currentY + msgHeight
            
            if currentY > messagesEndY + 100 * scaleValue then
                break
            end
        end
        
        dxSetBlendMode("blend")
        
        if totalHeight > availableHeight then
            local scrollBarHeight = (availableHeight / totalHeight) * availableHeight
            local scrollPosition = (phone.messageScroll / maxScroll) * (availableHeight - scrollBarHeight)
            
            dxDrawRectangle(x + 285 * scaleValue, messagesStartY, 3 * scaleValue, availableHeight, tocolor(60, 60, 60, 200))
            
            dxDrawRectangle(x + 285 * scaleValue, messagesStartY + scrollPosition, 3 * scaleValue, scrollBarHeight, tocolor(150, 150, 150, 200))
            
            local arrowColorUp = (phone.messageScroll > 0) and tocolor(59, 123, 227, 255) or tocolor(100, 100, 100, 150)
            local arrowColorDown = (phone.messageScroll < maxScroll) and tocolor(59, 123, 227, 255) or tocolor(100, 100, 100, 150)
            
            dxDrawText("▲", x + 275 * scaleValue, y + 85 * scaleValue, x + 300 * scaleValue, y + 105 * scaleValue, arrowColorUp, 1, font, "center", "center")
            
            dxDrawText("▼", x + 275 * scaleValue, messagesEndY + 5 * scaleValue, x + 300 * scaleValue, messagesEndY + 25 * scaleValue, arrowColorDown, 1, font, "center", "center")
        end
    end
	
    elseif phone.currentApp == "addingContact" then
        dxDrawText("Dodaj kontakt", x + 80 * scaleValue, y + 40 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font2, "left", "top")
        dxDrawText("Nazwa", x + 80 * scaleValue, y + 85 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        dxDrawEditBox("", x+80*scaleValue, y+100*scaleValue, 200*scaleValue, 25*scaleValue, ebElements[1], tocolor(255, 255, 255, 255), 20, false, font, true)
        dxDrawText("Numer telefonu", x + 80 * scaleValue, y + 140 * scaleValue, x, y, tocolor(255, 255, 255, 255), 1, font, "left", "top")
        dxDrawEditBox("", x+80*scaleValue, y+160*scaleValue, 200*scaleValue, 25*scaleValue, ebElements[2], tocolor(255, 255, 255, 255), 20, false, font, true)
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawRoundedRectangle(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(25, 25, 25, 255))
        dxDrawText("Dodaj",x + 180 * scaleValue, y + 375 * scaleValue, x + 180 * scaleValue, y + 375 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        dxDrawText("Anuluj",x + 180 * scaleValue, y + 415 * scaleValue, x + 180 * scaleValue, y + 415 * scaleValue, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true)
        
        if isMouseInPosition(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        elseif isMouseInPosition(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
            dxDrawRoundedRectangle(x + 80 * scaleValue, y + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue, tocolor(50, 50, 50, 255))
        end
    end
    
    if progress >= 1 and phone.hiding then
        removeEventHandler("onClientRender", getRootElement(), phoneFunc.render)
        removeEventHandler("onClientClick", getRootElement(), phoneFunc.click)
		removeEventHandler("onClientKey", root, handlePhoneScroll)
        phone.hiding = false
    end
end

function handlePhoneScroll(key, press)
    if not phone.state then return end
    
    if phone.currentApp == "messages" then
        local maxVisibleContacts = 7
        local maxScroll = math.max(0, #phone.contacts - maxVisibleContacts)
        
        if key == "mouse_wheel_down" and press and phone.contactScroll < maxScroll then
            phone.contactScroll = phone.contactScroll + 1
            return
        elseif key == "mouse_wheel_up" and press and phone.contactScroll > 0 then
            phone.contactScroll = phone.contactScroll - 1
            return
        end
    
elseif phone.currentApp == "newMessage" then
    local contactMessages = getMessagesForNumber(phone.messageRecipient) or {}
    local availableHeight = 220 * scaleValue
    
    local totalHeight = 0
    local maxMessageWidth = 130 * scaleValue
    
    for i, msg in ipairs(contactMessages) do
        local textWidth, textHeight = dxGetTextSize(msg.text, maxMessageWidth - 10 * scaleValue, 0.8, 0.8, font, true)
        totalHeight = totalHeight + math.max(25 * scaleValue, textHeight + 15 * scaleValue)
    end
    
    local maxScroll = math.max(0, totalHeight - availableHeight)
    local scrollStep = 30 * scaleValue  -- Krok scrollowania
    
    if key == "mouse_wheel_down" and press and phone.messageScroll < maxScroll then
        phone.messageScroll = math.min(maxScroll, phone.messageScroll + scrollStep)
        return
    elseif key == "mouse_wheel_up" and press and phone.messageScroll > 0 then
        phone.messageScroll = math.max(0, phone.messageScroll - scrollStep)
        return
    end
	end
end

function phoneFunc.enable(data)
    if phone.hiding or getTickCount() - (phone.lastToggle or 0) < 1000 then
        return false 
    end   
		phone.data = data
		loadPhoneData(data)
	    phone.lastToggle = getTickCount()

    phone.state = not phone.state

    if phone.state then
        phone.showTime = getTickCount()
        phone.endTime = phone.showTime + 1100
        addEventHandler("onClientRender", getRootElement(), phoneFunc.render)
		addEventHandler ( "onClientClick", getRootElement(), phoneFunc.click)
		addEventHandler("onClientKey", root, handlePhoneScroll)

    elseif not phone.state then
        phone.showTime = getTickCount()
        phone.endTime = phone.showTime + 1100
        phone.hiding = true
    end
end
addEvent ( "onPlayerUsePhone", true )
addEventHandler ( "onPlayerUsePhone", root, phoneFunc.enable )
function phoneFunc.click(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if not phone.state or button ~= "left" or state ~= "up" then
        return
    end
    
    -- Home button
    if isMouseInPosition(globAppsX + 130 * scaleValue, globAppsY + 460 * scaleValue, 116 * scaleValue, 8 * scaleValue) then
        phone.currentApp = "home"
        return
    end
    
    if phone.currentApp == "home" then
        for k, v in ipairs(phone.apps) do
            local row = math.floor((k - 1) / columns)
            local col = (k - 1) % columns
            local appX = globAppsX + marginX + col * (iconSize + padding)
            local appY = globAppsY + marginY + row * (iconSize + padding)
            if isMouseInPosition(appX + 68 * scaleValue, appY + 20 * scaleValue, iconSize, iconSize) then
                phone.currentApp = v.id
                return
            end
        end
    end
    
if phone.currentApp == "newMessage" then
    local maxVisibleMessages = 8
    local contactMessages = getMessagesForNumber(phone.messageRecipient) or {}
    local maxScroll = math.max(0, #contactMessages - maxVisibleMessages)
    
    if isMouseInPosition(globAppsX + 285 * scaleValue, globAppsY + 85 * scaleValue, 15 * scaleValue, 20 * scaleValue) and phone.messageScroll > 0 then
        phone.messageScroll = phone.messageScroll - 1
        return
    end
    
    local scrollAreaHeight = maxVisibleMessages * 25 * scaleValue
    if isMouseInPosition(globAppsX + 285 * scaleValue, globAppsY + 110 * scaleValue + scrollAreaHeight + 5 * scaleValue, 15 * scaleValue, 20 * scaleValue) and phone.messageScroll < maxScroll then
        phone.messageScroll = phone.messageScroll + 1
        return
    end
    
    if isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue) then
        local messageText = getEditBoxText(ebElements[5])
        if messageText and messageText:gsub(" ", "") ~= "" then
            local contactExists = false
            for k, v in ipairs(phone.contacts) do
                if v.phoneNumber == phone.messageRecipient then
                    contactExists = true
                    break
                end
            end
            
            if not contactExists then
                table.insert(phone.contacts, {
                    name = phone.messageRecipient,
                    phoneNumber = phone.messageRecipient,
                    messages = {}
                })
            end
            
            local messageData = {
                text = messageText,
                sender = phone.number,
                receiver = phone.messageRecipient,
                timestamp = getRealTime().timestamp or getTickCount()
            }
            
            
            triggerServerEvent("onPlayerSendSMS", localPlayer, phone.messageRecipient, messageText)
            
            setEditBoxText(ebElements[5], "")
        else
            exports.rp_library:createBox("Wprowadź treść wiadomości!")
        end
        return
        
    elseif isMouseInPosition(globAppsX + 185 * scaleValue, globAppsY + 410 * scaleValue, 95 * scaleValue, 30 * scaleValue) then
        setEditBoxText(ebElements[5], "")
        phone.currentApp = "messages"
        return
    end
end
  if phone.currentApp == "messages" then
    phone.contactScroll = phone.contactScroll or 0
    local maxVisibleContacts = 7
    local maxScroll = math.max(0, #phone.contacts - maxVisibleContacts)
    
    if isMouseInPosition(globAppsX + 285 * scaleValue, globAppsY + 75 * scaleValue, 15 * scaleValue, 20 * scaleValue) and phone.contactScroll > 0 then
        phone.contactScroll = phone.contactScroll - 1
        return
    end
    
    local scrollAreaHeight = maxVisibleContacts * 40 * scaleValue
    if isMouseInPosition(globAppsX + 285 * scaleValue, globAppsY + 100 * scaleValue + scrollAreaHeight + 5 * scaleValue, 15 * scaleValue, 20 * scaleValue) and phone.contactScroll < maxScroll then
        phone.contactScroll = phone.contactScroll + 1
        return
    end
    
    if isMouseInPosition(globAppsX + 260 * scaleValue, globAppsY + 40 * scaleValue, 20 * scaleValue, 20 * scaleValue) then
        phone.currentApp = "addingContact"
        return
    else
        local startY = globAppsY + 100 * scaleValue
        local offset = 0
        
        for i = phone.contactScroll + 1, math.min(phone.contactScroll + maxVisibleContacts, #phone.contacts) do
            local v = phone.contacts[i]
            local contactY = startY + offset
            
            if isMouseInPosition(globAppsX + 80 * scaleValue, contactY, 200 * scaleValue, 30 * scaleValue) then
                phone.currentApp = "CallOrTextContact"
                contactLastName, contactLastNumber = v.name, v.phoneNumber
                setEditBoxText(ebElements[3], contactLastName)
                setEditBoxText(ebElements[4], contactLastNumber)
                return
            end
            
            offset = offset + 40 * scaleValue 
        end
    end
end
    
if phone.currentApp == "CallOrTextContact" then
    if isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 280 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
        local phoneNumber = getEditBoxText(ebElements[4])
        if phoneNumber and phoneNumber:gsub(" ", "") ~= "" then
            triggerServerEvent("onPlayerPhoneCall", localPlayer, phoneNumber)
        else
            exports.rp_library:createBox("Wprowadź poprawny numer telefonu!")
        end
        return
        
    elseif isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 320 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
        local phoneNumber = getEditBoxText(ebElements[4])
        if phoneNumber and phoneNumber:gsub(" ", "") ~= "" then
            phone.messageRecipient = phoneNumber
            phone.currentApp = "newMessage"
        else
            exports.rp_library:createBox("Wprowadź poprawny numer telefonu!")
        end
        return
        
    elseif isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
        local name = getEditBoxText(ebElements[3])
        local phoneNumber = getEditBoxText(ebElements[4])
        
        if name and name:gsub(" ", "") ~= "" and phoneNumber and phoneNumber:gsub(" ", "") ~= "" then
            for k, v in ipairs(phone.contacts) do
                if v.name == contactLastName and v.phoneNumber == contactLastNumber then
                    v.name = name
                    v.phoneNumber = phoneNumber
                    break
                end
            end
            phone.currentApp = "messages"
        else
            exports.rp_library:createBox("Wprowadź poprawną nazwę i numer telefonu!")
        end
        return
        
    elseif isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
        phone.currentApp = "messages"
        return
        
    elseif isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 240 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
        for k, v in ipairs(phone.contacts) do
            if v.name == contactLastName and v.phoneNumber == contactLastNumber then
                table.remove(phone.contacts, k)
                savePhoneData()
                exports.rp_library:createBox("Kontakt został usunięty!")
                phone.currentApp = "messages"
                return
            end
        end
    end
end
	
    if phone.currentApp == "addingContact" then
        if isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 360 * scaleValue, 200 * scaleValue, 30 * scaleValue) then
            local name = getEditBoxText(ebElements[1])
            local phoneNumber = getEditBoxText(ebElements[2])
            
            if name and name:gsub(" ", "") ~= "" and phoneNumber and phoneNumber:gsub(" ", "") ~= "" then
                -- triggerServerEvent("onPlayerPhoneAddContact", localPlayer, name, phoneNumber)
                phone.currentApp = "messages"
				setEditBoxText(ebElements[1], "")
				setEditBoxText(ebElements[2], "")
				if #phone.contacts >= 10 then return exports.rp_library:createBox("Posiadasz limit posiadanych kontaktów: 10, usuń jakikolwiek aby znów kogoś dodać.") end
				table.insert(phone.contacts, {name = name, phoneNumber = phoneNumber, messages = {}})
				savePhoneData()
            else
				exports.rp_library:createBox("Wprowadź poprawną nazwę i numer telefonu!")
            end
            return
			elseif isMouseInPosition(globAppsX + 80 * scaleValue, globAppsY + 400 * scaleValue, 200 * scaleValue, 30 * scaleValue, 5 * scaleValue) then
			phone.currentApp = "messages"
			resetEditBox(ebElements[1])
			resetEditBox(ebElements[2])
        end
    end
    
	if phone.currentApp == "calling" then
		if isMouseInPosition(globAppsX + 150 * scaleValue, globAppsY + 300 * scaleValue, 64*scaleValue, 64*scaleValue) then -- odrzuc
			triggerServerEvent("onPlayerCallDecline", localPlayer)
		end
	end
	if phone.currentApp == "answering" then
		if isMouseInPosition(globAppsX + 95 * scaleValue, globAppsY + 300 * scaleValue, 64*scaleValue, 64*scaleValue) then  -- odbierz
				triggerServerEvent("onPlayerCallDecline", localPlayer)
		elseif isMouseInPosition(globAppsX + 210 * scaleValue, globAppsY + 300 * scaleValue, 64*scaleValue, 64*scaleValue) then -- odrzuc
				triggerServerEvent("onPlayerAnswerPhone", localPlayer)

		end
	end
	if phone.currentApp == "talking" then
	if isMouseInPosition(globAppsX + 150 * scaleValue, globAppsY + 300 * scaleValue, 64*scaleValue, 64*scaleValue) then -- odrzuc
				triggerServerEvent("onPlayerCallDecline", localPlayer)
		end
	end
    if phone.currentApp == "settings" then
        local startY = globAppsY + 55 * scaleValue
        local startX = globAppsX + 85 * scaleValue
        local offset = 0
        
        for k, v in ipairs(phone.settings) do
            local txtWidth = dxGetTextWidth(v.name .. ":", 1, font, false)
            local rectX = startX + txtWidth * scaleValue + 10 * scaleValue
            local rectY = startY + offset
            
            if isMouseInPosition(rectX, rectY, 50 * scaleValue, 15 * scaleValue) then
                if type(v.state) == "number" then
                    local maxValue = v.max or 10  
                    v.state = (v.state % maxValue) + 1
                else
                    v.state = not v.state
                end
                savePhoneData()
                if v.onChange then
                    v.onChange(v.state)
                end
                
                return
            end
            
            offset = offset + 20 * scaleValue
        end
    end
end
local talkingTimer = false
function talkCount()
	phone.talkingTime = phone.talkingTime + 1
end
function formatCallTime()
    local minutes = math.floor(phone.talkingTime / 60)
    local secs = phone.talkingTime % 60
    return string.format("%02d:%02d", minutes, secs)
end
function onPlayerCalling(phoneNumber, answering, secondPhoneNumber)
	-- dzwonisz do... i rozlacz musi byc dla tego co dzwoni, potem jak odbierze tamten to dla dwoch currentApp musi byc talking

   --calling ustawic
   if not answering then -- dzwoniacy
   phone.callingTo = phoneNumber
   phone.currentApp = "calling"
   else -- odbierajacy
   phone.callingTo = secondPhoneNumber-- numer dzwoniacy do niego
   phone.currentApp = "answering"
   end
	phone.talkingTime = 0
end
addEvent("onPlayerCalling", true)
addEventHandler("onPlayerCalling", getRootElement(), onPlayerCalling)

local playerRingtones = {}

function playSoundForPlayers(player, ringtone, sms)
    if ringtone == "disable" then
        if not playerRingtones[player] then
            return
        end
        destroyElement(playerRingtones[player])
        playerRingtones[player] = nil
        return
    end
    if sms then
        local x, y, z = getElementPosition(player)
        local sound = playSound3D("files/ringtones/sms.mp3", x, y, z, false)
        setSoundVolume(sound, 0.3)
        return
    end
    local x, y, z = getElementPosition(player)

    local sound = playSound3D("files/ringtones/" .. ringtone .. ".mp3", x, y, z, true)
    setElementDimension(sound, getElementDimension(player))
    setElementInterior(sound, getElementInterior(player))
    attachElements(sound, player, 0, 0, 0)
    playerRingtones[player] = sound
    setSoundVolume(sound, 0.1)
end
addEvent("playSoundForPlayers", true)
addEventHandler("playSoundForPlayers", getRootElement(), playSoundForPlayers)

function goToHomeScreen(another) 
	if another == "talkingStage" then
	phone.currentApp = "talking"
	if isTimer(talkingTimer) then killTimer(talkingTimer) outputChatBox("usunieto timer") end
	talkingTimer = setTimer ( talkCount, 1000, 0)
	--setTimer na talkingTime aby co sekunde dodawal sekunde do czasu a potem format.
	return
	end
	phone.callingTo = false
	phone.currentApp = "home"
	phone.talkingTime = 0
	if isTimer(talkingTimer) then killTimer(talkingTimer) end
end
addEvent("goToHomeScreen", true)
addEventHandler("goToHomeScreen", getRootElement(), goToHomeScreen)

addEvent("onPlayerSMSDelivered", true)
addEventHandler("onPlayerSMSDelivered", root, function(targetNumber, messageData)
    -- exports.rp_library:createBox("Wiadomość została dostarczona do: "..getNameNumber(targetNumber))
    
    addMessageToContact(targetNumber, messageData)
    savePhoneData()
end)

addEvent("onPlayerReceiveSMS", true)
addEventHandler("onPlayerReceiveSMS", root, function(messageData)
    addMessageToContact(messageData.sender, messageData)
    savePhoneData()
    
    exports.rp_library:createBox("Otrzymałeś nową wiadomość od: "..getNameNumber(messageData.sender))
end)