dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

local DumpsterItems = {
	Props = {
		"models/props_c17/FurnitureShelf001b.mdl",
		"models/props_c17/FurnitureDrawer001a_Chunk02.mdl",
		"models/props_interiors/refrigeratorDoor02a.mdl",
		"models/props_lab/lockerdoorleft.mdl",
		"models/props_wasteland/prison_lamp001c.mdl",
		"models/props_wasteland/prison_shelf002a.mdl",
		"models/props_vehicles/tire001c_car.mdl",
		"models/props_trainstation/traincar_rack001.mdl",
		"models/props_interiors/SinkKitchen01a.mdl",
		"models/props_c17/lampShade001a.mdl",
		"models/props_junk/PlasticCrate01a.mdl",
		"models/props_c17/metalladder002b.mdl",
		"models/Gibs/HGIBS.mdl",
		"models/props_c17/metalPot001a.mdl",
		"models/props_c17/streetsign002b.mdl",
		"models/props_c17/pottery06a.mdl",
		"models/props_combine/breenbust.mdl",
		"models/props_lab/partsbin01.mdl",
		"models/props_trainstation/payphone_reciever001a.mdl",
		"models/props_vehicles/carparts_door01a.mdl",
		"models/props_vehicles/carparts_axel01a.mdl"
	},

	Weapons = {
		"swb_357",
		"swb_ak47",
		"swb_awp",
		"swb_deagle",
		"swb_famas",
		"swb_fiveseven",
		"swb_p90",
		"swb_g3sg1",
		"swb_glock18",
		"swb_mp5",
		"swb_ump",
		"swb_galil",
		"swb_knife",
		"swb_m249",
		"swb_m3super90",
		"swb_m4a1",
		"swb_mac10",
		"swb_p228",
		"swb_sg550",
		"swb_sg552",
		"swb_aug",
		"swb_scout",
		"swb_tmp",
		"swb_usp",
		"swb_xm1014",
	}
}

function ENT:Initialize()
	self:SetModel("models/props_junk/TrashDumpster01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

function ENT:EmitItems(searcher)
	self:EmitSound("physics/metal/metal_solid_strain5.wav", 300, 100)
	local pos = self:GetPos() + ((self:GetAngles():Up() * 15) + (self:GetAngles():Forward() * 20))

	if searcher:CallSkillHook(SKILL_SCAVENGE) <= 50 then
		local ent = ents.Create(table.Random(DumpsterItems["Weapons"]))
		ent:SetPos(pos)
		ent:Spawn()
	elseif math.random(1, 100) <= 100 then
		local prop = ents.Create("prop_physics_multiplayer")
		prop:SetModel(table.Random(DumpsterItems["Props"]))
		prop:SetPos(pos)
		prop:Spawn()

		timer.Simple(10, function()
			if prop:IsValid() then
				prop:Remove()
			end
		end)
	end

end

function ENT:CanUse(pl)
	if self:GetNextUse() > CurTime() then return false end

	if not pl:IsHobo() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeHobo') )
		return false
	end

	return true
end

function ENT:CustomUse(pl)
	self:SetNextUse(CurTime() + 120)
	self:EmitItems(pl)
end

hook.Add("InitPostEntity", "SpawnDumpsters", function()
	for k,v in pairs(rp.cfg.Dumpsters[game.GetMap()] or {}) do
		local dump = ents.Create("ent_dumpster")
		dump:SetPos(v[1])
		dump:SetAngles(v[2])
		dump:Spawn()
	end
end)
