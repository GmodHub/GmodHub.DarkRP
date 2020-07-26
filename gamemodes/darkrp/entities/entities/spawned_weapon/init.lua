dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()
end

function ENT:PlayerUse(activator, caller)

	local class = self.weaponclass

	local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, self)

	if not CanPickup then return end
	if activator:HasWeapon(class) then
		rp.Notify(activator, NOTIFY_ERROR, term.Get('AlreadyHaveWeapon'))
		return false
	end

	activator:Give(class)
	weapon = activator:GetWeapon(class)

	if self.clip1 then
		weapon:SetClip1(self.clip1)
		weapon:SetClip2(self.clip2 or -1)
	end

	activator:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())
	self:EmitSound('items/ammo_pickup.wav')
	self:Remove()
end
