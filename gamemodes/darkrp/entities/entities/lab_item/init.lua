dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.RemoveOnJobChange = true

ENT.MaxHealth = 250
ENT.DamageScale = 0.5
ENT.ExplodeOnRemove = true

ENT.CanTool = {
	remover = true,
	material = true,
	colour = true,
	submaterial = true,
}

function ENT:Initialize()
	self:SetModel("models/props_c17/trappropeller_engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	self:SetUseType(SIMPLE_USE)
	self:Setprice(self.MinPrice)

  	self:SetAngles(Angle(-90, 0, 0)) -- Small model angle tweak
end

function ENT:Touch(ent) -- Apparently ENT:StartTouch nor ENT:EndTouch() worked.
    if(self:Getcount() ~= 0 or ent:GetClass() ~= "spawned_shipment" or ent:Getcount() == 0) then return end

	self:SetID(ent:Getcontents())
	self:Setcount(ent:Getcount())
	ent:Remove()
end

function ENT:CanNetworkUse(pl)
	return self.ItemOwner == pl
end

function ENT:PlayerUse(pl)
	if self:Getcount() <= 0 then return end

	if (pl ~= self.ItemOwner) and not pl:CanAfford(self:Getprice()) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	if (pl ~= self.ItemOwner) then
		pl:TakeMoney(self:Getprice())

		self.ItemOwner:AddMoney(self:Getprice() * 0.95)
		self.ItemOwner:Notify(NOTIFY_SUCCESS, term.Get('SoldItem'), rp.FormatMoney(self:Getprice() * 0.95), 0)

		pl:Notify(NOTIFY_SUCCESS, term.Get('RPItemBought'), class, rp.FormatMoney(self:Getprice()))
	end

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
	weapon:SetPos(self:GetPos() + weaponPos)
	weapon:SetAngles(weaponAng)
	weapon:Spawn()

	self:Setcount(count - 1)
	if self:Getcount() == 0 then
		self.ItemOwner:Notify(NOTIFY_GENERIC, term.Get('YourItemLabRanOut'))
	end
end
