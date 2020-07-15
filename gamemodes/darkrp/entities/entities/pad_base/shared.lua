ENT.Type			= 'anim'
ENT.Base			= 'base_rp'
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.NetworkPlayerUse = true

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'Status')
end

function ENT:IsPropsFaded()
	return (self:GetStatus() == 1)
end

function ENT:IsBusy()
	return (self:GetStatus() >= 1)
end