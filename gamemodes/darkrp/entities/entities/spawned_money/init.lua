AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props/cs_assault/money.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake()
end


function ENT:Use(activator,caller)
	if activator:IsBanned() then return end
	local amount = self:Getamount() or 0

	activator:AddMoney(amount)

	hook.Call('PlayerPickupRPMoney', GAMEMODE, activator, amount, activator:GetMoney())

	rp.Notify(activator, NOTIFY_GREEN, term.Get('MoneyFound'), amount)
	self:Remove()
end

function rp.SpawnMoney(pos, amount)
	local moneybag = ents.Create('spawned_money')
	moneybag:SetPos(pos)
	moneybag:Setamount(math.Min(amount, 2147483647))
	moneybag:Spawn()
	moneybag:Activate()
	return moneybag
end

function ENT:Touch(ent)
	if ent:GetClass() ~= 'spawned_money' or self.hasMerged or ent.hasMerged then return end

	ent.hasMerged = true

	ent:Remove()
	self:Setamount(self:Getamount() + ent:Getamount())
end
