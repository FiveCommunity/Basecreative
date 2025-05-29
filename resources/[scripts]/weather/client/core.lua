-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
FiveCommunity = {}
Tunnel.bindInterface("weather", FiveCommunity)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- WORLDZONES
-----------------------------------------------------------------------------------------------------------------------------------------
local WorldZones = {
	["1"] = {
		["PolyZone"] = PolyZone:Create({
			vector2(3490.7116699219, 1128.7587890625),
			vector2(2756.4135742188, 1217.3201904297),
			vector2(2426.068359375, 1103.0533447266),
			vector2(2183.0888671875, 964.26489257812),
			vector2(1952.9951171875, 949.75854492188),
			vector2(1642.8647460938, 1201.9565429688),
			vector2(1490.0106201172, 1630.8994140625),
			vector2(1114.0184326172, 1859.4862060547),
			vector2(771.62115478516, 1917.0520019531),
			vector2(410.37109375, 1919.8000488281),
			vector2(104.0051651001, 1860.3311767578),
			vector2(-206.81086730957, 1847.1422119141),
			vector2(-577.23425292969, 1885.5284423828),
			vector2(-1392.671875, 2065.4790039062),
			vector2(-1591.8718261719, 2092.94140625),
			vector2(-2007.7380371094, 2256.3449707031),
			vector2(-2729.5944824219, 2240.251953125),
			vector2(-3528.236328125, 2799.0771484375),
			vector2(-3353.5388183594, 3432.0930175781),
			vector2(-2998.0068359375, 4009.4365234375),
			vector2(-2234.1911621094, 5402.6030273438),
			vector2(-1276.1805419922, 6535.5698242188),
			vector2(-524.20947265625, 7374.849609375),
			vector2(36.372554779053, 7732.7998046875),
			vector2(1103.6657714844, 7495.3388671875),
			vector2(2060.6713867188, 7145.5551757812),
			vector2(2703.3701171875, 6887.1533203125),
			vector2(3808.1706542969, 6533.458984375),
			vector2(4472.2905273438, 5600.5551757812),
			vector2(4555.5122070312, 4972.8583984375),
			vector2(4594.9809570312, 3833.9296875),
			vector2(4367.6821289062, 2359.3764648438),
			vector2(3894.3803710938, 1443.0216064453)
		}, {
			["name"] = "North",
			["minZ"] = 6.6371645927429,
			["maxZ"] = 230.11245727539
		})
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALTHREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for Index, v in pairs(WorldZones) do
			if v["PolyZone"]:isPointInside(Coords) then
				if not Active then
					Active = Index
					LocalPlayer["state"]:set("Location", "North", true)
				end
			else
				if Active then
					Active = false
					LocalPlayer["state"]:set("Location", "South", true)
				end
			end
		end

		if LocalPlayer["state"]["Location"] == "South" then
			if GlobalState["WeatherN"] ~= GlobalState["WeatherS"] then
				SetWeatherTypeOverTime(GlobalState["WeatherS"], WeatherOverTime)

				Wait(TimeToChange)
			end

			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypeOvertimePersist(GlobalState["WeatherS"], WeatherOverTime)
			SetWeatherTypeNow(GlobalState["WeatherS"])
			SetWeatherTypePersist(GlobalState["WeatherS"])
			SetWeatherTypeNowPersist(GlobalState["WeatherS"])

			if (GlobalState["WeatherS"] == "SNOW" or GlobalState["WeatherS"] == "BLIZZARD" or GlobalState["WeatherS"] == "SNOWLIGHT" or GlobalState["WeatherS"] == "XMAS") then
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		elseif LocalPlayer["state"]["Location"] == "North" then
			if GlobalState["WeatherS"] ~= GlobalState["WeatherN"] then
				SetWeatherTypeOverTime(GlobalState["WeatherN"], WeatherOverTime)

				Wait(TimeToChange)
			end

			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypeOvertimePersist(GlobalState["WeatherN"], WeatherOverTime)
			SetWeatherTypeNow(GlobalState["WeatherN"])
			SetWeatherTypePersist(GlobalState["WeatherN"])
			SetWeatherTypeNowPersist(GlobalState["WeatherN"])

			if (GlobalState["WeatherN"] == "SNOW" or GlobalState["WeatherN"] == "BLIZZARD" or GlobalState["WeatherN"] == "SNOWLIGHT" or GlobalState["WeatherN"] == "XMAS") then
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONCLIENTRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStart",function(Resource)
	if (GetCurrentResourceName() ~= Resource) then
		return
	end

	print("Five Community Weather")
end)