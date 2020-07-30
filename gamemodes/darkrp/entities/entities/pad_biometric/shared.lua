ENT.Type			= 'anim'
ENT.Base			= 'pad_base'
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('String', 0, 'Org')
	self:NetworkVar('String', 1, 'Org1')
	self:NetworkVar('String', 2, 'Org2')
	self:NetworkVar('String', 3, 'Org3')
end

function ENT:CanHack(hacker)
	return true
end