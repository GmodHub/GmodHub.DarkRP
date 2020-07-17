AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self:PhysWake()

	self.FoodEnergy = 100
end

function ENT:OnTakeDamage(dmg)
	self:Remove()
end

function ENT:Use(activator,caller)
	if activator:IsBanned() then return end
	activator:SetHunger(activator:CallSkillHook(SKILL_HUNGER))
	self:Remove()
	activator:EmitSound("vo/sandwicheat09.wav")
end
