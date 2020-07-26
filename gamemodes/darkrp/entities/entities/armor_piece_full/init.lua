AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.SeizeReward = 350
ENT.WantReason = 'Нелегальный Предмет (Броня)'

function ENT:Initialize()
	self:SetModel('models/props_junk/cardboard_box004a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	self:PhysWake()
end

function ENT:Use(activ, caller)
	caller:SetArmor(100)
	self:EmitSound('npc/combine_soldier/gear5.wav')
	self:Remove()
end
