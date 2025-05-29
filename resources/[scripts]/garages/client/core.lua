-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("garages", Hensa)
vSERVER = Tunnel.getInterface("garages")
-----------------------------------------------------------------------------------------------------------------------------------------
-- DECORATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
DecorRegister("Player_Vehicle", 3)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local Opened = "1"
local Searched = nil
local Hotwired = false
local Anim = "machinic_loop_mechandplayer"
local Dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLEMODS
-----------------------------------------------------------------------------------------------------------------------------------------
function VehicleMods(Vehicle,Customize)
	TriggerEvent("lscustoms:Apply",Vehicle,Customize)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNPOSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.SpawnPosition(Select)
	local Slot = "0"
	local Checks = 0
	local Selected = {}
	local Position = nil

	repeat
		Checks = Checks + 1

		Slot = tostring(Checks)
		if GaragesCoords[Select] and GaragesCoords[Select][Slot] then
			Selected = vec4(GaragesCoords[Select][Slot][1],GaragesCoords[Select][Slot][2],GaragesCoords[Select][Slot][3],GaragesCoords[Select][Slot][4])
			Position = GetClosestVehicle(GaragesCoords[Select][Slot][1],GaragesCoords[Select][Slot][2],GaragesCoords[Select][Slot][3],2.75,0,127)
		end
	until not DoesEntityExist(Position) or not GaragesCoords[Select][Slot]

	if not GaragesCoords[Select][tostring(Checks)] then
		TriggerEvent("Notify","Atenção","Todas as vagas estão ocupadas.","default",5000)

		return false
	end

	SendNUIMessage({ Action = "Close" })
	SetNuiFocus(false,false)

	return Selected
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.CreateVehicle(Model, Network, Engine, Health, Customize, Windows, Tyres, Brakes, Admin)
	local Count = 0

	while not NetworkDoesNetworkIdExist(Network) do
		Count = Count + 1

		if Count >= 1000 then
			Count = 0
			break
		end

		Wait(10)
	end

	local Vehicle = NetToEnt(Network)
	while not DoesEntityExist(Vehicle) do
		Count = Count + 1

		if Count >= 1000 then
			Count = 0
			break
		end

		Wait(10)
	end

	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) then

			if Customize ~= nil then
				local Mods = json.decode(Customize)
				VehicleMods(Vehicle, Mods)
			end

			if Brakes[1] ~= nil then
				if Brakes[1] > 0.90 then
					Brakes[1] = 0.90
				end
			end

			if Brakes[2] ~= nil then
				if Brakes[2] > 0.55 then
					Brakes[2] = 0.55
				end
			end

			if Brakes[3] ~= nil then
				if Brakes[3] > 0.75 then
					Brakes[3] = 0.75
				end
			end

			SetVehicleHandlingFloat(Vehicle, "CHandlingData", "fBrakeForce", Brakes[1] or 0.90)
			SetVehicleHandlingFloat(Vehicle, "CHandlingData", "fBrakeBiasFront", Brakes[2] or 0.55)
			SetVehicleHandlingFloat(Vehicle, "CHandlingData", "fHandBrakeForce", Brakes[3] or 0.75)

			SetVehicleEngineHealth(Vehicle, Engine + 0.0)
			SetVehicleHasBeenOwnedByPlayer(Vehicle, true)
			SetVehicleNeedsToBeHotwired(Vehicle, false)
			DecorSetInt(Vehicle, "Player_Vehicle", -1)
			SetVehicleOnGroundProperly(Vehicle)
			SetVehRadioStation(Vehicle, "OFF")
			SetEntityHealth(Vehicle, Health)

			if Admin then
				local r, g, b = HexToRGB(Theme["main"])
				SetVehicleCustomPrimaryColour(Vehicle, r, g, b)
				SetVehicleCustomSecondaryColour(Vehicle, r, g, b)
			end

			if Windows then
				local Windows = json.decode(Windows)
				if Windows ~= nil then
					for Index, v in pairs(Windows) do
						if not v then
							RemoveVehicleWindow(Vehicle, parseInt(Index))
						end
					end
				end
			end

			if Tyres then
				local Tyres = json.decode(Tyres)
				if Tyres ~= nil then
					for Index, Burst in pairs(Tyres) do
						if Burst then
							SetVehicleTyreBurst(Vehicle, parseInt(Index), true, 1000.0)
						end
					end
				end
			end

			if not DecorExistOn(Vehicle, "Player_Vehicle") then
				DecorSetInt(Vehicle, "Player_Vehicle", -1)
			end

			if GetVehicleClass(Vehicle) == 14 then
				SetBoatAnchor(Vehicle, true)
			end

			SetModelAsNoLongerNeeded(Model)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:Delete")
AddEventHandler("garages:Delete", function(Vehicle)
	if not Vehicle or Vehicle == "" then
		Vehicle = vRP.ClosestVehicle(15)
	end

	if IsEntityAVehicle(Vehicle) and (not Entity(Vehicle)["state"]["Tow"] or LocalPlayer["state"]["Admin"]) then
		local Tyres = {}
		local Doors = {}
		local Windows = {}

		for i = 0, 5 do
			Doors[i] = IsVehicleDoorDamaged(Vehicle, i)
		end

		for i = 0, 5 do
			Windows[i] = IsVehicleWindowIntact(Vehicle, i)
		end

		for i = 0, 7 do
			local Status = false

			if GetTyreHealth(Vehicle, i) ~= 1000.0 then
				Status = true
			end

			Tyres[i] = Status
		end

		if DecorExistOn(Vehicle, "Player_Vehicle") then
			DecorRemove(Vehicle, "Player_Vehicle")
		end

		vSERVER.Delete(VehToNet(Vehicle), GetEntityHealth(Vehicle), GetVehicleEngineHealth(Vehicle), GetVehicleBodyHealth(Vehicle), GetVehicleFuelLevel(Vehicle), Doors, Windows, Tyres, GetVehicleNumberPlateText(Vehicle), { GetVehicleHandlingFloat(Vehicle, "CHandlingData", "fBrakeForce"), GetVehicleHandlingFloat(Vehicle, "CHandlingData", "fBrakeBiasFront"), GetVehicleHandlingFloat(Vehicle, "CHandlingData", "fHandBrakeForce") })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHBLIP
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.SearchBlip(Coords)
	if DoesBlipExist(Searched) then
		RemoveBlip(Searched)
		Searched = nil
	end

	if type(Coords) == "string" then
		Coords = vec3(GaragesCoords[Coords]["x"],GaragesCoords[Coords]["y"],GaragesCoords[Coords]["z"])
	end

	Searched = AddBlipForCoord(Coords["x"], Coords["y"], Coords["z"])
	SetBlipSprite(Searched, 225)
	SetBlipColour(Searched, 77)
	SetBlipScale(Searched, 0.6)
	SetBlipAsShortRange(Searched, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Veículo")
	EndTextCommandSetBlipName(Searched)

	SetTimeout(30000, function()
		RemoveBlip(Searched)
		Searched = nil
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.StartHotwired()
	local Ped = PlayerPedId()
	if not Hotwired and LoadAnim(Dict) then
		TaskPlayAnim(Ped, Dict, Anim, 8.0, 8.0, -1, 49, 1, 0, 0, 0)
		Hotwired = true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.StopHotwired(Vehicle)
	local Ped = PlayerPedId()
	if Hotwired and LoadAnim(Dict) then
		StopAnimTask(Ped, Dict, Anim, 8.0)
		Hotwired = false
	end

	if Vehicle then
		SetVehicleHasBeenOwnedByPlayer(Vehicle, true)
		SetVehicleNeedsToBeHotwired(Vehicle, false)
		DecorSetInt(Vehicle, "Player_Vehicle", -1)
		SetVehRadioStation(Vehicle, "OFF")
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.UpdateHotwired(Status)
	Hotwired = Status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERDECORS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.RegisterDecors(Vehicle)
	SetVehicleHasBeenOwnedByPlayer(Vehicle, true)
	SetVehicleNeedsToBeHotwired(Vehicle, false)
	DecorSetInt(Vehicle, "Player_Vehicle", -1)
	SetVehRadioStation(Vehicle, "OFF")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOPHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999

		local Ped = PlayerPedId()
		if IsPedInAnyVehicle(Ped) then
			local Vehicle = GetVehiclePedIsUsing(Ped)
			local Plate = GetVehicleNumberPlateText(Vehicle)
			if GetPedInVehicleSeat(Vehicle, -1) == Ped and Plate ~= "PDMSPORT" and not GlobalState["Plates"][Plate] and not Entity(Vehicle)["state"]["Lockpick"] then
				SetVehicleEngineOn(Vehicle, false, true, true)
				DisablePlayerFiring(Ped, true)
				TimeDistance = 1
			end

			if Hotwired and Vehicle then
				DisableControlAction(0, 75, true)
				DisableControlAction(0, 20, true)
				TimeDistance = 1
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:IMPOUND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:Impound")
AddEventHandler("garages:Impound", function()
	local Impound = vSERVER.Impound()
	if parseInt(#Impound) > 0 then
		for k,v in pairs(Impound) do
			exports["dynamic"]:AddButton(v["Name"], "Clique para efetuar a liberação.", "garages:Impound", v["Model"], false, true)
		end

		exports["dynamic"]:Open()
	else
		TriggerEvent("Notify", "Impound", "Você não possui veículos apreendidos.", "policia", 5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADOPEN
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()
		if not IsPedInAnyVehicle(Ped) then
			local Coords = GetEntityCoords(Ped)

			for Number,v in pairs(GaragesCoords) do
				local Distance = #(Coords - vec3(v["x"],v["y"],v["z"]))
				if Distance <= 3.25 then
					TimeDistance = 1

					SetDrawOrigin(v["x"],v["y"],v["z"])
					DrawSprite("Textures","E",0.0,0.0,0.02,0.02 * GetAspectRatio(false),0.0,255,255,255,255)
					ClearDrawOrigin()

					if Distance <= 1.25 and IsControlJustPressed(1,38) and vSERVER.Check() then
						local Vehicles = vSERVER.Vehicles(Number)
						if Vehicles then
							Opened = Number
							SetNuiFocus(true,true)
							TriggerEvent("target:Debug")
							SendNUIMessage({ Action = "Open", Payload = Vehicles })
						end
					end
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:Close")
AddEventHandler("garages:Close",function()
	SendNUIMessage({ Action = "Close" })
	SetNuiFocus(false,false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Close",function(Data,Callback)
	SetNuiFocus(false,false)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Spawn",function(Data,Callback)
	vSERVER.Spawn(Data["Model"], Opened)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Delete",function(Data,Callback)
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	for Number, v in pairs(GaragesCoords) do
		local Distance = #(Coords - vec3(v["x"], v["y"], v["z"]))
		if Distance <= StoreVehiclesDistance then
			if vSERVER.PaymentStore(Number) then
				TriggerEvent("garages:Delete")
			end
		end
	end

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SELL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Sell",function(Data,Callback)
	vSERVER.Sell(Data["Model"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Transfer",function(Data,Callback)
	vSERVER.Transfer(Data["Model"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Tax",function(Data,Callback)
	vSERVER.Tax(Data["Model"])

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:PROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:Propertys")
AddEventHandler("garages:Propertys", function(Table)
	for Name, v in pairs(Table) do
		GaragesCoords[Name] = {
			["x"] = v["x"],
			["y"] = v["y"],
			["z"] = v["z"],
			["1"] = v["1"]
		}
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:CLEAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:Clean")
AddEventHandler("garages:Clean", function(Name)
	if GaragesCoords[Name] then
		GaragesCoords[Name] = nil
	end
end)