AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_combine/combine_intmonitor003.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

function ENT:CanUse(pl)
	return pl:IsCP()
end

function ENT:PlayerUse(pl)
	pl.GenomeTeam = true
	net.Start('rp.ApplyGenome')
		net.WriteUInt(pl:IsVIP() and 33 or 30, 6)
		net.WriteBool(true)
		net.WriteBool(true)
		net.WriteFloat(pl.Genome.d)
		net.WriteFloat(pl.Genome.s)
		net.WriteFloat(pl.Genome.a)
	net.Send(pl)
end

hook.Add("InitPostEntity", "rp.GenomeMachines", function()
	for k, v in pairs(rp.cfg.GenomeMachines[game.GetMap()]) do
		local ent = ents.Create("genome_machine")
		ent:SetPos(v.Pos)
		ent:SetAngles(v.Ang)
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():EnableMotion(false)
	end
end)
