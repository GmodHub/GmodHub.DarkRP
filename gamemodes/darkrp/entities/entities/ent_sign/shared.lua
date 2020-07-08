ENT.Type		= 'anim'
ENT.Base		= 'base_anim'
ENT.Spawnable	= false

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'Text1')
	self:NetworkVar('String', 1, 'Text2')
	self:NetworkVar('String', 2, 'Text3')
end
