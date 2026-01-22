weather = {}

local apiKey = "9aa928767af76ed261d609bbfa904fed" --e648971715d8148ded25c9f7fedb884b
local city = "Los%20Angeles"





function startImageDownload()
	print("Wykonywanie zapytania...")
    fetchRemote ( "http://api.openweathermap.org/data/2.5/weather?q=" .. city .. "&appid=" .. apiKey .. "&units=metric", myCallback )
end

function myCallback( responseData, errorCode, playerToReceive )
-- print(errorCode)
    if errorCode == 0 then
	-- iprint(fromJSON(responseData))
	local weatherData = fromJSON(responseData)
        if weatherData then
			local serverTime = getRealTime()
            local currentTime = ("%04d-%02d-%02d %02d:%02d:%02d"):format(
                serverTime.year + 1900, serverTime.month + 1, serverTime.monthday,
                serverTime.hour, serverTime.minute, serverTime.second
            )
            
            local weatherDescription = weatherData.weather[1].description
			local weatherMainDescription = weatherData.weather[1].main -- Clouds np
            local temperature = weatherData.main.temp
			local temperatureFeelsLike = weatherData.main.feels_like
            local windSpeed = weatherData.wind.speed 
			setTime(serverTime.hour, serverTime.minute, serverTime.second)
			setMinuteDuration(60000)
            print("Czas lokalny w Los Angeles: " .. currentTime)
            print("Pogoda w Los Angeles: " .. weatherDescription .. ", Temperatura: " .. temperature .. "°C, odczuwalna: "..temperatureFeelsLike.." °C..")
            print("Szybkość wiatru: " .. windSpeed .. " m/s")
			-- iprint(weatherData.weather[1].main)
			-- outputChatBox("Opis pogody: "..weatherMainDescription)
			-- iprint(weatherMainDescription)
			-- iprint(weatherMainDescription)
			local weatherToSet = tableDescription[weatherMainDescription]
			-- outputChatBox(weatherToSet)
			setCloudsEnabled(true)
			setWeather(weatherToSet)
			generateRandomWeather()
			end
    end
end

tableDescription = {
-- ["mist"] = 9,
-- ["broken clouds"] = 10,
["Clouds"] = 2,
["Thunderstorm"] = 16,--	RAINY_COUNTRYSIDE
["Rain"] = 8, 
["Drizzle"] = 8,
["Clear"] = 10,
["Mist"] = 2,
["Fog"] = 2,
["Haze"] = 0,
["Smoke"] = 9,
 
}
-- function setWeather(text)
-- local weather = tableDescription[text]
-- end

addEventHandler("onResourceStart", resourceRoot, startImageDownload)

setTimer ( startImageDownload, 3600000, 0)

function generateRandomWeather()
local cloud = math.random(1,7)
local clear = math.random(10,15)
tableDescription["Clouds"] = cloud
tableDescription["Clear"] = clear
tableDescription["Mist"] = clear
end
--environment sounds 

print("weather loaded")

