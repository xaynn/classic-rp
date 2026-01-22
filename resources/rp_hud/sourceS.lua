function setFallAnimation()
setPedAnimation(client, "PED", "FALL_collapse", 2000, false, true, false, false, 250, true)
end


addEvent("setFallAnimation", true)
addEventHandler("setFallAnimation", getRootElement(), setFallAnimation)