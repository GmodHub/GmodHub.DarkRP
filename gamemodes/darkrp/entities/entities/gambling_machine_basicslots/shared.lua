ENT.Type 		= 'anim'
ENT.Base 		= 'gambling_machine_base'
ENT.PrintName 	= 'Basic Slots'
ENT.Spawnable 	= true
ENT.Category 	= 'RP Machines'
ENT.PressE 		= true

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('Int', 1, 'Roll1')
	self:NetworkVar('Int', 2, 'Roll2')
	self:NetworkVar('Int', 3, 'Roll3')
end
