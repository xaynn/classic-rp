benchPress = {}

local function updown(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_bp_up_smooth", false, true, "benchpress")
  elseif state == "up" then
    utility.animation(player, "gym_bp_down", false, true, "benchpress")
  end
end

local function stop(player)
  unbindKey(player, "enter", "down", stop)
  unbindKey(player, "space", "down", updown)
  unbindKey(player, "space", "up", updown)
  utility.animation(player, "gym_bp_getoff", false, true, "benchpress")

  setTimer(function()
    exports.pAttach:detach(sztanga, player)
    setElementRotation(sztanga, 0, 90, 0)
    setElementPosition(sztanga, 1166.55, -1661.5, 22.3)
  end, 3400, 1)
  
  setTimer(function ()
    stopExercise(player)
    setElementFrozen(player, false)
  end, 8500, 1)
end

function benchPress.start(obj, player)
  setElementFrozen(player, true)
  local x, y, z = getElementPosition(obj)
  local rx, ry, rz = getElementRotation(obj)
  setElementPosition(player, x, y - 1, z + 1.05)
  setElementRotation(player, rx, ry, rz, "default", true)
  utility.animation(player, "gym_bp_geton", false, true, "benchpress")

  setTimer(function()
    exports.pAttach:attach(sztanga, player, "right-hand", 0, 0, -0.1, 0, -5, 0)
    bindKey(player, "enter", "down", stop, player)
    bindKey(player, "space", "down", updown, player)
    bindKey(player, "space", "up", updown, player)
  end, 4000, 1)
end

return benchPress
