-- function that triggers server event after player pushes enter button (player wants to start work out)
local function findMachine()
    triggerServerEvent("playerLookingForMachine", localPlayer)
end

local trainingActionCooldown1 = false
local trainingActionCooldown2 = false
local trainingActionCooldown3 = false
local trainingActionCooldown4 = false

-- function that manages strength training; checks if players action key is up or down and checks for cooldowns; then fires event to server to run animation (animations on server side for sync); then starts timer for cooldown
local function weightsAction(key, state, type)
    local _, anim = getPedAnimation(localPlayer)
    if state == "down" and trainingActionCooldown1 ~= true and trainingActionCooldown2 ~= true then
        trainingActionCooldown1 = true
        triggerServerEvent("doExercise", localPlayer, type, "up_smooth", true)
        setTimer(function ()
            trainingActionCooldown1 = false
        end, 500, 1)
    elseif state == "up" and trainingActionCooldown2 ~= true and string.find(anim, "up_smooth") then
        trainingActionCooldown2 = true
        triggerServerEvent("doExercise", localPlayer, type, "down", true)
        setTimer(function ()
            trainingActionCooldown2 = false
        end, 500, 1)
    end
end

-- animations names for all paces of cardio workout
local animNames = {
    ["bicycle"] = {
        ["normal"] = "still",
        ["medium"] = "pedal",
        ["fast"] = "fast"
    },
    ["runningtrack"] = {
        ["normal"] = "walk",
        ["medium"] = "jog",
        ["fast"] = "sprint"
    }
}

-- function that manages cardio training; without input player is idle (bicycle) or walking (runningtrack) with space pressed player is moving with normal speed and with space + mb1 fast speed; cooldowns are to prevent a player from spamming animation
local function gymnasiumAction(key, state, type, start)
    local start = start or false

    local _, anim = getPedAnimation(localPlayer)
    local anim = anim or ""
    if key == "space" then -- normal
        if state == "down" and trainingActionCooldown1 ~= true and trainingActionCooldown2 ~= true then
            trainingActionCooldown1 = true
            if getKeyState("mouse1") then -- if player holds mb1 dont train at med speed but at fastest speed
                triggerServerEvent("doExercise", localPlayer, type, animNames[type]["fast"], false, true)
            else
                triggerServerEvent("doExercise", localPlayer, type, animNames[type]["medium"], false, true)
            end
            setTimer(function ()
                trainingActionCooldown1 = false
            end, 500, 1)
        elseif state == "up" and trainingActionCooldown2 ~= true and (string.find(anim, animNames[type]["fast"]) or string.find(anim, animNames[type]["medium"]) or start) then -- checks for cooldown and if previous animations were fast or pedal to not create weird animation
            trainingActionCooldown2 = true
            triggerServerEvent("doExercise", localPlayer, type, animNames[type]["normal"], false, true)
            setTimer(function ()
                trainingActionCooldown2 = false
            end, 500, 1)
        end
    elseif key == "mouse1" and getKeyState("space") then -- fast
        if state == "down" and trainingActionCooldown3 ~= true and trainingActionCooldown4 ~= true then
            trainingActionCooldown3 = true
            triggerServerEvent("doExercise", localPlayer, type, animNames[type]["fast"], false, true)
            setTimer(function ()
                trainingActionCooldown3 = false
            end, 500, 1)
        elseif state == "up" and trainingActionCooldown4 ~= true and (string.find(anim, animNames[type]["fast"]) or string.find(anim, animNames[type]["medium"])) then -- checks for cooldown and if previous animations were fast or pedal to not create weird animation
            trainingActionCooldown4 = true
            if getKeyState("space") then -- if player holds space dont reduce him to slowest speed but to med speed
                triggerServerEvent("doExercise", localPlayer, type, animNames[type]["medium"], false, true)
            else
                triggerServerEvent("doExercise", localPlayer, type, animNames[type]["normal"], false, true)
            end
            setTimer(function ()
                trainingActionCooldown4 = false
            end, 500, 1)
        end
    end
end

bindKey("enter", "down", findMachine) -- binds enter for training start key

-- timer times (estimate); provided time is time needed to complete ending animation for certain training type
local stopTimers = {
    ["runningtrack"] = 3000,
	["pressbench"] = 5500,
	["bicycle"] = 1500,
	["mat"] = 3000
}

-- cancel damage while player is training
local function playerGodMode()
    cancelEvent()
end

local maxStamina = 100
local currentStamina = 100

local function updateStaminaBarForGym()
    local scaleValue = exports.rp_scale:returnScaleValue()
    local STAMINA_BAR_WIDTH = 300
    local STAMINA_BAR_HEIGHT = 30
    local STAMINA_BAR_X = 810
    local STAMINA_BAR_Y = 900
    local staminaBarLength = STAMINA_BAR_WIDTH * (currentStamina / maxStamina) * scaleValue
    dxDrawRectangle(STAMINA_BAR_X * scaleValue, STAMINA_BAR_Y * scaleValue, STAMINA_BAR_WIDTH * scaleValue, STAMINA_BAR_HEIGHT * scaleValue, tocolor(204, 204, 0, 50), true)
    dxDrawRectangle(STAMINA_BAR_X * scaleValue, STAMINA_BAR_Y * scaleValue, staminaBarLength, STAMINA_BAR_HEIGHT * scaleValue, tocolor(204, 204, 0, 255), true)
    dxDrawText("Stamina", STAMINA_BAR_X * scaleValue, STAMINA_BAR_Y - 30 * scaleValue, nil, nil, tocolor(255, 255, 255, 255), 2.0, 2.0, "assets\\Helvetica.ttf", "left", "top", false, false, true)
end

local function staminaBarState(state)
    print(state)
    if state == true then
        addEventHandler("onClientRender", root, updateStaminaBarForGym)
    else
        removeEventHandler("onClientRender", root, updateStaminaBarForGym)
    end
end

local function localStaminaUpdate(newStamina)
    currentStamina = newStamina
end

-- function that sets correct keybinding after player stops his workout; triggers server event to stop all serverside things
local function stopExercise(_, _, type)
    unbindKey("enter", "down", stopExercise)
    if type == "pressbench" or type == "mat" then
        unbindKey("space", "both", weightsAction, type)
    else
        unbindKey("mouse1", "both", gymnasiumAction, type)
        unbindKey("space", "both", gymnasiumAction, type)
    end
    triggerServerEvent("offExercise", localPlayer, type, stopTimers[type])
    setTimer(function ()
        bindKey("enter", "down", findMachine)
        removeEventHandler("onClientPlayerDamage", localPlayer, playerGodMode)
    end, stopTimers[type], 1)
end

-- timer times (estimate); provided time is time needed to complete starting animation for certain training type
local startTimers = {
    ["runningtrack"] = 2500,
	["pressbench"] = 6500,
	["bicycle"] = 1500,
	["mat"] = 3000
}


-- function that is constantly checking if player fully completed a strength rep (fully - he also took it down); if he did fires a server event to update his progress
local weightsTimer = nil
local didDown = true
local function checkExerciseState()
    local _, anim = getPedAnimation(localPlayer)
    local progress = getPedAnimationProgress(localPlayer)
    if progress == 1 and didDown and (anim == "gym_bp_up_smooth" or anim == "gym_free_up_smooth") then
        didDown = false
        triggerServerEvent("weightsTraining", localPlayer)
    elseif progress == 1 and (anim == "gym_bp_down" or anim == "gym_free_down") then
        didDown = true
    end
end

-- function that sets correct keybinding after player starts his workout
local function startExercise(type, newMaxStamina)
    maxStamina = newMaxStamina
    addEventHandler("onClientPlayerDamage", localPlayer, playerGodMode)
    unbindKey("enter", "down", findMachine)
    setTimer(function ()
        bindKey("enter", "down", stopExercise, type)
        if type == "pressbench" or type == "mat" then
            weightsTimer = setTimer(checkExerciseState, 100, 0)
            bindKey("space", "both", weightsAction, type)
        else
            gymnasiumAction("space", "up", type, true)
            bindKey("mouse1", "both", gymnasiumAction, type)
            bindKey("space", "both", gymnasiumAction, type)
        end
    end, startTimers[type], 1)
end

addEvent( "turnStaminaBar", true )
addEventHandler( "turnStaminaBar", localPlayer, staminaBarState )

addEvent( "onStaminaChange", true )
addEventHandler( "onStaminaChange", localPlayer, localStaminaUpdate )

addEvent( "onExercise", true )
addEventHandler( "onExercise", localPlayer, startExercise )

addEvent( "noStamina", true )
addEventHandler( "noStamina", localPlayer, stopExercise )