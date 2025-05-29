-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("lscustoms",Hensa)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local InVehicle = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Permission(Index)
	local source = source
	local Passport = vRP.Passport(source)
	local Permission = Locations[Index]["Permission"]
	if Passport then
		if not Permission then
			return true
		else
			if vRP.HasService(Passport,Permission) then
				return true
			else
				TriggerClientEvent("Notify", source, "Atenção", "Você não tem permissões.", "amarelo", 5000)
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Save(Model,Plate,Mods,Price)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if vRP.PaymentFull(Passport,Price) then
			local TheVehicle = vRP.Query("vehicles/plateVehicles", { Plate = Plate })
			if TheVehicle[1] then
				vRP.Query("entitydata/SetData",{ Name = "LsCustoms:"..TheVehicle[1]["Passport"]..":"..Model..":"..TheVehicle[1]["id"], Information = json.encode(Mods) })
				vRP.UpgradeStress(Passport, math.random(5))

				TriggerClientEvent("Notify", source, "Sucesso", "Você modificou um veículo registrado.", "verde", 5000)
			else
				if CallPolices then
					TriggerClientEvent("Notify", source, "Atenção", "Você modificou um veículo sem registro e a polícia foi acionada.", "amarelo", 5000)

					exports["vrp"]:CallPolice({ ["Source"] = source, ["Passport"] = Passport, ["Permission"] = "Policia", ["Name"] = "Possível veículo roubado", ["Code"] = 20, ["Color"] = 16 })
				else
					TriggerClientEvent("Notify", source, "Atenção", "Você modificou um veículo sem registro.", "amarelo", 5000)
				end
			end

			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LSCUSTOMS:NETWORK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("lscustoms:Network")
AddEventHandler("lscustoms:Network",function(Network,Plate)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if not Network then
			if InVehicle[Passport] then
				InVehicle[Passport] = nil
			end
		else
			InVehicle[Passport] = { Network,Plate }
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if InVehicle[Passport] then
		SetTimeout(1000,function()
			TriggerEvent("garages:deleteVehicle",InVehicle[Passport][1],InVehicle[Passport][2])
			InVehicle[Passport] = nil
		end)
	end
end)