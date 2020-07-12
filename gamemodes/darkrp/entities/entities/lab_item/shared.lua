ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Item lab'
ENT.Spawnable 	= false
ENT.PressE 		= true

ENT.NetworkPlayerUse = true

ENT.MinPrice	= 100
ENT.MaxPrice	= 10000000
ENT.TaxRate		= 0.05

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'price')
	self:NetworkVar('Int', 1, 'ID')
	self:NetworkVar('Int', 2,'count')
end

function ENT:GetGunName()
	return rp.shipments[self:GetID()] and rp.shipments[self:GetID()].name or ""
end

function ENT:GetGunClass()
	return rp.shipments[self:GetID()] and rp.shipments[self:GetID()].entity or ""
end

function ENT:GetGunModel()
	return rp.shipments[self:GetID()] and rp.shipments[self:GetID()].model or ""
end