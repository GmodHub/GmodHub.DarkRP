dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.RemoveOnJobChange = true

function ENT:Initialize()
	self:SetModel("models/props/CS_militia/footlocker01_open.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:PhysWake()

	self:CPPISetOwner(self.ItemOwner)
end

function ENT:PlayerUse(pl)
	if (pl == self:Getowning_ent()) and (self:Getmoney() > 0) then
		rp.Notify(pl, NOTIFY_GREEN, term.Get('PlayerTookDonationBox'), rp.FormatMoney(self:Getmoney()))
		pl:AddMoney(self:Getmoney())
		self:Setmoney(0)
	elseif (self:Getmoney() > 0) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('YouDontOwnThis'))
	end
end

function ENT:Touch(ent)
	if ent:GetClass() ~= "spawned_money" or self.hasMerged or ent.hasMerged or ent.PrinterMoney then return end
	ent.hasMerged = true
	ent:Remove()
	self:Setmoney(self:Getmoney() + ent:Getamount())
	if IsValid(self:Getowning_ent()) then
		rp.Notify(self:Getowning_ent(), NOTIFY_GREEN, term.Get('PlayerReceivedDonationBox'), rp.FormatMoney(ent:Getamount()))
	end
end
