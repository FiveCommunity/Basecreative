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
Tunnel.bindInterface("barbershop", Hensa)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Check()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not exports["hud"]:Reposed(Passport, source) and not exports["hud"]:Wanted(Passport, source) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Update(Table,Creation)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Barbershop", Information = json.encode(Table) })

		if Creation then
			vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Creator", Information = json.encode(1) })
			exports["vrp"]:Bucket(source,"Exit")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MODE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Mode()
	local Return = false
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Identity = vRP.Identity(Passport)
		if Identity and Identity["Created"] >= os.time() then
			Return = true
		end
	end

	return Return
end