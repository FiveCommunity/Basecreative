-----------------------------------------------------------------------------------------------------------------------------------------
-- SOUTH
-----------------------------------------------------------------------------------------------------------------------------------------
WeatherListS = { "EXTRASUNNY", "CLEAR", "CLOUDS", "SMOG", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "CLEARING" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORTH
-----------------------------------------------------------------------------------------------------------------------------------------
WeatherListN = { "EXTRASUNNY", "CLEAR", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "CLEARING" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLASSWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
function ClassWeather(Type)
	local Weather = "Limpo"

	if Type == "EXTRASUNNY" then
		Weather = "Ensolarado"
	elseif Type == "CLEAR" then
		Weather = "Limpo"
	elseif Type == "CLOUDS" then
		Weather = "Nublado"
	elseif Type == "SMOG" then
		Weather = "Poluído"
	elseif Type == "FOGGY" then
		Weather = "Enevoado"
	elseif Type == "OVERCAST" then
		Weather = "Nublado"
	elseif Type == "RAIN" then
		Weather = "Chuvoso"
	elseif Type == "THUNDER" then
		Weather = "Tempestuoso"
	elseif Type == "CLEARING" then
		Weather = "Instável"
	elseif Type == "NEUTRAL" then
		Weather = "Neutro"
	elseif Type == "SNOW" then
		Weather = "Nevando"
	elseif Type == "BLIZZARD" then
		Weather = "Nevasca"
	elseif Type == "SNOWLIGHT" then
		Weather = "Nevasca"
	elseif Type == "XMAS" then
		Weather = "Nevando"
	elseif Type == "HALLOWEEN" then
		Weather = "Apocalíptico"
	end

	return Weather
end