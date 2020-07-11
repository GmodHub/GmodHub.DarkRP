AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/jaanus/aspbtl.mdl")
	self:SetColor(0, 255, 0, 255)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:Use(activator, caller)
	if activator:IsBanned() then return end
	caller:CureSTD()
	rp.Notify(caller, NOTIFY_GREEN, term.Get('STDCured'))
	self:Remove()
end
