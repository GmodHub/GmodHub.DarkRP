AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- Materials
local n, _ = file.Find('materials/models/alakran/*', 'GAME')
for k,v in ipairs(n) do
	resource.AddFile('materials/models/alakran/' .. v)
end

-- Models
local n, _ = file.Find('models/alakran/marijuana/*', 'GAME')
for k,v in ipairs(n) do
	resource.AddFile('models/alakran/marijuana/' .. v)
end

ENT.RemoveOnJobChange = true
ENT.LazyFreeze = true

function ENT:Initialize()
	self:SetModel('models/alakran/marijuana/pot_empty.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()

	self.isUsable = false
	self.isPlantable = true
	self.damage = 60

	self:GetStage(0)

	self:SetTrigger(true)
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
		self:Remove()
	end
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
		local WeedBag = ents.Create('durgz_weed')
		WeedBag:SetPos(SpawnPos + Vector(0,0,15))
		WeedBag:Spawn()
		self:SetStage(0)
	end
end

local function Stages(self)
	if !IsValid(self) then return end

	timer.Create('WeedPlant' .. self:EntIndex(), 25, 5, function()
		if !IsValid(self) then return end
		self:SetStage(self:GetStage() + 1)
		self:SetModel('models/alakran/marijuana/marijuana_stage' .. self:GetStage() .. '.mdl')
		if self:GetStage() == 5 then 
			self:GetStage(0)
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