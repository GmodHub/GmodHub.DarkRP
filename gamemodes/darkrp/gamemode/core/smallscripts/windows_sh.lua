-- Models to cull when windows spawn
local WindowModels = {
	['models/props_breakable/windowglass1_16_32.mdl'] 			= true,
	['models/props_breakable/windowglass1_16_32_cracked.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_1.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_2.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_3.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_4.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_5.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_6.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shard_7.mdl'] 	= true,
	['models/props_breakable/windowglass1_16_32_shattered.mdl'] = true,
	['models/props_breakable/windowglass1_32_32.mdl']			= true,
	['models/props_breakable/windowglass1_32_32_cracked.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_1.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_2.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_3.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_4.mdl']	= true,
	['models/props_breakable/windowglass1_32_32_shard_5.mdl']	= true,
	['models/props_breakable/windowglass1_32_32_shard_6.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_7.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shard_8.mdl'] 	= true,
	['models/props_breakable/windowglass1_32_32_shattered.mdl'] = true,
	['models/props_breakable/windowglass1_76_40.mdl'] 			= true,
	['models/props_breakable/windowglass1_76_40_cracked.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_1.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_2.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_3.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_4.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_5.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_6.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_7.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shard_8.mdl'] 	= true,
	['models/props_breakable/windowglass1_76_40_shattered.mdl']	= true,
	['models/props/cs_militia/vent01.mdl']						= true,
}

if (SERVER) then
	AddCSLuaFile()
	util.AddNetworkString('StiffyWindows.Clear')

	local function SpawnStiffyWindows()
		net.Start('StiffyWindows.Clear')
		net.Broadcast()
		for k, v in ipairs(ents.FindByClass('prop_dynamic')) do
			if WindowModels[v:GetModel()] then
				v:Remove()
			end
		end
		for k, v in ipairs(ents.FindByClass('func_breakable_surf')) do
			v:Remove()
		end
		for k, v in ipairs(ents.FindByClass('point_template')) do
			v:Fire('forcespawn')
		end
	end

	hook('InitPostEntity', 'StiffyWindows.InitPostEntity', SpawnStiffyWindows)
	timer.Create('StiffyWindows', 300, 0, SpawnStiffyWindows)
else
	net('StiffyWindows.Clear', function()
		for k, v in ipairs(ents.FindByClass('class C_PhysPropClientside')) do
			if WindowModels[v:GetModel()] then
				v:Remove()
			end
		end
	end)
end
