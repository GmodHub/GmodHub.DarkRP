ENT.Type			= 'anim'
ENT.Base			= 'pad_base'
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('String', 0, 'Org')
end

function ENT:CanHack(hacker)
	return true
end