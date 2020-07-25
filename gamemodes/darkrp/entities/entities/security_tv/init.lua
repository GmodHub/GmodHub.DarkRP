dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetModel('models/props/cs_office/tv_plasma.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:CanNetworkUse(pl)
	return self:CPPIGetOwner() == pl
end
