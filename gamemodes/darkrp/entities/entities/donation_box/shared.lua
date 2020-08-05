ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Donation Box'
ENT.Author 		= 'GmodHub'
ENT.Spawnable 	= false
ENT.PressE 		= true

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 1, 'owning_ent')
	self:NetworkVar('Float', 0, 'money')
end
