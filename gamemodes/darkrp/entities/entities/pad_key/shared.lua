ENT.Type			= 'anim'
ENT.Base			= 'pad_base'
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('Int', 1, 'NumStars')
	self:NetworkVar("Bool", 0, "IsEnabled")
end
