DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local sx, sy = guiGetScreenSize()
local font = dxCreateFont("Helvetica.ttf", 20, false, "proof") or "default" -- fallback to default

local buttons = {}
local editboxes = {}
local checkboxes = {}
local windows = {}
local gridlists = {}
local labels = {}

local rectangles = {}
local comboboxes = {}
-- local xd = DGS:dgsCreateEdit(400, 400, 400, 50, "", false)
-- DGS:dgsSetProperty(xd, "font", font)
-- DGS:dgsSetProperty(xd, "placeHolderFont", font)
-- DGS:dgsSetProperty(xd, "placeHolder", "Podaj swój nickname")
-- DGS:dgsSetProperty(xd, "bgImage", rounded)
-- DGS:dgsSetProperty(xd, "caretHeight", 0.85)
-- DGS:dgsSetProperty(xd, "padding", {50, 13})  
-- DGS:dgsSetProperty(xd, "textSize", {0.7, 0.7})
-- DGS:dgsSetProperty(xd, "selectColor", tocolor(76, 60, 140, 255))
-- DGS:dgsSetProperty(xd, "alignment", {"left", "top"}) 
-- DGS:dgsSetProperty(xd, "placeHolderVisibleWhenFocus", true)



function createEditBox(id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners)
    local rounded = DGS:dgsCreateRoundRect(corners, false, tocolor(22, 25, 24, 255))

    local editbox = DGS:dgsCreateEdit(x, y, w, h, text, false, parent)
    local border, rectColor = createRectangle(id .. "rectangle", x, y, w, h, corners, parent)
    DGS:dgsSetProperty(editbox, "font", font)
    DGS:dgsSetProperty(editbox, "placeHolderFont", font)
    DGS:dgsSetProperty(editbox, "placeHolder", placeHolder)
    DGS:dgsSetProperty(editbox, "bgImage", rounded)
	-- DGS:dgsSetPostGUI(editbox, true)
	DGS:dgsSetPostGUI(border, true)

    DGS:dgsSetProperty(editbox, "caretHeight", caretHeight)
    -- end
    if padding then -- dla ikon po prostu
        DGS:dgsSetProperty(editbox, "padding", {50, 0})
    else
        DGS:dgsSetProperty(editbox, "padding", {5, 0})
    end
    DGS:dgsSetProperty(editbox, "textSize", {textSize, textSize}) -- 0.7
    DGS:dgsSetProperty(editbox, "selectColor", tocolor(40, 40, 46, 255))
    DGS:dgsSetProperty(editbox, "alignment", {"left", "center"})
    DGS:dgsSetProperty(editbox, "placeHolderVisibleWhenFocus", true)
    DGS:dgsSetProperty(editbox, "maxLength", maxLength)
    DGS:dgsSetProperty(editbox, "masked", masked)
    -- DGS:dgsSetProperty(editbox,"shadow",{1,1,tocolor(0,0,0,255),true})
    editboxes[id] = {editbox, rounded, border}

    addEventHandler(
        "onDgsBlur",
        editbox,
        function()
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(255, 255, 255, 255))
            end
        end
    )

    addEventHandler(
        "onDgsFocus",
        editbox,
        function()
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(111, 97, 209, 255))
            end
        end
    )

    addEventHandler(
        "onDgsEditSwitched",
        editbox,
        function(previous)
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(255, 255, 255))
            end
        end
    )
    return editbox
end



function createRectangle(id, x, y, w, h, cornerRadius, parent)
    local cornerRadius = cornerRadius

    local backgroundColor = tocolor(255, 255, 255, 220)

    local borderColor = tocolor(0, 0, 0, 180)


    local roundedRect = DGS:dgsCreateRoundRect(cornerRadius, false, backgroundColor, backgroundColor, true, true)


    local roundedRectImage = DGS:dgsCreateImage(x, y, w, h, roundedRect, false, parent)
    DGS:dgsRoundRectSetBorderThickness(roundedRect, 0.01, 0.01)
	DGS:dgsSetEnabled(roundedRectImage, false)
	DGS:dgsSetPostGUI(roundedRectImage, true)

	rectangles[id] = {roundedRectImage}
	return roundedRectImage, roundedRect
end

-- createEditBox("sss", 400, 400, 400, 40, "", nil, 0.5, 0.7, 50, false, "Podaj swój nickname")

-- createRectangle("xcvdcvfb", 300, 300, 200, 200)
function createLabel(id, x, y, w, h, text, parent, scale, horizontalAlign, verticalAlign, colorCoded, subPixelPositioning, wordBreak)
	local label = DGS:dgsCreateLabel(x, y, w, h, text, false, parent, 0xFFFFFFFF, scale, scale, _, _, _, horizontalAlign, verticalAlign)
	DGS:dgsSetProperty(label,"colorCoded",colorCoded)
	DGS:dgsSetProperty(label,"font",font)
	DGS:dgsSetProperty(label,"subPixelPositioning",subPixelPositioning)
	DGS:dgsSetProperty(label,"wordBreak",wordBreak)
	labels[id] = {label}
	return label
	
end
-- createLabel("fiasd", 400, 380, 100, 40, "Username", nil, 0.5, "left", "top", false, true, false)

function creatededsgfgdfsEditBox(id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked, placeHolder)
    local editbox = DGS:dgsCreateEdit(x,y,w,h,text,false,parent,nil,1,1)

    if bgColor then
        DGS:dgsSetProperty(editbox, "bgColor", bgColor)
    end

    DGS:dgsSetProperty(editbox, "caretHeight", caretHeight)
    DGS:dgsSetProperty(editbox, "font", font)
    DGS:dgsSetProperty(editbox, "textSize", {textSize, textSize})
    -- DGS:dgsSetProperty(editbox, "bgcolor", tocolor(255, 255, 255, 0))

    DGS:dgsSetProperty(editbox, "selectColor", tocolor(0,95,255,255))
    DGS:dgsSetProperty(editbox, "selectColorBlur", tocolor(0,95,255,255))

    DGS:dgsSetProperty(editbox, "maxLength", maxLength)
    if masked then
        DGS:dgsSetProperty(editbox, "masked", true)
    end
	if placeHolder then
	DGS:dgsSetProperty(editbox,"placeHolderFont",font)
	DGS:dgsSetProperty(editbox,"placeHolder",placeHolder)
	DGS:dgsSetProperty(editbox,"textSize",{textSize,textSize})
	end
    local rectanglelabel = DGS:dgsCreateRoundRect(0, false, tocolor(255, 255, 255, 255))
    local createdLabel = DGS:dgsCreateImage(x ,y + h - 5,w,1,rectanglelabel,false,parent)
    editboxes[id] = {editbox, rectanglelabel, createdLabel}

    addEventHandler("onDgsBlur",editbox,
        function()
			if source == editbox then
            DGS:dgsRoundRectSetColor(rectanglelabel, tocolor(255, 255, 255)) 
			end
        end
    )

    addEventHandler("onDgsFocus",editbox,
        function()
			if source == editbox then
            DGS:dgsRoundRectSetColor(rectanglelabel, tocolor(23,63,139,255)) 
			end
        end)

	addEventHandler("onDgsEditSwitched", editbox, 
	function(previous)
		if source == editbox then
	     DGS:dgsRoundRectSetColor(rectanglelabel, tocolor(255, 255, 255))
	end
	end)



	
    return editbox
end




function createWindow(id, x, y, width, height, windowText, rounded, textSize, movable, closeButton)
    local px = 0
    if rounded then
        px = rounded * scaleValue
    else
        px = 0
    end
	local titleHeight = 0
	if windowText then
	titleHeight = 30 * scaleValue
	end
    -- local rectangle = DGS:dgsCreateRoundRect(px, false, tocolor(26, 29, 38, 255))
	local rectangle = DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {px,false}, {px,false} }, tocolor(19,23,24,255) )
	local rectangle2 = DGS:dgsCreateRoundRect({ {px,false}, {px,false}, {0,false}, {0,false} }, tocolor(19,23,24,255) )
    -- local window = DGS:dgsCreateWindow(x,sy,width,height,windowText,false,nil,titleHeight,rectangle,nil,rectangle,nil,nil,false)
	local window  = DGS:dgsCreateWindow(x, y, width, height, windowText, false, nil, titleHeight, rectangle, nil, rectangle, nil, nil, closeButton)
	DGS:dgsSetProperty(window,"image", rectangle)
    DGS:dgsSetProperty(window,"titleImage", rectangle2)
    DGS:dgsSetProperty(window, "sizable", false)
	DGS:dgsSetProperty(window,"font",font)
	DGS:dgsSetProperty(window,"textSize",{textSize, textSize})
	DGS:dgsSetProperty(window,"movable",movable)
	
	exports.rp_nicknames:setNicknamesState(false)

	-- DGS:dgsSetInputMode("no_binds_when_editing")
	DGS:dgsSetInputMode("no_binds")

	addEventHandler("onDgsWindowClose", window, function()
        if source == window then
           DGS:dgsSetInputMode("allow_binds")
		   showCursor(false)
		   exports.rp_nicknames:setNicknamesState(true)
		   end
    end)
	
	addEventHandler("onClientElementDestroy", window, function()
		if source == window then
		DGS:dgsSetInputMode("allow_binds")
		showCursor(false)
		end
end)

	windows[id] = {rectangle, window, rectangle2}
	showCursor(true)
	return window
end


function createCheckBox(id, x, y, text, parent, textSize)
    local uncheckedRect = DGS:dgsCreateRoundRect(5 * scaleValue, false, tocolor(111,97,209,255))
    local checkedRect = DGS:dgsCreateRoundRect(5 * scaleValue, false, tocolor(125, 109, 237, 255))

    local uncheckedBox = DGS:dgsCreateCheckBox(x, y, 16, 16, text, false, false, parent, tocolor(255, 255, 255, 255), 1, 1, uncheckedRect, uncheckedRect, uncheckedRect, nil, nil, nil, checkedRect, checkedRect, checkedRect)
    local checkboxWidth, checkboxHeight = DGS:dgsGetSize(uncheckedBox, false)
    local checkedcheckboxDraw = DGS:dgsCreateImage(x + checkboxWidth / 2 - 8, y + checkboxHeight / 2 - 8, 16*scaleValue, 16*scaleValue, "checkbox.png", false, parent, tocolor(255, 255, 255, 255))
    local currentId = id
    local currentBox = uncheckedBox
    DGS:dgsSetAlpha(checkedcheckboxDraw, 0)
    checkboxes[id] = {uncheckedRect, checkedRect, uncheckedBox, checkedcheckboxDraw}
    DGS:dgsSetEnabled(checkboxes[id][4], false)
    DGS:dgsSetProperty(uncheckedBox, "textSize", {textSize, textSize})
    DGS:dgsSetProperty(uncheckedBox, "font", font)
	-- DGS:dgsSetProperty(button, "textColor", tocolor(17,18,19,255))

    addEventHandler("onDgsCheckBoxChange", checkboxes[id][3], function(state)
        if source == uncheckedBox then
            if state then
                if isElement(checkboxes[currentId][4]) then destroyElement(checkboxes[currentId][4]) end
                local checkboxX, checkboxY = DGS:dgsGetPosition(currentBox, false)
                local imageX = checkboxX + checkboxWidth / 2 - 8 * scaleValue
                local imageY = checkboxY + checkboxHeight / 2 - 8 * scaleValue
                checkboxes[currentId][4] = DGS:dgsCreateImage(imageX, imageY, 16*scaleValue, 16*scaleValue, "checkbox.png", false, parent, tocolor(255, 255, 255, 255))
                DGS:dgsSetEnabled(checkboxes[currentId][4], false)
            else
                if isElement(checkboxes[currentId][4]) then destroyElement(checkboxes[currentId][4]) end
            end
        end
    end)
    return uncheckedBox
end

function createGridList(id, x, y, width, height, parent, columnHeight, scale)
    local rectangle =
        DGS:dgsCreateRoundRect(
        {{0, false}, {0, false}, {5 * scaleValue, false}, {5 * scaleValue, false}},
        tocolor(19,23,24,255)
    )
    local rectanglehoover =
        DGS:dgsCreateRoundRect({{0, false}, {0, false}, {0, false}, {0, false}}, tocolor(111,97,209,255))

    local rectangle2 =
        DGS:dgsCreateRoundRect(
        {{5 * scaleValue, false}, {5 * scaleValue, false}, {0, false}, {0, false}},
        tocolor(19,23,24,255)
    )
    if not columnHeight then
        columnHeight = 20
    end
    local gridlist = DGS:dgsCreateGridList(x,y,width,height,nil,parent,columnHeight,nil,nil,nil,nil,nil,nil,rectangle,rectangle2,rectangle2,rectanglehoover,rectanglehoover)
    gridlists[id] = {rectangle, rectangle2, rectanglehoover, gridlist}
    DGS:dgsSetProperty(gridlist, "bgColor", tocolor(105,90,196,255))
    DGS:dgsSetProperty(gridlist, "titleImage", rectangle2)
	DGS:dgsSetProperty(gridlist,"font",font)
	DGS:dgsSetProperty(gridlist,"columnTextColor",tocolor(105,90,196,255))
	DGS:dgsSetProperty(gridlist,"columnColor",tocolor(105,90,196,255))
    DGS:dgsSetProperty(gridlist, "leading", 5)
	DGS:dgsSetProperty(gridlist,"rowTextSize",{scale,scale})
	DGS:dgsSetProperty(gridlist,"columnTextSize",{scale,scale})
	-- DGS:dgsSetProperty(gridlist,"defaultColumnOffset",50)
	-- DGS:dgsSetProperty(gridlist,"rowTextPosOffset",{5,5})
	-- DGS:dgsSetProperty(gridlist,"rowTextColor",tocolor(105,90,196,255))
	DGS:dgsSetProperty(gridlist,"rowColor",{tocolor(105,90,196,255),tocolor(116, 99, 219, 255),tocolor(130, 111, 242, 255)})
	DGS:dgsSetProperty(gridlist,"columnMoveOffset",5)

    return gridlist
end

-- createGridList("baba", 300, 300, 200, 200, nil)

function createComboBox(id, x, y, w, h, caption, parent, itemHeight, scale)

	-- local xd1 = DGS:dgsCreateRoundRect(20, false, tocolor(111,97,209,255))
    -- local xd2 = DGS:dgsCreateRoundRect(20, false, tocolor(122, 106, 235, 255))
	-- local xd3 = DGS:dgsCreateRoundRect(20, false, tocolor(127, 110, 250, 255))
	
	-- local image1 = DGS:dgsCreateImage(200,200,400,100,xd1,false)
	local combobox = DGS:dgsCreateComboBox(x, y, w, h, caption, false, parent, itemHeight, 0xFFFFFFFF, scale, scale)
	DGS:dgsSetProperty(combobox,"color",{tocolor(111,97,209,255),tocolor(122,106,235,255),tocolor(127,110,250,255)})
	DGS:dgsSetProperty(combobox,"itemColor",{tocolor(111,97,209,255),tocolor(122,106,235,255),tocolor(127,110,250,255)})
	DGS:dgsSetProperty(combobox,"font",font)
	-- DGS:dgsSetProperty(combobox,"textSize",{scaleX,scaleY})
	comboboxes[id] = {combobox}
	return combobox
	-- DGS:dgsSetProperty()
end
function destroyCheckbox(id)
    for k, v in pairs(checkboxes[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end

function destroyComboBox(id)
    for k, v in pairs(comboboxes[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end



function destroyLabel(id)
    for k, v in pairs(labels[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end
function createButtonRounded(id, x, y, w, h, text, parent, textSize, roundedpx) --hooverImage = clickedImage
	-- iprint(id, x, y, w, h, text, parent, textSize, roundedpx)
    local rectangleButton = DGS:dgsCreateRoundRect(roundedpx * scaleValue, false, tocolor(111,97,209,255))
    local rectangleButtonHoover = DGS:dgsCreateRoundRect(roundedpx * scaleValue, false, tocolor(122, 106, 235, 255))
	local rectangleButtonClicked = DGS:dgsCreateRoundRect(roundedpx * scaleValue, false, tocolor(127, 110, 250, 255))

	
	
    local button = DGS:dgsCreateButton(x,y,w,h,text,false,parent,nil,1,1,rectangleButton,rectangleButtonHoover,rectangleButtonClicked)
    DGS:dgsSetProperty(button, "font", font) 
    DGS:dgsSetProperty(button, "textSize", {textSize, textSize})
    DGS:dgsSetProperty(button, "textColor", tocolor(17,18,19,255))
	-- DGS:dgsSetProperty(button,"shadow",{1,1,tocolor(0,0,0,255),true})
    buttons[id] = {rectangleButton, rectangleButtonHoover, button}
	
    return button
end

function createButton(id, x, y, w, h, text, parent, textSize, func) --hooverImage = clickedImage -- moze dodac event i normalnie bedzie mozna event handler dodawac.
    local rectangleButton = DGS:dgsCreateRoundRect(0, false, tocolor(23,63,139,255))
    local rectangleButtonHoover = DGS:dgsCreateRoundRect(0, false, tocolor(23,63,139,255))
    local button = DGS:dgsCreateButton(x,y,w,h,text,false,parent,nil,1,1,rectangleButton,rectangleButtonHoover,rectangleButtonHoover)
    DGS:dgsSetProperty(button, "font", font)
    DGS:dgsSetProperty(button, "textSize", {textSize, textSize})
    buttons[id] = {rectangleButton, rectangleButtonHoover, button, x, y, w, h, func}
	
		-- removeEventHandler ( "onDgsMouseClickUp", loginPanelData.buttonLogin, tryToLogin )
    addEventHandler("onDgsMouseClickUp",button,
        function()
			if source == button then
            -- DGS:dgsRoundRectSetColor(rectanglelabel, tocolor(23,63,139,255)) 
			end
        end)
    return rectangleButton
end

function createMemoEditBox(id, x, y, w, h, text, parent, caretHeight, textSize, maxLength, placeHolder, corners)
    local rounded = DGS:dgsCreateRoundRect(corners, false, tocolor(22, 25, 24, 255))

	local border, rectColor = createRectangle(id .. "rectangle", x, y, w, h, corners, parent)
	local editbox = DGS:dgsCreateMemo(x, y, w, h, text, false, parent)
    DGS:dgsSetProperty(editbox, "font", font)
    DGS:dgsSetProperty(editbox, "placeHolderFont", font)
    DGS:dgsSetProperty(editbox, "placeHolder", placeHolder)
    DGS:dgsSetProperty(editbox, "bgImage", rounded)
	-- DGS:dgsSetPostGUI(editbox, true)
	DGS:dgsSetProperty(editbox, "textSize", {textSize, textSize}) -- 0.7
    DGS:dgsSetProperty(editbox, "selectColor", tocolor(40, 40, 46, 255))
    -- DGS:dgsSetProperty(editbox, "alignment", {"left", "center"})
    DGS:dgsSetProperty(editbox, "placeHolderVisibleWhenFocus", true)
    DGS:dgsSetProperty(editbox, "maxLength", maxLength)
	DGS:dgsSetPostGUI(border, true)

    DGS:dgsSetProperty(editbox, "caretHeight", caretHeight)
	editboxes[id] = {editbox, rounded, border}
	    addEventHandler(
        "onDgsBlur",
        editbox,
        function()
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(255, 255, 255, 255))
            end
        end
    )

    addEventHandler(
        "onDgsFocus",
        editbox,
        function()
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(111, 97, 209, 255))
            end
        end
    )

    addEventHandler(
        "onDgsEditSwitched",
        editbox,
        function(previous)
            if source == editbox then
                DGS:dgsRoundRectSetColor(rectColor, tocolor(255, 255, 255))
            end
        end
    )
	return editbox

end

-- local huj = createMemoEditBox("ssaasd", 200, 200, 200, 200, "Siemka", nil, 0.5, 1, 20, "Testiwe", 5)
-- destroyElement(huj)


function getEditBoxText(id)
if isElement(editboxes[id][1]) then
local text = DGS:dgsGetText(editboxes[id][1])
return text or ""
else
return false
end
end

function setEditBoxText(id, text)
if isElement(editboxes[id][1]) then
local text = DGS:dgsSetText(editboxes[id][1], text)
return text
end
end

function setCheckBoxState(id, state)
DGS:dgsSetProperty(checkboxes[id][3], "state", state)
triggerEvent("onDgsCheckBoxChange", checkboxes[id][3], state)
end

function getCheckBoxState(id)
local state = DGS:dgsGetProperty(checkboxes[id][3],"state") 
return state or false
end

function destroyButton(id)
    for k, v in pairs(buttons[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end

function destroyEditBox(id)
    for k, v in pairs(editboxes[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end

function destroyWindow(id)
    for k, v in pairs(windows[id]) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end


-- createButton("fiut",0,0,100,40,"siemaneczko",nil, 0.5)
-- destroyButton("fiut")
-- createEditBox("fiut", 300, 300, 200, 40, "fiut", nil, nil, tocolor(255, 0, 0, 0), 0.7, 0.7, 50, false) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
-- createEditBox("fiutson", 300, 350, 200, 40, "fiut", nil, nil, tocolor(255, 0, 0, 0), 0.7, 0.7, 50, false) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
-- destroyEditBox("fiut")
-- destroyEditBox("fiutson")

function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
    if type(sEventName) == "string" and isElement(pElementAttachedTo) and type(func) == "function" then
        local aAttachedFunctions = getEventHandlers(sEventName, pElementAttachedTo)
        if type(aAttachedFunctions) == "table" and #aAttachedFunctions > 0 then
            for i, v in ipairs(aAttachedFunctions) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

-- createCheckBox("czekbox",sx/2+5*scaleValue,sy/2+5*scaleValue,"moj checkbox",nil, 0.50*scaleValue) -- musi byc 10,10
-- createCheckBox("czekboxdfgfdg",sx/2+5*scaleValue,sy/2+30*scaleValue,"moj checkbox",nil, 0.50*scaleValue) -- musi byc 10,10

function updateCamera ()
dxDrawRectangle(sx/2+5*scaleValue,sy/2+5*scaleValue,20*scaleValue,20*scaleValue)
end
-- addEventHandler ( "onClientRender", root, updateCamera )
-- destroyEditBox("fiut")
-- showCursor(true)

-- print(getCheckBoxState("czekbox"))



-- createWindow("szmata", 100, 100, 500*scaleValue, 500*scaleValue, "szmata xd", 5, 0.5*scaleValue) --id, x, y, width, height, windowText, rounded, textSize