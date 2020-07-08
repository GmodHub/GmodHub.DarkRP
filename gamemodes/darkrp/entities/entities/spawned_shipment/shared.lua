ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Shipment'
ENT.Category 	= 'RP'
ENT.Spawnable 	= true
ENT.PressE 		= true

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'contents')
	self:NetworkVar('Int', 1, 'count')
end

function ENT:IsEmpty()
	return self:Getcontents() == 0
end

function ENT:GetShipmentTable()
	return rp.shipments[self:Getcontents()]
end

rp.inv.Wl['spawned_shipment'] = 'Shipment'