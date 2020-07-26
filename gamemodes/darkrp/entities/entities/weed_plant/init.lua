AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.RemoveOnJobChange = true
ENT.LazyFreeze = true

ENT.MaxHealth = 100
ENT.DamageScale = 0.7
ENT.ExplodeOnRemove = true

function ENT:Initialize()
	self:SetModel('models/alakran/marijuana/pot_empty.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()

	self.isUsable = false
	self.isPlantable = true
	self:GetStage(0)

	self:SetTrigger(true)
end

function ENT:Use( activator, caller )
	if activator:IsBanned() then return end
	if !IsValid(activator) or !activator:IsPlayer() then return end
	if !self.isUsable then
		self:SetAngles(Angle(0,0,0))
		return
	end

	if self.isUsable == true then
		self.isUsable = false
		self.isPlantable = true
		self:SetModel('models/alakran/marijuana/pot_empty.mdl')
		local SpawnPos = self:GetPos() + Vector(0,0,15)
		local WeedBag = ents.Create('drug_Трава')
		WeedBag:SetPos(SpawnPos + Vector(0,0,15))
		WeedBag:Spawn()
		self:SetStage(0)
	end
end

local function Stages(self)
	if !IsValid(self) then return end

	timer.Create('WeedPlant' .. self:EntIndex(), 15, 5, function()
		if !IsValid(self) then return end
		self:SetStage(self:GetStage() + 1)
		self:SetModel('models/alakran/marijuana/marijuana_stage' .. self:GetStage() .. '.mdl')
		if self:GetStage() == 5 then
			self.isUsable = true
		end
	end)
end

function ENT:StartTouch(hitEnt)
	if hitEnt:GetClass() == 'seed_weed' and self.isPlantable == true then
		self.isPlantable = false
		hitEnt:Remove()
		self:SetModel('models/alakran/marijuana/pot.mdl')
		Stages(self)
	end
end
