ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Gambling Machine Base'
ENT.PressE 		= true

ENT.MinPrice = 500
ENT.MaxPrice = 100000000

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'price')
	self:NetworkVar('Bool', 0, 'InService')
	self:NetworkVar('Bool', 1, 'IsPayingOut')
end