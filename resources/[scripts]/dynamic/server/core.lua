-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("dynamic", Hensa)
vSKINSHOP = Tunnel.getInterface("skinshop")
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local CountClothes = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CODES
-----------------------------------------------------------------------------------------------------------------------------------------
local Codes = {
	["13"] = {
		["Message"] = "Oficial desmaiado/ferido",
		["Blip"] = 6
	},
	["20"] = {
		["Message"] = "Localização",
		["Blip"] = 6
	},
	["38"] = {
		["Message"] = "Abordagem de trânsito",
		["Blip"] = 6
	},
	["78"] = {
		["Message"] = "Apoio com prioridade",
		["Blip"] = 6
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DYNAMIC:TENCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("dynamic:Tencode")
AddEventHandler("dynamic:Tencode",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasService(Passport,"Policia") and Codes[Number] then
		local FullName = vRP.FullName(Passport)
		local Coords = vRP.GetEntityCoords(source)
		local Service = vRP.NumPermission("Policia")

		for Passports,Sources in pairs(Service) do
			async(function()
				if Number == "13" then
					TriggerClientEvent("sounds:Private",Sources,"deathcop",0.5)
				else
					vRPC.PlaySound(Sources,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
				end

				TriggerClientEvent("NotifyPush",Sources,{ code = Number, title = Codes[Number]["Message"], x = Coords["x"], y = Coords["y"], z = Coords["z"], name = FullName, color = Codes[Number]["Blip"] })
			end)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Experience()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Experiences = {
			["Caçador"] = vRP.GetExperience(Passport, "Hunter"),
			["Taxista"] = vRP.GetExperience(Passport, "Taxi"),
			["Jardineiro"] = vRP.GetExperience(Passport, "Cleaner"),
			["Lenhador"] = vRP.GetExperience(Passport, "Lumberman"),
			["Correios"] = vRP.GetExperience(Passport, "PostOp"),
			["Transportador"] = vRP.GetExperience(Passport, "Transporter"),
			["Caminhoneiro"] = vRP.GetExperience(Passport, "Trucker"),
			["Reciclagem"] = vRP.GetExperience(Passport, "Garbageman"),
			["Pescador"] = vRP.GetExperience(Passport, "Fisherman"),
			["Motorista"] = vRP.GetExperience(Passport, "Driver"),
			["Reboque"] = vRP.GetExperience(Passport, "Tows"),
			["Desmanche"] = vRP.GetExperience(Passport, "Dismantle"),
			["Entregador"] = vRP.GetExperience(Passport, "Delivery"),
			["Corredor"] = vRP.GetExperience(Passport, "Runner")
		}

		return Experiences
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PEDSTATS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.PedStats()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Stats = {
			["Likes"] = vRP.GetLikes(Passport),
			["Unlikes"] = vRP.GetUnLikes(Passport)
		}

		return Stats
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DYNAMIC:SERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("dynamic:Service")
AddEventHandler("dynamic:Service",function(Permission)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.ServiceToggle(source, Passport, Permission, false)

		TriggerClientEvent("dynamic:Close", source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DYNAMIC:EXITSERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("dynamic:ExitService")
AddEventHandler("dynamic:ExitService",function(Permission)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.ServiceLeave(source, Passport, Permission, false)

		TriggerClientEvent("dynamic:Close", source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Clothes()
	local Clothes = {}
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		CountClothes[Passport] = 2

		local Consult = vRP.GetServerData("Clothes:"..Passport)
		for Table,_ in pairs(Consult) do
			Clothes[#Clothes + 1] = Table
		end
	end

	return Clothes
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DYNAMIC:CLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("dynamic:Clothes")
AddEventHandler("dynamic:Clothes",function(Mode)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult = vRP.GetServerData("Clothes:"..Passport)
		local Split = splitString(Mode)
		local Name = Split[2]

		if Split[1] == "Save" then
			if CountTable(Consult) >= CountClothes[Passport] then
				TriggerClientEvent("Notify",source,"Armário","Limite atingide de roupas.","amarelo",5000)

				return false
			end

			local Keyboard = vKEYBOARD.Primary(source,"Nome")
			if Keyboard then
				local Check = sanitizeString(Keyboard[1],"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

				if string.len(Check) >= 4 then
					if not Consult[Check] then
						Consult[Check] = vSKINSHOP.Customization(source)
						vRP.SetServerData("Clothes:"..Passport,Consult)
						TriggerClientEvent("dynamic:AddMenu",source,Check,"Informações da vestimenta.",Check,"wardrobe")
						TriggerClientEvent("dynamic:AddButton",source,"Aplicar","Vestir-se com as vestimentas.","dynamic:Clothes","Apply-"..Check,Check,true)
						TriggerClientEvent("dynamic:AddButton",source,"Remover","Deletar a vestimenta do armário.","dynamic:Clothes","Delete-"..Check,Check,true,true)
					end
				else
					TriggerClientEvent("Notify",source,"Armário","Nome escolhido precisa possuir mínimo de 4 letras.","amarelo",5000)
				end
			end
		elseif Split[1] == "Delete" then
			if Consult[Name] then
				Consult[Name] = nil
				vRP.SetServerData("Clothes:"..Passport,Consult)
			end
		elseif Split[1] == "Apply" then
			if Consult[Name] then
				TriggerClientEvent("skinshop:Apply",source,Consult[Name])
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if CountClothes[Passport] then
		CountClothes[Passport] = nil
	end
end)