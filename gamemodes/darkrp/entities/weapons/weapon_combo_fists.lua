SWEP.Base = "basecombatweapon"
SWEP.PrintName				= "Combo Fists"
SWEP.Author					= "code_gs"
SWEP.Purpose				= "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot					= 2
SWEP.SlotPos				= 2

SWEP.Spawnable				= true

SWEP.ViewModel				= Model("models/code_gs/weapons/c_fists.mdl")
SWEP.WorldModel				= ""
SWEP.ViewModelFOV			= 75
SWEP.UseHands				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cooldown 		= 0.2

SWEP.DrawAmmo				= false
SWEP.HoldType 				= "fist"
SWEP.HitDistance			= 45
SWEP.Damage 				= 10
SWEP.Deviation 				= 5
SWEP.Force 					= 1000
SWEP.Multiplier 			= 1000
SWEP.AnimDelay 				= 0.1

SWEP.Sounds = {
	[ "primary" ] = "Flesh.ImpactHard",
	[ "secondary" ] = "WeaponFrag.Throw"
}

SWEP.KnockSounds = {
	Sound("physics/flesh/flesh_impact_bullet2.wav"),
	Sound("physics/flesh/flesh_impact_bullet4.wav"),
	Sound("physics/flesh/flesh_impact_bullet5.wav")
}

local function resetDoor(door, fakedoor)
	door:SetNotSolid(false)
	door:SetNoDraw(false)
	door.FistHits = nil

	if (IsValid(fakedoor)) then
		fakedoor:Remove()
	end
end

function SWEP:ThugKnock(door)
	self.Owner:EmitSound(self.KnockSounds[math.random(#self.KnockSounds)])

	if (door:GetPropertyNetworkID() == nil) then -- Unmapped door, don't let em break it down
		return
	end

	if (!self.Owner:IsWanted() and !self.Owner:IsArrested() and self.Owner:CloseToCPs() and math.random(4) == 4) then
		self.Owner:Wanted(nil, "Breaking and entering!")

		return
	end

	if (IsValid(self.Door) and (self.Door ~= door)) or (not self.NeedFistHits) then
		self.NeedFistHits = math.floor(self.Owner:CallSkillHook(SKILL_THUG, (self.Owner:IsArrested() and math.random(120, 180) or math.random(40, 60))))
	end

	self.Door = door

	door.FistHits = door.FistHits and (door.FistHits + 1) or 1

	if (door.FistHits > self.NeedFistHits) then
		self.Door = nil
		self.NeedFistHits = nil

		hook.Call('PlayerBreakDownDoor', nil, self.Owner, door)

		door:Fire("unlock", "", .5)
		door:Fire("open", "", .6)
		door:Fire("setanimation", "open", .6)
		door:EmitSound("physics/wood/wood_crate_break" .. math.random(5) .. ".wav")

		local pos = door:GetPos()
		local ang = door:GetAngles()
		local model = door:GetModel()
		local skin = door:GetSkin()

		rp.Notify(self.Owner, NOTIFY_ERROR, term.Get('LostKarmaNR'), 1)
		self.Owner:TakeKarma(2)

		door:SetNotSolid(true)
		door:SetNoDraw(true)

		local norm = (pos - self.Owner:GetPos()):GetNormal()
		local push = 10000 * norm
		local ent = ents.Create("prop_physics")

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetModel(model)

		if (skin) then
			ent:SetSkin(skin)
		end

		ent:Spawn()
		ent.ShareGravgun = true

		timer.Simple(0.01, function()
			if IsValid(ent) then
				ent:SetVelocity(push)
				ent:GetPhysicsObject():ApplyForceCenter(push)
			end
		end)
		timer.Simple(25, function() resetDoor(door, ent) end)
	end
end

function SWEP:PrimaryAttack(right)
	if (not self:CanPrimaryAttack()) then
		return
	end

	self:DoFireEffects(right)

	self:SetNextPrimaryFire(CurTime() + 0.4)
	self:SetNextSecondaryFire(CurTime() + 0.4)

	if (CLIENT) then return end

	self:AddContextThink(function()
		local pPlayer = self:GetOwner()

		if (pPlayer == NULL) then
			return true
		end

		pPlayer:LagCompensation(true)

		local vecShoot = pPlayer:GetShootPos()
		local vecAim = pPlayer:GetAimVector()

		local tr = util.TraceLine( {
			start = vecShoot,
			endpos = vecShoot + vecAim * self.HitDistance,
			filter = pPlayer,
			mask = MASK_SHOT_HULL
		} )

		if (tr.Entity == NULL) then -- Fix
			tr = util.TraceHull( {
				start = vecShoot,
				endpos = vecShoot + vecAim * self.HitDistance,
				filter = pPlayer,
				mins = Vector(-10, -10, -8),
				maxs = Vector(10, 10, 8),
				mask = MASK_SHOT_HULL
			} )
		end

		local ent = tr.Entity

		if (ent ~= NULL) then
			self:PlaySound("primary")
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(pPlayer)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(self.Owner:IsArrested() and 1 or minstd:RandomInt(self.Damage - self.Deviation, self.Damage + self.Deviation))
			dmginfo:SetDamageForce(pPlayer:GetRight() * 4912 * (right and -1 or 1) + pPlayer:GetForward() * self.Force)
			ent:TakeDamageInfo(dmginfo)

			local pPhys = ent:GetPhysicsObject()

			if (pPhys:IsValid()) then -- Physics objects show up as [NULL PhysObject] and not NULL
				pPhys:ApplyForceOffset(vecAim * self.Multiplier * pPhys:GetMass(), tr.HitPos)
			end

			if ((self.Owner:Team() == TEAM_THUG) or self.Owner:IsArrested()) and ent:IsDoor() then
				self:ThugKnock(ent)
			end
		end

		pPlayer:LagCompensation(false)

		return true
	end, self.AnimDelay )

end

function SWEP:SecondaryAttack()

	self:PrimaryAttack(true)

end
-- No muzzle flash
function SWEP:DoFireEffects(right)
	self:_SendWeaponAnim(self:LookupActivity(right and "secondary" or "primary"))
	if (SERVER) then
		self:PlaySound("secondary")
	end

	local pPlayer = self:GetOwner()

	if (pPlayer ~= NULL) then
		pPlayer:SetAnimation(pPlayer:LookupAnimation("attack"))
	end
end
