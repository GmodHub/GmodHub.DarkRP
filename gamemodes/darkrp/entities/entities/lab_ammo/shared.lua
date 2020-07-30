ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Armor lab'
ENT.Author 		= 'GmodHub'
ENT.Spawnable 	= false
ENT.PressE 		= true

ENT.MinPrice = 100
ENT.MaxPrice = 1000


function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'price')
end