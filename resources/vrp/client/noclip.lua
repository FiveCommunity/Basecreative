-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local NoClip = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOCLIP
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.NoClip(source)
	NoClip = not NoClip
	local Ped = PlayerPedId()

	if NoClip then
		LocalPlayer["state"]:set("Invisible", true, false)
		LocalPlayer["state"]:set("Blastoise", true, false)

		SetEntityCollision(Ped,false,false)
		SetEntityVisible(Ped,false,false)
		SetEntityInvincible(Ped,false)

		TriggerEvent("Notify","Sucesso","Modo <b>NoClip</b> ativado.", "verde", 5000)
	else
		SetEntityCollision(Ped,true,true)
		SetEntityVisible(Ped,true,false)
		SetEntityInvincible(Ped,false)

		LocalPlayer["state"]:set("Blastoise", false, false)
		LocalPlayer["state"]:set("Invisible", false, false)

		TriggerEvent("Notify","Atenção","Modo <b>NoClip</b> desativado.", "amarelo", 5000)
	end

	while NoClip do
		local Speed = 1.0
		local cX,cY,cZ = GetCamDirections()
		local Coords = GetEntityCoords(Ped)
		local X,Y,Z = table.unpack(Coords)

		if IsControlPressed(1,21) then
			Speed = 5.0
		end

		if IsControlPressed(1,22) then
			Speed = 30.0
		end

		if IsControlPressed(1,19) then
			Speed = 100.0
		end

		if IsControlPressed(1,210) then
			Speed = 0.2
		end

        if IsControlPressed(1,32) then
            X = X + Speed * cX
            Y = Y + Speed * cY
            Z = Z + Speed * cZ
        end
        
        if IsControlPressed(1,34) then
            X = X - Speed * cY
            Y = Y + Speed * cX
        end

        if IsControlPressed(1,35) then
            X = X + Speed * cY
            Y = Y - Speed * cX
        end
        
        if IsControlPressed(1,269) then
            X = X - Speed * cX
            Y = Y - Speed * cY
            Z = Z - Speed * cZ
        end

		if IsControlPressed(1,10) then
			Z = Z + 0.25
		end

		if IsControlPressed(1,11) then
			Z = Z - 0.25
		end

		SetEntityCoordsNoOffset(Ped,X,Y,Z,false,false,false)
		Wait(0)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCAMDIRECTION
-----------------------------------------------------------------------------------------------------------------------------------------
function GetCamDirections()
	local Ped = PlayerPedId()
	local Pitch = GetGameplayCamRelativePitch()
	local Heading = GetGameplayCamRelativeHeading() + GetEntityHeading(Ped)
	local x = -math.sin(Heading * math.pi / 180.0)
	local y = math.cos(Heading * math.pi / 180.0)
	local z = math.sin(Pitch * math.pi / 180.0)
	local Len = math.sqrt(x * x + y * y + z * z)
	if Len ~= 0 then
		x = x / Len
		y = y / Len
		z = z / Len
	end

	return x,y,z
end