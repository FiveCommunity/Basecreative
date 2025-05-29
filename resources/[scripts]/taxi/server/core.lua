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
Tunnel.bindInterface("taxi",Hensa)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Service(Result)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local TaxiPermission, TaxiHierarchy = "Taxi", 1

		if Result then
			if not vRP.HasPermission(Passport, TaxiPermission) then
				vRP.SetPermission(Passport, TaxiPermission, TaxiHierarchy)
			end
		else
			if vRP.HasPermission(Passport, TaxiPermission) then
				vRP.RemovePermission(Passport, TaxiPermission)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Payment(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and Locations[Selected] then
		Active[Passport] = true

		local Coords = vRP.GetEntityCoords(source)
		if not Selected or not vRPC.LastVehicle(source,"taxi") or #(Coords - Locations[Selected]["Vehicle"]) > 5 then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Taxista\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		local GainExperience = 3
		local Amount = math.random(275,325)
		local Experience = vRP.GetExperience(Passport,"Taxi")
		local Valuation = Amount + Amount * (0.05 * Experience)

		if exports["inventory"]:Buffs("Dexterity",Passport) then
			Valuation = Valuation + (Valuation * 0.1)
		end

		if vRP.UserPremium(Passport) then
			local Hierarchy = vRP.LevelPremium(Passport)
			local Bonification = (Hierarchy == 1 and 0.100) or (Hierarchy == 2 and 0.075) or (Hierarchy >= 3 and 0.050)

			Valuation = Valuation + (Valuation * Bonification)
			GainExperience = GainExperience + 2
		end

		vRP.GenerateItem(Passport,"dollar",Valuation,true)
		vRP.PutExperience(Passport,"Taxi",GainExperience)
		vRP.UpgradeStress(Passport,3)

		Active[Passport] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Active[Passport] then
		Active[Passport] = nil
	end

	if Passport and vRP.HasPermission(Passport, "Taxi") then
		vRP.RemovePermission(Passport, "Taxi")
	end
end)