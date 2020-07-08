AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

ENT.RemoveOnJobChange = true

ENT.MinPrice = 1
ENT.MaxPrice = 5

function ENT:Initialize()
	self:SetModel('models/props_combine/health_charger001.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:PhysWake()

	local ply = self:Getowning_ent()
	self.SID = ply.SID
	self:Setprice(self.MinPrice)

	self.damage = 150
end

function ENT:PhysgunPickup(pl)
	return ((pl == self.dt.owning_ent and self:InSpawn()) or false)
end

function ENT:PhysgunFreeze(pl)
	return self:InSpawn()
end

function ENT:OnTakeDamage(dmg)
	local phys = self:GetPhysicsObject()
	if not phys:IsMoveable() then return end

	self.damage = self.damage - dmg:GetDamage()
	if (self.damage <= 0) then
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
end

function ENT:Use(pl)
	if pl:IsBanned() then return end

	local owner = self:Getowning_ent()
	if pl:Health() < 100 then

		local Cost = ((100 - pl:Health()) * self:Getprice())

		if not pl:CanAfford(Cost) then 
			rp.Notify(pl, NOTIFY_ERROR, rp.Term('CannotAfford'))
			return 
		end
		
		if pl ~= owner then
			owner:AddMoney(Cost)
			rp.Notify(owner, NOTIFY_GREEN, rp.Term('MedLabProfit'), Cost)

			pl:AddMoney(-Cost)
			rp.Notify(pl, NOTIFY_GREEN, rp.Term('BoughtHealth'), Cost)
		end

		pl:SetHealth(100)
		self:EmitSound(Sound('HealthVial.Touch'))
	end
end

function ENT:OnRemove()
	self:Destruct()
	rp.Notify(self:Getowning_ent(), NOTIFY_ERROR, rp.Term('MedLabExploded'))
end