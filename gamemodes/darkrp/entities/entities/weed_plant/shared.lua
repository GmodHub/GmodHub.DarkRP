ENT.Type 			= 'anim'
ENT.Base 			= 'base_rp'
ENT.PrintName 		= 'Growing Weed Plant'
ENT.Author 			= 'GmodHub'
ENT.Spawnable 		= false
ENT.PressKeyText	= 'To take'

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'Stage')
	self:NetworkVar('Entity', 1, 'owning_ent')
end