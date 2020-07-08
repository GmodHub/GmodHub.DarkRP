ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Medic lab'
ENT.Author 		= 'aStonedPenguin'
ENT.Spawnable 	= false
ENT.PressE 		= true

ENT.MinPrice = 1
ENT.MaxPrice = 5

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'price')
end