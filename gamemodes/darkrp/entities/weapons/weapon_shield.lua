AddCSLuaFile()

SWEP.shieldDamage = 10
SWEP.bashReloadTime = 2
SWEP.stunTime = 1

SWEP.canBeDestroyedByDamage = false
SWEP.onlyExplosionDamage = true
SWEP.defaultHealth = 800

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 2

SWEP.PrintName = 'Щит'
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = 'physgun'
SWEP.HoldType ='physgun'
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = 'RP'

SWEP.ViewModel = Model('models/drover/shield.mdl')
SWEP.WorldModel = Model('models/drover/w_shield.mdl')

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ''

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ''

function SWEP:GetSwitcherSlot()
	return IsValid(self.Owner) and self.Owner:IsCP() and 2 or 3
end

function SWEP:Initialize()
	self:SetHoldType('physgun')
end

for k, v in ipairs(ents.FindByClass("weapon_shield")) do
	if (IsValid(v.shieldProp)) then
		v.shieldProp:Remove()
		v:SetupShield()
	end
end
function SWEP:SetupShield()
	if CLIENT then return end
	self.shieldProp = ents.Create('prop_physics')
	self.shieldProp:SetModel('models/drover/2w_shield.mdl')
	self.shieldProp:Spawn()
	self.shieldProp:SetModelScale(0,0)
	local phys = self.shieldProp:GetPhysicsObject()
	if not IsValid(phys) then
		return
	end
	phys:SetMass(5000)

	local nothand = false
	local attach = self:GetOwner():LookupAttachment('anim_attachment_RH')
	if attach == nil or attach == 0 then
		attach = self:GetOwner():LookupAttachment('forward')
		nothand = true

		if attach == nil or attach == 0 then
			return
		end
	end

	local up = 3
	local forward = 11
	local right = 0

	local aforward = 20
	local aup = 70
	local aright = 0

	if nothand then
		up = -20
		forward = 17
		aforward = 0
		aup = 90
	end

	if (self:GetOwner():GetModel() == "models/code_gs/player/robber.mdl") then -- dummy code_gs
		aforward= -140
		aup = 0
		aright = 110
		up = -2
		right = -12
		forward = 1
	end

	local attachTable = self:GetOwner():GetAttachment(attach)
	self.shieldProp:SetPos(attachTable.Pos + attachTable.Ang:Up()*up + attachTable.Ang:Forward()*forward + attachTable.Ang:Right()*right)

	attachTable.Ang:RotateAroundAxis(attachTable.Ang:Forward(),aforward)
	attachTable.Ang:RotateAroundAxis(attachTable.Ang:Up(),aup)
	attachTable.Ang:RotateAroundAxis(attachTable.Ang:Right(),aright)

	self.shieldProp:SetAngles(attachTable.Ang)
	self.shieldProp:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.shieldProp:SetParent(self:GetOwner(),attach)
	timer.Simple(0.2,function()
		if IsValid(self) and IsValid(self.shieldProp) then
			self.shieldProp:SetModelScale(1,0)
			net.Start('disable_shielddraw') net.WriteEntity(self) net.WriteEntity(self.shieldProp) net.Send(self:GetOwner())
		end
	end)
end

function SWEP:CheckPlace(pos)

	local mins = Vector(-10, -20, -3)
	local maxs = Vector(20, 20, 40)
	local tr = {
		start = pos,
		endpos = pos + Vector(0,0,5),
		mins = mins,
		maxs = maxs,
		filter = {self:GetOwner(),self.shieldProp}
	}
	local hullTrace = util.TraceHull(tr)
	if (hullTrace.Hit) then
		return false
	end
	return true
end

function SWEP:FreezeEnemy(ply)
	ply:Freeze(true)
	timer.Simple(1, function()
		if IsValid(ply) then ply:Freeze(false) end
	end)
end

function SWEP:FindEnemy()
	local mins = Vector(-10, -10, -3)
	local maxs = Vector(10, 10, 40)
	local pos = self:GetOwner():GetPos() + self:GetOwner():GetForward()*35 + Vector(0,0,40)
	local tr = {
		start = pos,
		endpos = pos + Vector(0,0,5),
		mins = mins,
		maxs = maxs,
		filter = {self:GetOwner(),self.shieldProp,Entity(0)}
	}
	local hullTrace = util.TraceHull(tr)
	if (hullTrace.Hit) then
		if hullTrace.Entity:IsPlayer() then
			return hullTrace.Entity
		end
		return false
	end
	return false
end


function SWEP:ShieldBash()
	local enemy = self:FindEnemy()
	if enemy == false then return end
	enemy:TakeDamage(self.shieldDamage,self:GetOwner(),self)
	self:FreezeEnemy(enemy)
	self:GetOwner():EmitSound(Sound('Flesh.ImpactHard'))
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.bashReloadTime)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if CLIENT then return end
	net.Start('shieldbash') net.WriteEntity(self:GetOwner()) net.Broadcast()
	self:ShieldBash()

end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local ang = self:GetOwner():GetAngles()
	ang.p = 0
	ang.r = 0
	local pos = self:GetOwner():GetPos() + ang:Forward()*45 + Vector(0,0,10)
	local checkingPlace = self:CheckPlace(pos)
	if not checkingPlace then return end

	local shieldEnt = ents.Create('police_shield')
	shieldEnt:SetPos(pos)
	local tempAngle = self:GetOwner():GetAngles()
	shieldEnt:SetAngles(Angle(0,tempAngle.y,0))

	shieldEnt.canBeDestroyedByDamage = self.canBeDestroyedByDamage
	shieldEnt.onlyExplosionDamage = self.onlyExplosionDamage
	shieldEnt.currentHealth = self.defaultHealth

	shieldEnt:Spawn()
	shieldEnt.ItemOwner = self:GetOwner()
	self:GetOwner():Freeze(true)
	local ply = self:GetOwner()
	timer.Simple(0.2,function()
		if IsValid(ply) then
			ply:Freeze(false)
			if (ply:Alive()) then
				ply:SelectWeapon("weapon_physgun")
			end
		end
	end)

	if (!self.Owner:CanDropWeapon(self)) then
		shieldEnt.NonDroppable = true
		table.RemoveByValue(self.Owner.Weapons, self)
	end

	self:Remove()
end


if SERVER then
	util.AddNetworkString('disable_shielddraw')
	util.AddNetworkString('shieldbash')
end

if CLIENT then
	net.Receive('disable_shielddraw',function()
		local weaponEntity = net.ReadEntity()
		local shieldProp = net.ReadEntity()
		if IsValid(shieldProp) then
			shieldProp:SetNoDraw(true)
			if IsValid(weaponEntity) then
				weaponEntity.shieldProp = shieldProp
			end
		end
	end)

	net.Receive('shieldbash',function()
		local ply = net.ReadEntity()
		if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
		ply:AnimRestartGesture(GESTURE_SLOT_GRENADE,ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND, true)
	end)
end


function SWEP:ViewModelDrawn(viewmodel)
	if IsValid(self.shieldProp) and !self.shieldProp:GetNoDraw() then
		self.shieldProp:SetNoDraw(true)
	end
end

function SWEP:DrawWorldModel()
	if IsValid(self.shieldProp) and self.shieldProp:GetNoDraw() then
		self.shieldProp:SetNoDraw(false)
	end
end

function SWEP:Reload()

end

function SWEP:Deploy()
	self:SetHoldType('physgun')
	self:SetupShield()
	return true
end

function SWEP:Holster()
	if CLIENT then return end
	if not IsValid(self.shieldProp) then return true end
	self.shieldProp:Remove()
	return true
end


function SWEP:OnDrop()
	if CLIENT then return end
	if not IsValid(self.shieldProp) then return true end
	self.shieldProp:Remove()
	return true
end

function SWEP:OnRemove()
	if CLIENT then return end
	if not IsValid(self.shieldProp) then return true end
	self.shieldProp:Remove()
	return true
end
