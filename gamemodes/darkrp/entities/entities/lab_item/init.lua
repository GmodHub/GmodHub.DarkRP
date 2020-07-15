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

	self:SetUseType(SIMPLE_USE)

	self.HP = 100
end

--[[function ENT:OnTakeDamage(dmg) -- let's be indestructable for now
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
end]]

function ENT:Touch(ent) -- Apparently ENT:StartTouch nor ENT:EndTouch() worked.
    if(self:Getcount() ~= 0 or ent:GetClass() ~= "spawned_shipment" or ent:Getcount() == 0) then return end

	self:SetID(ent:Getcontents())
	self:Setcount(ent:Getcount())
	ent:Remove()
end

function ENT:CanUse(pl)
	if(self.ItemOwner == pl) then
		return true
	else
		if(pl:CanAfford(self:Getprice())) then
			pl:AddMoney(-self:Getprice())
			self:SpawnItem()
			-- Maybe rp notify or something if you can't buy
		end
		return false
	end
end

function ENT:SpawnItem()
	local count = self:Getcount()

	if(count == 0) then
		self:SetID(0)
		return
	end

	local contents = self:GetID()

	local weapon = ents.Create('spawned_weapon')

	local weaponAng = self:GetAngles()
	local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
	weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

	local class = rp.shipments[contents].entity
	local model = rp.shipments[contents].model

	weapon.weaponclass = class
	weapon:SetModel(model)
	weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
	weapon.clip1 = self.clip1
	weapon.clip2 = self.clip2
	weapon:SetPos(self:GetPos() + weaponPos)
	weapon:SetAngles(weaponAng)
	weapon:Spawn()

	self:Setcount(count - 1)
	self.locked = false
end