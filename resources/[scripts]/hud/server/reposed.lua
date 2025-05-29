-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Call = {}
local Reposed = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Reposed", function(source, Passport, Seconds)
	if Reposed[Passport] then
		if os.time() > Reposed[Passport] then
			Reposed[Passport] = os.time() + Seconds
		else
			Reposed[Passport] = Reposed[Passport] + Seconds
		end
	else
		Reposed[Passport] = os.time() + Seconds
	end

	TriggerClientEvent("hud:Reposed", source, Reposed[Passport] - os.time())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Reposed", function(Passport, source)
	local source = parseInt(source)
	local Passport = parseInt(Passport)

	if Reposed[Passport] then
		if Reposed[Passport] > os.time() then
			if not Call[Passport] then
				Call[Passport] = os.time()
			end

			if Call[Passport] <= os.time() and source > 0 then
				Call[Passport] = os.time() + 60

				TriggerClientEvent("Notify", source, "Hospital", "Você está de repouso e não pode fazer isso agora.", "hospital", 10000)
			end

			return true
		end
	end

	return false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect", function(Passport, source)
	if Reposed[Passport] then
		if Reposed[Passport] > os.time() then
			TriggerClientEvent("hud:Reposed", source, Reposed[Passport] - os.time())
		end
	end
end)