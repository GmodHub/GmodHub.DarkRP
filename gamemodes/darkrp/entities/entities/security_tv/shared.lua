ENT.Type 		= 'anim'
ENT.Base		= 'base_rp'
ENT.PrintName 	= 'Securiy: TV'
ENT.Author		= 'Velkon + aStonedPenguin'
ENT.Category	= 'RP'
ENT.Spawnable 	= true

ENT.PressE 			= true
ENT.PressKeyText	= 'To Enable'

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 0, 'Camera')
end
