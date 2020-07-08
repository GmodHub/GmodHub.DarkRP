rp.WeaponMaterials = {
	['models/props_wasteland/quarryobjects01'] = 1000,
	['phoenix_storms/metalset_1-2'] = 2000,
	['models/XQM/SquaredMat'] = 2000,
	['models/props_animated_breakable/smokestack/brickwall002a'] = 2000,
	['models/props_combine/combine_monitorbay_disp'] = 2000,
	['models/props_combine/metal_combinebridge001'] = 2000,
	['models/props_debris/concretefloor020a'] = 2000,
	['models/XQM/BoxFull_diffuse'] = 2000,
	['phoenix_storms/Fender_chrome'] = 2000,
	['models/dav0r/hoverball'] = 3000,
	['phoenix_storms/Future_vents'] = 3000,
	['phoenix_storms/car_tire'] = 3000,
	['phoenix_storms/white_fps'] = 3000,
	['phoenix_storms/cigar'] = 3000,
	['phoenix_storms/wire/pcb_blue'] = 3000,
	['models/shadertest/shader5'] = 3000,
	['models/shiny'] = 3000,
	['models/player/player_chrome1'] = 3000,
	['models/props_combine/prtl_sky_sheet'] = 3000,
	['phoenix_storms/FuturisticTrackRamp_1-2'] = 3000,
	['phoenix_storms/checkers_map'] = 3000,
	['models/combine_advisor/mask'] = 3000,
	['models/weapons/v_crossbow/rebar_glow'] = 3000,
	['phoenix_storms/t_light'] = 3000,
	['models/XQM/CellShadedCamo_diffuse'] = 4000,
	['phoenix_storms/stripes'] = 4000,
	['models/XQM/SquaredMatInverted'] = 4000,
	['models/effects/splode_sheet'] = 4000,
	['models/flesh'] = 4000,
	['models/props/cs_assault/moneytop'] = 5000,
	['phoenix_storms/heli'] = 7500,
}

if (SERVER) then
	util.AddNetworkString 'rp.cosmetrics.WeaponSkin'
else
	rp.WeaponMaterialCache = rp.WeaponMaterialCache or {}

	net('rp.cosmetrics.WeaponSkin', function()
		rp.WeaponMaterialCache[net.ReadEntity()] = net.ReadString()
	end)

	hook('PreDrawViewModel', 'rp.weaponskins.PreDrawViewModel', function(vm, pl, wep)
		if IsValid(vm) and IsValid(wep) and (wep == pl:GetActiveWeapon()) and string.find(wep:GetClass(), 'swb') then
			local mat = rp.WeaponMaterialCache[wep]

			wep.CosmeticsViewModelIndex = vm:ViewModelIndex()

			for k, v in pairs(vm:GetMaterials()) do
				if mat and (not string.find(v, 'hands')) then
					vm:SetSubMaterial(k - 1, mat)
				else
					vm:SetSubMaterial(k - 1)
				end
			end
		end
	end)

	local function reset(wep)
		if (not IsValid(LocalPlayer())) then return end

		local vm = LocalPlayer():GetViewModel(wep.CosmeticsViewModelIndex)

		if (not IsValid(vm)) then return end

		for k, v in pairs(vm:GetMaterials()) do
			vm:SetSubMaterial(k - 1)
		end
	end

	hook('PlayerSwitchWeapon', 'rp.weaponskins.PlayerSwitchWeapon', function(pl, oldWep, newWep)
		if IsValid(oldWep) and oldWep.CosmeticsViewModelIndex then
			reset(oldWep)
		end
	end)

	hook('EntityRemoved', 'rp.weaponskins.EntityRemoved', function(ent)
		if rp.WeaponMaterialCache[ent] then
			reset(ent)

			rp.WeaponMaterialCache[ent] = nil
		end
	end)
end