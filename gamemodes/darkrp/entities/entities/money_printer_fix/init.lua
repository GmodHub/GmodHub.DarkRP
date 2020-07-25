AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.SeizeReward = 250
ENT.WantReason = 'Устройства для Печати Денег'

function ENT:Initialize()
	self:SetModel('models/props_c17/tools_wrench01a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'money_printer') then
		self.Used = true
		self:Remove()
		ent:SetHP(100)
		ent:EmitSound('ambient/energy/weld1.wav')
	end
end
