AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self:PhysWake()

	self.FoodEnergy = self.FoodEnergy or math.random(15, 25)
end

function ENT:OnTakeDamage(dmg)
	self:Remove()
end

function ENT:Use(activator,caller)
	if activator:IsBanned() then return end
	activator:AddHunger(self.FoodEnergy)
	self:Remove()
	activator:EmitSound("vo/sandwicheat09.wav")
end
