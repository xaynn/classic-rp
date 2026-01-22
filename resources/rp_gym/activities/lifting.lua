lifting = {}

function updown(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_free_up_smooth", false, true, "freeweights")
  elseif state == "up" then
    utility.animation(player, "gym_free_down", false, true, "freeweights")
  end
end

local function stop(player)
  unbindKey(player, "enter", "down", stop)
  unbindKey(player, "space", "down", updown)
  unbindKey(player, "space", "up", updown)
  utility.animation(player, "gym_free_putdown", false, true, "freeweights")
  
  setTimer(function()
    exports.pAttach:detach(dumbell1, player)
    exports.pAttach:detach(dumbell2, player)
    local x2, y2, z2 = utility.getPositionFromElementOffset(mat, -0.2, 0, 0.2)
    setElementPosition(dumbell1, x2, y2, z2)
    setElementRotation(dumbell1, 0, 0, 0)
    x2, y2, z2 = utility.getPositionFromElementOffset(mat, 0.2, 0, 0.2)
    setElementPosition(dumbell2, x2, y2, z2)
    setElementRotation(dumbell2, 0, 0, 0)
  end, 1000, 1)

  setTimer(function()
    stopExercise(player)
    setElementFrozen(player, false)
  end, 3000, 1)
end

function lifting.start(obj, player)
  setElementFrozen(player, true)
  local x, y, z = getElementPosition(obj)
  local rx, ry, rz = getElementRotation(obj)
  setElementPosition(player, x, y - 1, z + 1.05)
  setElementRotation(player, rx, ry, rz, "default", true)
  utility.animation(player, "gym_free_pickup", false, true, "freeweights")

  setTimer(function()
    exports.pAttach:attach(dumbell1, player, "left-hand", 0, 0, 0, 0, 0, 0)
    exports.pAttach:attach(dumbell2, player, "right-hand", 0, 0, 0, 0, 0, 0)
    bindKey(player, "enter", "down", stop, player)
    bindKey(player, "space", "down", updown, player)
    bindKey(player, "space", "up", updown, player)
  end, 2000, 1)
end

return lifting
