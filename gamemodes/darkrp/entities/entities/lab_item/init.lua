AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.SeizeReward = 500
ENT.WantReason = 'Black Market Item (Item lab)'
ENT.LazyFreeze = true

ENT.RemoveOnJobChange = true

function ENT:Initialize()
	self:SetModel("models/props_c17/trappropeller_engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()

    self:SetAngles(Angle(-90, 0, 0)) -- Small model angle tweak

	self.HP = 100
end

function ENT:OnTakeDamage(dmg)
	self.HP = self.HP - dmg:GetDamage()

	if (self.HP <= 0) then
		self:Explode()
	end
end

function ENT:Explode()
	timer.Destroy(self:EntIndex() .. 'Drug')
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
	
	self:Remove()

	if IsValid(self.ItemOwner) then
		rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('DrugLabExploded'))
	end
end

function ENT:StartTouch(ent)
    if(ent:GetClass() ~= "spawned_shipment" or self:Getcount() ~= 0 or ent:Getcount() == 0) then return end

    -- TODO: Load shipment
end