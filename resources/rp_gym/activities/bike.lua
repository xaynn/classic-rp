bike = {}

local function normal(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_bike_pedal", true, false, "gymnasium")
  else
    utility.animation(player, "gym_bike_still", true, false, "gymnasium")
  end
end

local function fast(_, _, state, player)
  if state == "down" then
    utility.animation(player, "gym_bike_fast", true, false, "gymnasium")
  else
    utility.animation(player, "gym_bike_pedal", true, false, "gymnasium")
  end
end

local function stop(player)
  unbindKey(player, "enter", "down", bike.stop)
  unbindKey(player, "space", "down", normal)
  unbindKey(player, "space", "up", normal)
  unbindKey(player, "mouse1", "down", fast)
  unbindKey(player, "mouse1", "up", fast)
  utility.animation(player, "gym_bike_getoff", false, true, "gymnasium")
  
  setTimer(function()
    stopExercise(player)
    setElementFrozen(player, false)
  end, 1800, 1)
end

function bike.start(obj, player)
  setElementFrozen(player, true)
  local x, y, z = getElementPosition(obj)
  local rx, ry, rz = getElementRotation(obj)
  setElementPosition(player, x + .5, y + .5, z + 1)
  setElementRotation(player, rx, ry, rz - 180, "default", true)
  utility.animation(player, "gym_bike_geton", false, true, "gymnasium")
  bindKey(player, "enter", "down", stop, player)
  bindKey(player, "space", "down", normal, player)
  bindKey(player, "space", "up", normal, player)
  bindKey(player, "mouse1", "down", fast, player)
  bindKey(player, "mouse1", "up", fast, player)
end

return bike
