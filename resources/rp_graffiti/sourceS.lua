local graffitiSavePath = "storedServerGraffitis.json"
local graffitiSaveFolder = "files/server_graffitis/"

local graffitiDatas = {}
local graffitiImages = {}

addEvent("onTryToDownloadClientImage", true)
addEventHandler("onTryToDownloadClientImage", getRootElement(),
	function (path)
		local player = client
		
		fetchRemote(path,
			function (responseData, errno)
				triggerClientEvent(player, "onClientReceiveDownloadedImage", player, responseData, errno)
			end
		, "", false)
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		if not fileExists(graffitiSavePath) then
			graffitiDatas = {}
		else
			local graffitis = fileOpen(graffitiSavePath)
			if graffitis then
				local graffitisData = fileRead(graffitis, fileGetSize(graffitis))
				
				if graffitisData then
					graffitiDatas = fromJSON(graffitisData)
					
					local currentTime = getRealTime().timestamp
					local twoWeeksInSeconds = 60 * 60 * 24 * 14

					for fileName, data in pairs(graffitiDatas) do
						local timestamp = tonumber(fileName:match("^(%d+)%-%w+"))
						
						if timestamp and currentTime - timestamp > twoWeeksInSeconds then
							-- Usuwamy stare graffiti
							if fileExists(graffitiSaveFolder .. fileName .. ".png") then
								fileDelete(graffitiSaveFolder .. fileName .. ".png")
							end

							graffitiDatas[fileName] = nil
							graffitiImages[fileName] = nil
						else
							-- Ładujemy graffiti do pamięci
							if fileExists(graffitiSaveFolder .. fileName .. ".png") then
								local graffitiImage = fileOpen(graffitiSaveFolder .. fileName .. ".png")
								if graffitiImage then
									graffitiImages[fileName] = fileRead(graffitiImage, fileGetSize(graffitiImage))
									fileClose(graffitiImage)
								end
							end
						end
					end
				end
				
				fileClose(graffitis)
			end
		end
	end
)


setTimer(function()
	local currentTime = getRealTime().timestamp
	local twoWeeksInSeconds = 60 * 60 * 24 * 14
	local changed = false

	for fileName, data in pairs(graffitiDatas) do
		local timestamp = tonumber(fileName:match("^(%d+)%-%w+"))
		
		if timestamp and currentTime - timestamp > twoWeeksInSeconds then
			if fileExists(graffitiSaveFolder .. fileName .. ".png") then
				fileDelete(graffitiSaveFolder .. fileName .. ".png")
			end

			graffitiDatas[fileName] = nil
			graffitiImages[fileName] = nil
			changed = true
		end
	end

	-- Zapisujemy dane jeśli coś się zmieniło
	if changed then
		local updatedData = toJSON(graffitiDatas)
		local saveFile = fileCreate(graffitiSavePath)
		if saveFile then
			fileWrite(saveFile, updatedData)
			fileClose(saveFile)
		end
	end
end, 1000 * 60 * 60 * 8, 0) -- co 8 godzin


addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		if fileExists(graffitiSavePath) then
			fileDelete(graffitiSavePath)
		end
		
		local graffitis = fileCreate(graffitiSavePath)
		if graffitis then
			fileWrite(graffitis, toJSON(graffitiDatas))
			fileClose(graffitis)
		end
	end
)

addEvent("requestGraffitiList", true)
addEventHandler("requestGraffitiList", getRootElement(),
	function ()
		triggerClientEvent(client, "receiveGraffitiList", client, graffitiDatas)
	end
)

addEvent("requestGraffitis", true)
addEventHandler("requestGraffitis", getRootElement(),
	function (requestGraffitis)
		if requestGraffitis then
			local datasToSend = {}
			
			for _, fileName in pairs(requestGraffitis) do
				if graffitiDatas[fileName] and graffitiImages[fileName] then
					table.insert(datasToSend, {fileName, graffitiImages[fileName]})
				end
			end
			
			triggerClientEvent(client, "receiveGraffitis", client, datasToSend)
		end
	end
)

addEvent("createGraffiti", true)
addEventHandler("createGraffiti", getRootElement(),
	function (pixels, data)
		if not exports.rp_inventory:getUsedTypeItem(client, 10) then return end
		local fileName = getRealTime().timestamp .. "-" .. utf8.gsub(utf8.gsub(getPlayerName(client), "#%x%x%x%x%x%x", ""), "%W", "")
		
		local graffitiImage = fileCreate(graffitiSaveFolder .. fileName .. ".png")
		if graffitiImage then
			fileWrite(graffitiImage, pixels)
			fileClose(graffitiImage)
			
			graffitiImages[fileName] = pixels
			graffitiDatas[fileName] = data
			graffitiDatas[fileName].fileName = fileName
			
			triggerClientEvent("createGraffiti", getRootElement(), client, graffitiImages[fileName], graffitiDatas[fileName])
		end
	end
)

addEvent("deleteGraffiti", true)
addEventHandler("deleteGraffiti", getRootElement(), -- check
	function (fileName)
			if not exports.rp_inventory:getUsedTypeItem(client, 10) then return end
		if graffitiDatas[fileName] then
			if fileExists(graffitiSaveFolder .. fileName .. ".png") then
				fileDelete(graffitiSaveFolder .. fileName .. ".png")
			end
			
			graffitiDatas[fileName] = nil
			graffitiImages[fileName] = nil
			
			triggerClientEvent("deleteGraffiti", getRootElement(), fileName)
		end
	end
)

addEvent("protectGraffiti", true)
addEventHandler("protectGraffiti", getRootElement(),
	function (fileName)
		if graffitiDatas[fileName] then
			graffitiDatas[fileName].isProtected = not graffitiDatas[fileName].isProtected
			
			triggerClientEvent("protectGraffiti", getRootElement(), fileName, graffitiDatas[fileName].isProtected)
		end
	end
)

addEvent("graffitiCleanAnimation", true)
addEventHandler("graffitiCleanAnimation", getRootElement(),
	function ()
		setPedAnimation(client, "graffiti", "spraycan_fire", 15000, true, false, false, false)
	end
)