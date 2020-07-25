dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.DrugLabCreate')

ENT.SeizeReward = 500
ENT.WantReason = 'Black Market Item (Drug lab)'
ENT.LazyFreeze = true

ENT.RemoveOnJobChange = true

ENT.MaxHealth = 100
ENT.DamageScale = 1
ENT.ExplodeOnRemove = true

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

function ENT:CraftDrug(class)
	local time = math.random(60, 180)
	self:SetCraftTime(CurTime() + time)
	self:SetCraftRate(time)

	timer.Create(self:EntIndex() .. 'Drug', time, 1, function()
		if IsValid(self) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetMagnitude(1)
			effectdata:SetScale(1)
			effectdata:SetRadius(2)
			util.Effect('Sparks', effectdata)

			local e = ents.Create(class)
			e:SetPos(self:GetPos() + ((self:GetAngles():Up() * 15) + (self:GetAngles():Forward() * 20)))
			e:Spawn()
			e:Activate()
		end
	end)
end

net.Receive('rp.DrugLabCreate', function(len, pl)
	local ent = net.ReadEntity()
	local class = net.ReadUInt(8) or 0

	if not IsValid(ent) or not scripted_ents.IsBasedOn(ent:GetClass(), "drug_lab_base") or (pl ~= ent.ItemOwner) then return end
	if (ent:GetPos():Distance(pl:GetPos()) >= 80) then return end
	if not rp.Drugs[class] then return end

	ent:CraftDrug(rp.Drugs[class].Class)
end)
