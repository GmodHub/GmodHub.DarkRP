ENT.Type 		= 'anim'
ENT.Base 		= 'gambling_machine_base'
ENT.PrintName 	= 'FiftyFifty'
ENT.Spawnable 	= true
ENT.Category 	= 'RP Machines'
ENT.PressE 		= true

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('Int', 1, 'PlayerRoll')
	self:NetworkVar('Int', 2, 'HouseRoll')
end
