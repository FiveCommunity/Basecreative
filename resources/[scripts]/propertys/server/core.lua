-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("propertys",Hensa)
vKEYBOARD = Tunnel.getInterface("keyboard")
vSKINSHOP = Tunnel.getInterface("skinshop")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Lock = {}
local Saved = {}
local Inside = {}
local Active = {}
local Robbery = {}
local CountClothes = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALVARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState["Markers"] = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:ROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Robbery")
AddEventHandler("propertys:Robbery",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true
		TriggerClientEvent("dynamic:Close",source)

		local Service = vRP.HasService(Passport,"Policia")
		local Lockpick = vRP.ConsultItem(Passport,"lockpick")
		local Consult = vRP.Query("propertys/Exist",{ Name = Name })
		local LockpickPlus = vRP.ConsultItem(Passport,"lockpickplus")
		if (not Consult[1] or (Consult[1] and Consult[1]["Interior"] ~= "Galpão")) and (Service or ((Lockpick or LockpickPlus) and vRP.Task(source,5,5000))) then
			if not Saved[Name] then
				Saved[Name] = (Consult[1] and Consult[1]["Interior"] or exports["propertys"]:Informations())
			end

			if not Robbery[Name] then
				Robbery[Name] = {}
			end

			if not Service then
				if Lockpick then
					vRP.RemoveItem(Passport,Lockpick["Item"],1,true)
				end

				if Consult[1] then
					local Online = vRP.Source(Consult[1]["Passport"])
					if Online then
						TriggerClientEvent("Notify",Online,"Alerta de Segurança","Sua propriedade está sendo invadida, chame as autoridades para ajudar no local.","policia",5000)
					end
				end
			end

			TriggerClientEvent("propertys:Enter",source,Name,Saved[Name])
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:ROBBERYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:RobberyItem")
AddEventHandler("propertys:RobberyItem",function(Number,Name)
	local ItemList = nil
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Robbery[Name] then
		local Lockpick = vRP.ConsultItem(Passport,"lockpick")
		if Lockpick or vRP.ConsultItem(Passport,"lockpickplus") then
			if not Robbery[Name][Number] then
				if (Number == "Locker" and not vRP.Safecrack(source,6)) or (Number ~= "Locker" and not vRP.Task(source,5,5000)) then
					if Lockpick and math.random(100) >= 95 then
						vRP.RemoveItem(Passport,Lockpick["Item"],1,true)
					end

					TriggerClientEvent("sounds:Area",-1,"alarm",1.0,Propertys[Name]["Coords"],75)
					TriggerClientEvent("sounds:Area",-1,"alarm",1.0,vRP.GetEntityCoords(source),125,GetPlayerRoutingBucket(source))

					exports["vrp"]:CallPolice({
						["Source"] = source,
						["Passport"] = Passport,
						["Coords"] = Propertys[Name]["Coords"],
						["Permission"] = "Policia",
						["Name"] = "Roubo a Propriedade",
						["Wanted"] = 30,
						["Code"] = 31,
						["Color"] = 44
					})

					return false
				end

				if Number == "Locker" then
					ItemList = LockerItens
				else
					ItemList = OtherItens
				end

				Robbery[Name][Number] = true
				TriggerClientEvent("propertys:RemCircleZone",source,Number)

				for _,reward in ipairs(ItemList) do
					if math.random(0, 225) <= reward["Chance"] then
						local amount = math.random(reward["Min"], reward["Max"])
						vRP.GenerateItem(Passport, reward["Item"], amount, true)
						return
					end
				end
			else
				TriggerClientEvent("Notify",source,"Atenção","Não tem mais nada aqui.","amarelo",5000)
			end
		else
			TriggerClientEvent("Notify",source,"Atenção","Você precisa de alguma <b>Lockpick</b>.","amarelo",5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Police(Outside,Inside)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		TriggerClientEvent("sounds:Area",-1,"alarm",1.0,Outside,75)
		TriggerClientEvent("sounds:Area",-1,"alarm",1.0,Inside,125,GetPlayerRoutingBucket(source))

		exports["vrp"]:CallPolice({
			["Source"] = source,
			["Passport"] = Passport,
			["Coords"] = Outside,
			["Permission"] = "Policia",
			["Name"] = "Roubo a Propriedade",
			["Wanted"] = 300,
			["Code"] = 31,
			["Color"] = 44
		})
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Propertys(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if Name == "Hotel" then
			local Consult = vRP.Query("propertys/Count",{ Passport = Passport })
			if Consult[1] then
				local Count = Consult[1]["COUNT(Passport)"]
				if Count <= 0 then
					return "Hotel"
				end
			end
		else
			local Consult = vRP.Query("propertys/Exist",{ Name = Name })
			if Consult[1] then
				if Consult[1]["Passport"] == Passport or vRP.InventoryFull(Passport,"propertys-"..Consult[1]["Serial"]) or Lock[Name] then
					if not Saved[Name] then
						Saved[Name] = Consult[1]["Interior"]
					end

					local Interior = Saved[Name]
					local Price = Informations[Interior]["Price"] * 0.25
					local Tax = CompleteTimers(Consult[1]["Tax"] - os.time())

					if os.time() > Consult[1]["Tax"] then
						Tax = "Efetue o pagamento da <b>Hipoteca</b>."

						if vRP.Request(source,"Propriedades","Deseja pagar a hipoteca de <b>$"..Dotted(Price).."</b>?") and vRP.PaymentFull(Passport,Price) then
							TriggerClientEvent("Notify",source,"Propriedades","Pagamento concluído.","verde",5000)
							vRP.Query("propertys/Tax",{ Name = Name })
							Tax = CompleteTimers(2592000)
						else
							return false
						end
					end

					return {
						["Interior"] = Interior,
						["Tax"] = Tax
					}
				end
			else
				return "Nothing"
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Toggle(Name,Mode)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if Mode == "Exit" then
			Inside[Passport] = nil
			exports["vrp"]:Bucket(source,"Exit")
		else
			Inside[Passport] = Propertys[Name]["Coords"]

			if Name == "Hotel" then
				exports["vrp"]:Bucket(source,"Enter",200000 + Passport)
			else
				exports["vrp"]:Bucket(source,"Enter",100000 + RouteNumber(Name))
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTENUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function RouteNumber(Name)
	local Name = Name
	local Route = string.sub(Name,-4)

	return parseInt(Route)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:BUY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Buy")
AddEventHandler("propertys:Buy",function(Name)
	local source = source
	local Split = splitString(Name)
	local Passport = vRP.Passport(source)
	if Passport and not exports["bank"]:CheckFines(Passport) then
		local Name,Interior,Mode = Split[1],Split[2],Split[3]

		local Consult = vRP.Query("propertys/Exist",{ Name = Name })
		if not Consult[1] then
			TriggerClientEvent("dynamic:Close",source)

			if vRP.Request(source,"Propriedades","Deseja comprar a propriedade?") then
				local Serial = PropertysSerials()

				if Mode == "Dollar" then
					if vRP.PaymentFull(Passport,Informations[Interior]["Price"]) then
						local Markers = GlobalState["Markers"]
						Markers[Name] = true
						GlobalState:set("Markers",Markers,true)

						Saved[Name] = Interior
						vRP.GiveItem(Passport,"propertys-"..Serial,3,true)
						TriggerClientEvent("Notify",source,"Propriedades","Compra concluída.","verde",5000)
						exports["bank"]:AddTaxs(Passport,source,"Propriedades",Informations[Interior]["Price"],"Compra de propriedade.")
						vRP.Query("propertys/Buy",{ Name = Name, Interior = Interior, Passport = Passport, Serial = Serial, Vault = Informations[Interior]["Vault"] or 0, Fridge = Informations[Interior]["Fridge"] or 0, Tax = os.time() + 2592000 })
					else
						TriggerClientEvent("Notify",source,"Propriedades","<b>Dólares</b> insuficientes.","amarelo",5000)
					end
				elseif Mode == "Gemstone" then
					if vRP.PaymentGemstone(Passport,Informations[Interior]["Gemstone"]) then
						local Markers = GlobalState["Markers"]
						Markers[Name] = true
						GlobalState:set("Markers",Markers,true)

						Saved[Name] = Interior
						vRP.GiveItem(Passport,"propertys-"..Serial,3,true)
						TriggerClientEvent("Notify",source,"Propriedades","Compra concluída.","verde",5000)
						vRP.Query("propertys/Buy",{ Name = Name, Interior = Interior, Passport = Passport, Serial = Serial, Vault = Informations[Interior]["Vault"] or 0, Fridge = Informations[Interior]["Fridge"] or 0, Tax = os.time() + 31104000 })
					else
						TriggerClientEvent("Notify",source,"Propriedades","<b>Diamantes</b> insuficientes.","amarelo",5000)
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:LOCK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Lock")
AddEventHandler("propertys:Lock",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	local Consult = vRP.Query("propertys/Exist",{ Name = Name })
	if Passport and Consult[1] and (vRP.InventoryFull(Passport,"propertys-"..Consult[1]["Serial"]) or Consult[1]["Passport"] == Passport) then
		if Lock[Name] then
			Lock[Name] = nil
			TriggerClientEvent("Notify",source,"Aviso","Propriedade trancada.","default",5000)
		else
			Lock[Name] = true
			TriggerClientEvent("Notify",source,"Aviso","Propriedade destrancada.","default",5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:SELL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Sell")
AddEventHandler("propertys:Sell",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		local Consult = vRP.Query("propertys/Exist",{ Name = Name })
		if Consult[1] and Consult[1]["Passport"] == Passport then
			TriggerClientEvent("dynamic:Close",source)

			local Interior = Consult[1]["Interior"]
			local Price = Informations[Interior]["Price"] * 0.25
			if vRP.Request(source,"Propriedades","Vender por <b>$"..Dotted(Price).."</b>?") then
				if GlobalState["Markers"][Name] then
					local Markers = GlobalState["Markers"]
					Markers[Name] = nil
					GlobalState:set("Markers",Markers,true)
				end

				vRP.GiveBank(Passport,Price)
				vRP.RemoveServerData("Vault:"..Name)
				vRP.RemoveServerData("Fridge:"..Name)
				vRP.Query("propertys/Sell",{ Name = Name })
				TriggerClientEvent("garages:Clean",-1,Name)
				TriggerClientEvent("Notify",source,"Propriedades","Venda concluída.","verde",5000)
			end
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:TRANSFER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Transfer")
AddEventHandler("propertys:Transfer",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and not exports["bank"]:CheckFines(Passport) then
		Active[Passport] = true

		local Consult = vRP.Query("propertys/Exist",{ Name = Name })
		if Consult[1] and Consult[1]["Passport"] == Passport then
			TriggerClientEvent("dynamic:Close",source)

			local Keyboard = vKEYBOARD.Primary(source,"Passaporte")
			if Keyboard and vRP.Identity(Keyboard[1]) and vRP.Request(source,"Propriedades","Deseja trasnferir a propriedade para passaporte <b>"..Keyboard[1].."</b>?") then
				vRP.Query("propertys/Transfer",{ Name = Name, Passport = Keyboard[1] })
				TriggerClientEvent("Notify",source,"Propriedades","Transferência concluída.","verde",5000)
			end
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:CREDENTIALS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Credentials")
AddEventHandler("propertys:Credentials",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	local Consult = vRP.Query("propertys/Exist",{ Name = Name })
	if Passport and Consult[1] and Consult[1]["Passport"] == Passport then
		TriggerClientEvent("dynamic:Close",source)

		if vRP.Request(source,"Propriedades","Lembre-se que ao prosseguir todos os cartões vão deixar de funcionar, deseja prosseguir?") then
			local Serial = PropertysSerials()
			vRP.Query("propertys/Credentials",{ Name = Name, Serial = Serial })
			vRP.GiveItem(Passport,"propertys-"..Serial,Consult[1]["Item"],true)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:ITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Item")
AddEventHandler("propertys:Item",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	local Consult = vRP.Query("propertys/Exist",{ Name = Name })
	if Passport and Consult[1] and Consult[1]["Passport"] == Passport and Consult[1]["Item"] < 5 then
		TriggerClientEvent("dynamic:Close",source)

		if vRP.Request(source,"Propriedades","Comprar uma chave adicional por <b>$150.000</b> dólares?") then
			if vRP.PaymentFull(Passport,150000) then
				vRP.Query("propertys/Item",{ Name = Name })
				vRP.GiveItem(Passport,"propertys-"..Consult[1]["Serial"],1,true)
			else
				TriggerClientEvent("Notify",source,"Aviso","<b>Dólares</b> insuficientes.","amarelo",5000)
			end
		end
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

		local Consult = vRP.GetServerData("Wardrobe:"..Passport)
		for Table,_ in pairs(Consult) do
			Clothes[#Clothes + 1] = Table
		end
	end

	return Clothes
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS:CLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("propertys:Clothes")
AddEventHandler("propertys:Clothes",function(Mode)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult = vRP.GetServerData("Wardrobe:"..Passport)
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
						vRP.SetServerData("Wardrobe:"..Passport,Consult)
						TriggerClientEvent("dynamic:AddMenu",source,Check,"Informações da vestimenta.",Check,"wardrobe")
						TriggerClientEvent("dynamic:AddButton",source,"Aplicar","Vestir-se com as vestimentas.","propertys:Clothes","Apply-"..Check,Check,true)
						TriggerClientEvent("dynamic:AddButton",source,"Remover","Deletar a vestimenta do armário.","propertys:Clothes","Delete-"..Check,Check,true,true)
					end
				else
					TriggerClientEvent("Notify",source,"Armário","Nome escolhido precisa possuir mínimo de 4 letras.","amarelo",5000)
				end
			end
		elseif Split[1] == "Delete" then
			if Consult[Name] then
				Consult[Name] = nil
				vRP.SetServerData("Wardrobe:"..Passport,Consult)
			end
		elseif Split[1] == "Apply" then
			if Consult[Name] then
				TriggerClientEvent("skinshop:Apply",source,Consult[Name])
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYSSERIALS
-----------------------------------------------------------------------------------------------------------------------------------------
function PropertysSerials()
	repeat
		Serial = GenerateString("LDLDLDLDLD")
		Consult = vRP.Query("propertys/Serial",{ Serial = Serial })
	until Serial and not Consult[1]

	return Serial
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Permission(Name)
	local source = source
	local Passport = vRP.Passport(source)
	local Consult = vRP.Query("propertys/Exist",{ Name = Name })
	if Passport and (Name == "Hotel" or Consult[1] and (vRP.InventoryFull(Passport,"propertys-"..Consult[1]["Serial"]) or Consult[1]["Passport"] == Passport)) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Mount(Name,Mode)
	local Weight = 25
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Name and Mode then
		if Name == "Hotel" then
			Name = "Hotel:"..Passport
		else
			Weight = vRP.Query("propertys/Exist",{ Name = Name })[1][Mode]
		end

		local Primary = {}
		local Inv = vRP.Inventory(Passport)
		local Consult = vRP.GetServerData(Mode..":"..Name)

		for Index,v in pairs(Inv) do
			v["name"] = ItemName(v["item"])
			v["weight"] = ItemWeight(v["item"])
			v["index"] = ItemIndex(v["item"])
			v["amount"] = parseInt(v["amount"])
			v["rarity"] = ItemRarity(v["item"])
			v["economy"] = ItemEconomy(v["item"])
			v["desc"] = ItemDescription(v["item"])
			v["key"] = v["item"]
			v["slot"] = Index

			local Split = splitString(v["item"])

			if not v["desc"] then
				if Split[1] == "vehkey" and Split[2] then
					v["desc"] = "Placa do Veículo: <common>"..Split[2].."</common>"
				elseif ItemNamed(Split[1]) and Split[2] then
					if Split[1] == "identity" then
						v["desc"] = "Passaporte: <rare>"..Dotted(Split[2]).."</rare><br>Nome: <rare>"..vRP.FullName(Split[2]).."</rare><br>Tipo Sangüineo: <rare>"..Sanguine(vRP.Identity(Split[2])["Blood"]).."</rare>"
					else
						v["desc"] = "Propriedade: <common>"..vRP.FullName(Split[2]).."</common>"
					end
				end
			end

			if Split[2] then
				local Loaded = ItemLoads(v["item"])
				if Loaded then
					v["charges"] = parseInt(Split[2] * (100 / Loaded))
				end

				if ItemDurability(v["item"]) then
					v["durability"] = parseInt(os.time() - Split[2])
					v["days"] = ItemDurability(v["item"])
				end
			end

			Primary[Index] = v
		end

		local Secondary = {}
		for Index,v in pairs(Consult) do
			v["name"] = ItemName(v["item"])
			v["weight"] = ItemWeight(v["item"])
			v["index"] = ItemIndex(v["item"])
			v["amount"] = parseInt(v["amount"])
			v["rarity"] = ItemRarity(v["item"])
			v["economy"] = ItemEconomy(v["item"])
			v["desc"] = ItemDescription(v["item"])
			v["key"] = v["item"]
			v["slot"] = Index

			local Split = splitString(v["item"])

			if not v["desc"] then
				if Split[1] == "vehkey" and Split[2] then
					v["desc"] = "Placa do Veículo: <common>"..Split[2].."</common>"
				elseif ItemNamed(Split[1]) and Split[2] then
					if Split[1] == "identity" then
						v["desc"] = "Passaporte: <rare>"..Dotted(Split[2]).."</rare><br>Nome: <rare>"..vRP.FullName(Split[2]).."</rare><br>Tipo Sangüineo: <rare>"..Sanguine(vRP.Identity(Split[2])["Blood"]).."</rare>"
					else
						v["desc"] = "Propriedade: <common>"..vRP.FullName(Split[2]).."</common>"
					end
				end
			end

			if Split[2] then
				local Loaded = ItemLoads(v["item"])
				if Loaded then
					v["charges"] = parseInt(Split[2] * (100 / Loaded))
				end

				if ItemDurability(v["item"]) then
					v["durability"] = parseInt(os.time() - Split[2])
					v["days"] = ItemDurability(v["item"])
				end
			end

			Secondary[Index] = v
		end

		return Primary,Secondary,vRP.GetWeight(Passport),Weight
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Store(Item,Slot,Amount,Target,Name,Mode)
	local source = source
	local Amount = parseInt(Amount,true)
	local Passport = vRP.Passport(source)
	if Passport then
		if (Mode == "Vault" and ItemFridge(Item)) or (Mode == "Fridge" and not ItemFridge(Item)) then
			TriggerClientEvent("inventory:Update",source)

			return false
		end

		if Name == "Hotel" then
			if vRP.StoreChest(Passport,Mode..":Hotel:"..Passport,Amount,25,Slot,Target) then
				TriggerClientEvent("inventory:Update",source)
			end
		else
			local Consult = vRP.Query("propertys/Exist",{ Name = Name })
			if Consult[1] then
				if Item == "diagram" then
					if vRP.TakeItem(Passport,Item,Amount,false,Slot) then
						vRP.Query("propertys/"..Mode,{ Name = Name, Weight = 10 * Amount })
						TriggerClientEvent("inventory:Update",source)
					end
				else
					if vRP.StoreChest(Passport,Mode..":"..Name,Amount,Consult[1][Mode],Slot,Target) then
						TriggerClientEvent("inventory:Update",source)
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Take(Slot,Amount,Target,Name,Mode)
	local source = source
	local Amount = parseInt(Amount,true)
	local Passport = vRP.Passport(source)
	if Passport then
		if Name == "Hotel" then
			if vRP.TakeChest(Passport,Mode..":Hotel:"..Passport,Amount,Slot,Target) then
				TriggerClientEvent("inventory:Update",source)
			end
		else
			if vRP.TakeChest(Passport,Mode..":"..Name,Amount,Slot,Target) then
				TriggerClientEvent("inventory:Update",source)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Update(Slot,Target,Amount,Name,Mode)
	local source = source
	local Amount = parseInt(Amount,true)
	local Passport = vRP.Passport(source)
	if Passport then
		if Name == "Hotel" then
			Name = "Hotel:"..Passport
		end

		if vRP.UpdateChest(Passport,Mode..":"..Name,Slot,Target,Amount) then
			TriggerClientEvent("inventory:Update",source)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Inside[Passport] then
		vRP.InsidePropertys(Passport,Inside[Passport])
		Inside[Passport] = nil
	end

	if CountClothes[Passport] then
		CountClothes[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Markers = GlobalState["Markers"]
	for _,v in pairs(vRP.Query("propertys/All")) do
		local Name = v["Name"]
		if Propertys[Name] then
			Markers[Name] = true
		end
	end

	GlobalState:set("Markers",Markers,true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHOSENCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("ChosenCharacter",function(Passport,source)
	local Increments = {}

	local Consult = vRP.Query("propertys/Count", { Passport = Passport })
	if Consult[1] then
		local Count = Consult[1]["COUNT(Passport)"]
		if Count <= 0 then
			Increments[#Increments + 1] = Propertys["Hotel"]["Coords"]
		else
			local All = vRP.Query("propertys/AllUser",{ Passport = Passport })
			if All[1] then
				for _,v in pairs(All) do
					local Name = v["Name"]
					if Propertys[Name] then
						Increments[#Increments + 1] = Propertys[Name]["Coords"]
					end
				end
			end
		end
	end

	TriggerClientEvent("spawn:Increment",source,Increments)
end)