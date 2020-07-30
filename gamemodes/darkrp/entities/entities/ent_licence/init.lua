dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetModel('models/props_lab/clipboard.mdl')

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetUseType(SIMPLE_USE)
end

function ENT:PlayerUse(pl)
	if pl:IsBanned() then return end

	if pl:HasLicense() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('AlreadyHasGunLicense'))
		return
	end

	rp.Notify(pl, NOTIFY_GREEN, term.Get('GunLicenseActive'))
	pl:SetNetVar('HasGunlicense', true)

	self:Remove()
end
