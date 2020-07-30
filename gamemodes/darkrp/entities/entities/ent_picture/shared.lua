ENT.Type 		= 'anim'
ENT.PrintName	= 'Picture'
ENT.Author		= 'GmodHub'
ENT.Base 		= 'base_anim'
ENT.Category 	= 'RP'
ENT.PressE 		= true
ENT.Spawnable	= true

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'URL')
	self:NetworkVar('Bool', 0, 'IsLoading')
end
