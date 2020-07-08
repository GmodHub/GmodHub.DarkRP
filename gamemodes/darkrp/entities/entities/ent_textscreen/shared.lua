ENT.Type 		= 'anim'
ENT.Base 		= 'base_anim'
ENT.PrintName 	= 'Textscreen'
ENT.Spawnable 	= false

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'Text')

	self:NetworkVar('Bool', 0, 'Background')

	self:NetworkVar('Int', 0, 'Font')
	self:NetworkVar('Int', 1, 'Size')
	self:NetworkVar('Int', 2, 'TextColor')
	self:NetworkVar('Int', 3, 'BackgroundColor')
end
