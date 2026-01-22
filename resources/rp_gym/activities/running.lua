running = {}

local function jog(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_tread_jog", true, false, "gymnasium")
  else
    utility.animation(player, "gym_tread_walk", true, false, "gymnasium")
  end
end

local function sprint(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_tread_sprint", true, false, "gymnasium")
  else
    utility.animation(player, "gym_tread_jog", true, false, "gymnasium")
  end
end

local function stop(player)
  unbindKey(player, "enter", "down", stop)
  unbindKey(player, "space", "down", jog)
  unbindKey(player, "space", "up", jog)
  unbindKey(player, "mouse1", "down", sprint)
  unbindKey(player, "mouse1", "up", sprint)
  utility.animation(player, "gym_tread_getoff", false, true, "gymnasium")
  
  setTimer(function()
    stopExercise(player)
    setElementFrozen(player, false)
  end, 3300, 1)
end

function running.start(obj, player)
  setElementFrozen(player, true)
  local x, y, z = getElementPosition(obj)
  local rx, ry, rz = getElementRotation(obj)
  setElementPosition(player, x, y - 1.5, z + 1)
  setElementRotation(player, rx, ry, rz, "default", true)
  utility.animation(player, "gym_tread_geton", false, true, "gymnasium")
  bindKey(player, "enter", "down", stop, player)
  bindKey(player, "space", "down", jog, player)
  bindKey(player, "space", "up", jog, player)
  bindKey(player, "mouse1", "down", sprint, player)
  bindKey(player, "mouse1", "up", sprint, player)
end

return running
