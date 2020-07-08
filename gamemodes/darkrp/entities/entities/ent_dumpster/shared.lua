ENT.Type 			= 'anim'
ENT.Base 			= 'base_rp'
ENT.PrintName 		= 'Dumpster'
ENT.Spawnable 		= true
ENT.Category 		= 'RP'
ENT.PressKeyText 	= 'Scavenge'

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'NextUse')
end
