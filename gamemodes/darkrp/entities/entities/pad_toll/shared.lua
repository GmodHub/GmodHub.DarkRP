ENT.Type			 = 'anim'
ENT.Base			 = 'pad_base'
ENT.Spawnable		 = false
ENT.AdminSpawnable	 = false

ENT.MinPrice = 100
ENT.MaxPrice = 100000

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar('Int', 1, 'price')
	self:NetworkVar('Bool', 0, 'OneTimeUse')
	self:NetworkVar("Float", 0, "HoldLength")
end

function ENT:CanHack(hacker)
	return true
end