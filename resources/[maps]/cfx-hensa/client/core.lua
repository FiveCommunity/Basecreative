-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERIORS
-----------------------------------------------------------------------------------------------------------------------------------------
local interiors = {
	["bounty1-downtown"] = {
		coords = vec3(470.3234, -918.0665, 26.4111),
		sets = {
			["style1"] = true,
			["style2"] = false,
			["style3"] = false,
			["more_filecab_boss"] = false,
			["safe_armory_boss"] = true,
			["more_folder_office_a"] = true,
			["more_folder_office_b"] = false,
			["branding"] = true,
			["monitor_branding"] = false,
			["plant_boss"] = true,
			["trophy_boss"] = true,
			["trophy2_boss"] = true,
			["license_boss"] = true,
		}
	},
	["bounty2-delperro"] = {
		coords = vec3(-1405.8451, -663.9863, 32.50),
		sets = {
			["style1"] = false,
			["style2"] = true,
			["style3"] = false,
			["more_filecab_boss"] = true,
			["safe_armory_boss"] = false,
			["more_folder_office_a"] = false,
			["more_folder_office_b"] = true,
			["branding"] = true,
			["monitor_branding"] = false,
			["plant_boss"] = true,
			["trophy_boss"] = true,
			["trophy2_boss"] = true,
			["license_boss"] = true,
		}
	},
	["bounty3-harmony"] = {
		coords = vec3(592.3723, 2763.0103, 42.0677),
		sets = {
			["style1"] = false,
			["style2"] = false,
			["style3"] = true,
			["more_filecab_boss"] = true,
			["safe_armory_boss"] = false,
			["more_folder_office_a"] = false,
			["more_folder_office_b"] = true,
			["branding"] = true,
			["monitor_branding"] = false,
			["plant_boss"] = true,
			["trophy_boss"] = true,
			["trophy2_boss"] = true,
			["license_boss"] = true,
		}
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINTERIORS
-----------------------------------------------------------------------------------------------------------------------------------------
for name, v in pairs(interiors) do
	RequestIpl(name)

	local interior = GetInteriorAtCoords(v.coords)
	if IsValidInterior(interior) then
		for name2, enable in pairs(v.sets) do
			if enable then
				ActivateInteriorEntitySet(interior, name2)
			else
				DeactivateInteriorEntitySet(interior, name2)
			end
		end

		RefreshInterior(interior)
	end
end