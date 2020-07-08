AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName		= 'Pimp Hand'
	SWEP.Instructions	= 'Left click to slap\nRight click to cough'
	SWEP.Purpose 		= 'Keep your hoes in check'
	SWEP.Slot			= 2
end

SWEP.Spawnable		= true

SWEP.ViewModel		= Model 'models/sup/weapons/pimphand.mdl'
SWEP.WorldModel		= ''
SWEP.HoldType		= 'normal'
SWEP.ViewModelFOV	= 90
SWEP.UseHands 		= false

SWEP.Sounds = {
	Hit = Sound('code_gs/pimphand/slap.ogg'),
	Miss = Sound('Weapon_Knife.Slash'),
	HitWorld = Sound('Default.ImpactSoft'),
	Cough = {
		Sound('ambient/voices/cough1.wav'),
		Sound('ambient/voices/cough2.wav'),
		Sound('ambient/voices/cough3.wav'),
		Sound('ambient/voices/cough4.wav')
	}
}


function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:DrawShadow(false)
end

function SWEP:Deploy()
	local check = (IsValid(self.Owner) and self.Owner:IsSuperAdmin()) and true or false
	self.Primary.Force = check and 100000 or 400
	self.Primary.Delay = check and 1 or 5
	self.Secondary.Delay = check and 1 or 5

	self:Reload()
end

function SWEP:ResetAnim(time)
	local tId = self:EntIndex() .. '.ResetAnim'

	if timer.Exists(tId) then timer.Remove(tId) end
	timer.Create(tId, time or 0.7, 1, function() if not IsValid(self) then return end self:SendWeaponAnim(ACT_VM_IDLE) end)
end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) then return end

	self:ResetAnim()

	if SERVER then

		self.Owner:LagCompensation(true)
			local tr = util.TraceHull({
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 40),
				mins = Vector(-8, -8, -8),
				maxs = Vector(8, 8, 8),
				filter = self.Owner
			})
		self.Owner:LagCompensation(false)

		local EmitSound = Sound('Weapon_Knife.Slash')
		self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

		if IsFirstTimePredicted() then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
		end

		if tr.Hit then
			local ent = tr.Entity
			local valid = IsValid(ent)
			local player = valid and ent:IsPlayer()
			local phys = valid and ent:GetClass() == 'prop_physics'
			if valid and (player or phys) then
				if player then
					hook.Call('PlayerSlapPlayer', nil, self.Owner, ent)

					EmitSound = self.Sounds.Hit
					if ent:HasSTD() and (math.random(1, 5) == 5) then
						ent:CureSTD()
						self.Owner:Notify(NOTIFY_SUCCESS, term.Get('PimpSTDCured'), ent)
					end
				else
					EmitSound = self.Sounds.HitWorld
				end

				local pos = tr.StartPos
				local dmginfo = DamageInfo()
					dmginfo:SetDamage(0)
					dmginfo:SetDamagePosition(pos)
					dmginfo:SetDamageType(DMG_CLUB)
					dmginfo:SetInflictor(self)
					dmginfo:SetAttacker(self.Owner)

					local vec = (tr.HitPos - pos):GetNormal()
					local force = self.Primary.Force
					if player then -- SetVelocity is more practical for players
						ent:SetVelocity(vec * force)
					else
						dmginfo:SetDamageForce(vec * force)
					end

				ent:TakeDamageInfo(dmginfo)
			else
				EmitSound  = self.Sounds.HitWorld
			end
		end

		self.Owner:EmitSound(EmitSound)
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local nextFire = CurTime() + 1
	if (self:GetNextSecondaryFire() < nextFire) then
		self:SetNextSecondaryFire(nextFire)
	end
end

function SWEP:Reload()
	if (self:GetNextPrimaryFire() > CurTime()) or (self:GetNextSecondaryFire() > CurTime()) then return end

	local nextFire = CurTime() + 1
	if (self:GetNextPrimaryFire() < nextFire) then
		self:SetNextPrimaryFire(nextFire)
	end

	if (self:GetNextSecondaryFire() < nextFire) then
		self:SetNextSecondaryFire(nextFire)
	end

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:ResetAnim(1)
end

function SWEP:SecondaryAttack()
	if not IsValid(self.Owner) then return end

	self:ResetAnim()

	if SERVER then
		self:SendWeaponAnim(ACT_VM_RECOIL1)
		self.Owner:EmitSound(self.Sounds.Cough[math.random(1,4)], 100)
	end

	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	local nextFire = CurTime() + 1
	if (self:GetNextPrimaryFire() < nextFire) then
		self:SetNextPrimaryFire(nextFire)
	end
end