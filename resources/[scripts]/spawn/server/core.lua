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
Tunnel.bindInterface("spawn", Hensa)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Route = 50000
local Licensed = {}
local Connected = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Characters()
	local source = source
	local License = vRP.Identities(source)

	local source = source
	local License = vRP.Identities(source)
	local Consult = vRP.Query("characters/Characters",{ License = License })

	Route = Route + 1
	exports["vrp"]:Bucket(source,"Enter",Route)

	local Characters = {}
	for _,v in pairs(Consult) do
		local Passport = parseInt(v["id"])

		Characters[#Characters + 1] = {
			["Passport"] = Passport,
			["Skin"] = v["Skin"],
			["Nome"] = v["Name"].." "..v["Lastname"],
			["Sexo"] = v["Sex"],
			["Banco"] = v["Bank"],
			["Blood"] = Sanguine(v["Blood"]),
			["Clothes"] = vRP.UserData(Passport,"Clothings"),
			["Barber"] = vRP.UserData(Passport,"Barbershop"),
			["Tattoos"] = vRP.UserData(Passport,"Tattooshop")
		}
	end

	return Characters
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.ChosenCharacter(Passport)
	local Return = false
	local source = source
	local License = vRP.Identities(source)
	local Consult = vRP.Query("characters/UserLicense",{ id = Passport, License = License })

	if Consult[1] and not Licensed[License] then
		exports["vrp"]:Bucket(source,"Exit")
		vRP.ChosenCharacter(source,Passport)
		Connected[Passport] = License
		Licensed[License] = true
		Return = true
	else
		DropPlayer(source, "Conectando em personagem irregular.")
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.NewCharacter(Name, Lastname, Sex)
	local Return = false
	local source = source
	if not Active[source] then
		Active[source] = true

		local License = vRP.Identities(source)
		local Account = vRP.Account(License)

		local AmountCharactersPremium = Account["Characters"]
		if vRP.LicensePremium(License) then
			AmountCharactersPremium = AmountCharactersPremium + 2
		end

		local Consult = vRP.Query("characters/Count",{ License = License })
		if Account["Characters"] <= parseInt(Consult[1]["qtd"]) then
			TriggerClientEvent("Notify",source,"Atenção","Limite de personagem atingido.","amarelo",5000)
		else
			local Sexo = "M"
			if Sex == "mp_f_freemode_01" then
				Sexo = "F"
			end

			Return = true
			vRPC.DoScreenFadeOut(source)
			vRP.Query("characters/NewCharacter",{ License = License, Name = EmptySpace(Name), Lastname = EmptySpace(Lastname), Sex = Sexo, Skin = Sex, Phone = vRP.GeneratePhone(), Blood = math.random(4) })

			local Last = vRP.Query("characters/LastCharacter",{ License = License })
			if Last[1] then
				vRP.ChosenCharacter(source, Last[1]["id"], Sex)
			end
		end

		Active[source] = nil
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
    if Connected[Passport] then
    	local License = Connected[Passport]

        Connected[Passport] = nil
        Licensed[License] = nil
    end

    if Active[source] then
    	Active[source] = nil
    end
end)