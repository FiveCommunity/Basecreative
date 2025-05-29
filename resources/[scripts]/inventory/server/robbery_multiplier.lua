-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = {
	["Register"] = {
		["Timer"] = 15,
		["Wanted"] = 60,
		["Delay"] = 3600,
		["Cooldown"] = {},
		["Percentage"] = 750,
		["Backpack"] = true,
		["Name"] = "Roubo a Registradora",
		["Residual"] = "Resquício de Línter",
		["Payment"] = {
			["List"] = {
				{ ["Item"] = "dirtydollar", ["Chance"] = 100, ["Min"] = 325, ["Max"] = 375 }
			}
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERBACKPACK
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterBackpack = {
	["mp_m_freemode_01"] = {
		["Model"] = 41,
		["Texture"] = 0
	},
	["mp_f_freemode_01"] = {
		["Model"] = 41,
		["Texture"] = 0
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:ROBBERYMULTIPLIER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:RobberyMultiplier")
AddEventHandler("inventory:RobberyMultiplier",function(Number,Mode)
	local Consult = nil
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and Config[Mode] then
		if Config[Mode]["Police"] and vRP.AmountService("Policia") < Config[Mode]["Police"] then
			TriggerClientEvent("Notify",source,"Atenção","Contingente indisponível.","amarelo",5000)

			return false
		end

		if Config[Mode]["Need"] then
			Consult = vRP.ConsultItem(Passport,Config[Mode]["Need"]["Item"],Config[Mode]["Need"]["Amount"])

			if not Consult then
				TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>"..Config[Mode]["Need"]["Amount"].."x "..ItemName(Config[Mode]["Need"]["Item"]).."</b>.","amarelo",5000)

				return false
			end
		end

		if not Config[Mode]["Cooldown"][Number] or os.time() > Config[Mode]["Cooldown"][Number] then
			Player(source)["state"]["Buttons"] = true
			Active[Passport] = os.time() + Config[Mode]["Timer"]
			TriggerClientEvent("player:Residual",source,Config[Mode]["Residual"])
			vRPC.PlayAnim(source,false,{"oddjobs@shop_robbery@rob_till","loop"},true)
			TriggerClientEvent("Progress",source,"Roubando",Config[Mode]["Timer"] * 1000)

			exports["vrp"]:CallPolice({
				["Source"] = source,
				["Passport"] = Passport,
				["Permission"] = "Policia",
				["Name"] = Config[Mode]["Name"],
				["Percentage"] = Config[Mode]["Percentage"],
				["Wanted"] = Config[Mode]["Wanted"],
				["Code"] = 31,
				["Color"] = 22
			})

			repeat
				if Active[Passport] and os.time() >= Active[Passport] then
					vRPC.Destroy(source)
					Active[Passport] = nil
					Player(source)["state"]["Buttons"] = false

					if (not Config[Mode]["Cooldown"][Number] or os.time() > Config[Mode]["Cooldown"][Number]) and not Config[Mode]["Need"] or (Config[Mode]["Need"] and Consult and vRP.ConsultItem(Passport,Consult["Item"],Config[Mode]["Need"]["Amount"]) and (not Config[Mode]["Need"]["Consume"] or (Config[Mode]["Need"]["Consume"] and vRP.TakeItem(Passport,Consult["Item"],Config[Mode]["Need"]["Amount"])))) then
						Config[Mode]["Cooldown"][Number] = os.time() + Config[Mode]["Delay"]

						local Payment = Config[Mode]["Payment"]
						if Payment and Payment["List"] then
							for _,reward in ipairs(Payment["List"]) do
								if math.random(0, 100) <= reward["Chance"] then
									local amount = math.random(reward["Min"], reward["Max"])
									vRP.GenerateItem(Passport, reward["Item"], amount, true)
									vRP.UpgradeStress(Passport, math.random(2, 4))

									if Config[Mode]["Backpack"] then
										TriggerClientEvent("skinshop:Backpack", source, RegisterBackpack)
									end

									return
								end
							end
						end
					end
				end

				Wait(100)
			until not Active[Passport]
		else
			if (Config[Mode]["Cooldown"][Number] - (Config[Mode]["Delay"] - 300)) >= os.time() then
				TriggerClientEvent("Notify",source,"Atenção","Não tem mais nada aqui.","amarelo",5000)
			else
				TriggerClientEvent("Notify",source,"Atenção","Aguarde "..CompleteTimers(Config[Mode]["Cooldown"][Number] - os.time())..".","azul",5000)
			end
		end
	end
end)