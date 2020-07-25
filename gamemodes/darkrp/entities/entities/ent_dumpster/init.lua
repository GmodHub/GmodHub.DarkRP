dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetModel("models/props_junk/TrashDumpster01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

function ENT:CanUse(pl)
	if (self:GetNextUse() > CurTime()) and not pl:IsRoot() then return false end

	if not pl:IsHobo() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeHobo') )
		return false
	end

	return true
end

function ENT:PlayerUse(pl)
	self:SetNextUse(CurTime() + 120)
	self:EmitSound("physics/metal/metal_solid_strain5.wav", 300, 100)

	local pos = self:GetPos() + (self:GetAngles():Forward() * 60)
	local luck = pl:CallSkillHook(SKILL_SCAVENGE)

	if luck >= 70 then
		local v, k = table.Random(rp.WeaponsMap)
		local ent = ents.Create("spawned_weapon")
		ent.weaponclass = k
		ent:SetModel(v.Model)
		ent:SetPos(pos)
		ent:Spawn()
	elseif luck >= 60 then
		local v, k = table.Random(rp.DrugsMap)
		local ent = ents.Create(k)
		ent:SetPos(pos)
		ent:Spawn()
	else
		local v, k = table.Random(rp.pp.Whitelist)
		local prop = ents.Create("prop_physics_multiplayer")
		prop:SetModel(k)
		prop:SetPos(pos)
		prop:Spawn()

		timer.Simple(10, function()
			if prop:IsValid() then
				prop:Remove()
			end
		end)
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 25 // Dumb spawn fix

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end

hook.Add("InitPostEntity", "SpawnDumpsters", function()
	for k,v in pairs(rp.cfg.Dumpsters[game.GetMap()] or {}) do
		local dump = ents.Create("ent_dumpster")
		dump:SetPos(v[1])
		dump:SetAngles(v[2])
		dump:Spawn()
	end
end)
