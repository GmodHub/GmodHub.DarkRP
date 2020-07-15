AddCSLuaFile()

sound.Add( {
	name = "csgo_knife.Deploy",
	channel = CHAN_WEAPON,
	volume = 0.4,
	level = 65,
	sound = "csgo_knife/knife_deploy1.ogg"
} )

sound.Add( {
	name = "csgo_knife.Hit",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 65,
	sound = { "csgo_knife/knife_hit1.ogg", "csgo_knife/knife_hit2.ogg", "csgo_knife/knife_hit3.ogg", "csgo_knife/knife_hit4.ogg" }
} )

sound.Add( {
	name = "csgo_knife.HitWall",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 65,
	sound = { "csgo_knife/knife_hit_01.ogg", "csgo_knife/knife_hit_02.ogg", "csgo_knife/knife_hit_03.ogg", "csgo_knife/knife_hit_04.ogg", "csgo_knife/knife_hit_05.ogg" }
} )

sound.Add( {
	name = "csgo_knife.Slash",
	channel = CHAN_WEAPON,
	volume = {0.5, 1.0},
	pitch = {97, 105},
	level = 65,
	sound = { "csgo_knife/knife_slash1.ogg", "csgo_knife/knife_slash2.ogg" }
} )

sound.Add( {
	name = "csgo_knife.Stab",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 65,
	sound = "csgo_knife/knife_stab.ogg"
} )

-- Butterfly
sound.Add( {
	name = "csgo_ButterflyKnife.backstab01",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_backstab01.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.backstab02",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_backstab02.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.draw01",
	channel = CHAN_ITEM,
	volume = 0.6,
	soundlevel = 65,
	sound = "csgo_knife/bknife_draw01.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.draw02",
	channel = CHAN_ITEM,
	volume = 0.6,
	soundlevel = 65,
	sound = "csgo_knife/bknife_draw02.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look01_a",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look01_a.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look01_b",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look01_b.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look02_a",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look02_a.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look02_b",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look02_b.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look03_a",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look03_a.ogg"
} )

sound.Add( {
	name = "csgo_ButterflyKnife.look03_b",
	channel = CHAN_ITEM,
	volume = 0.4,
	soundlevel = 65,
	sound = "csgo_knife/bknife_look03_b.ogg"
} )

sound.Add( {
	name = "csgo_KnifeFalchion.inspect",
	channel = CHAN_STATIC,
	volume = 1,
	soundlevel = 65,
	sound = "csgo_knife/knife_falchion_inspect.ogg"
} )

sound.Add( {
	name = "csgo_KnifeFalchion.draw",
	channel = CHAN_STATIC,
	volume = {0.4, 0.9},
	pitch = {97, 105},
	soundlevel = 65,
	sound = "csgo_knife/knife_falchion_draw.ogg"
} )

sound.Add( {
	name = "csgo_KnifeFalchion.Catch",
	channel = CHAN_STATIC,
	volume = {0.3, 0.7},
	pitch = {97, 105},
	soundlevel = 65,
	sound = "csgo_knife/knife_falchion_catch.ogg"
} )

sound.Add( {
	name = "csgo_KnifeFalchion.Idlev2",
	channel = CHAN_STATIC,
	volume = 1,
	soundlevel = 65,
	sound = "csgo_knife/knife_falchion_idle.ogg"
} )

sound.Add( {
	name = "csgo_Weapon.WeaponMove1",
	channel = CHAN_ITEM,
	volume = 0.15,
	soundlevel = 65,
	sound = "csgo_knife/movement1.ogg"
} )

sound.Add( {
	name = "csgo_Weapon.WeaponMove3",
	channel = CHAN_ITEM,
	volume = 0.15,
	soundlevel = 65,
	sound = "csgo_knife/movement3.ogg"
} )

sound.Add( {
	name = "csgo_Weapon.WeaponMove2",
	channel = CHAN_ITEM,
	volume = 0.15,
	soundlevel = 65,
	sound = "csgo_knife/movement2.ogg"
} )

sound.Add( {
	name = "csgo_KnifePush.Attack1Heavy",
	channel = CHAN_STATIC,
	volume = {0.1, 0.2},
	pitch = {98, 105},
	level = 65,
	sound = { "csgo_knife/knife_push_attack1_heavy_01.ogg", "csgo_knife/knife_push_attack1_heavy_02.ogg", "csgo_knife/knife_push_attack1_heavy_03.ogg", "csgo_knife/knife_push_attack1_heavy_04.ogg" }
} )

sound.Add( {
	name = "csgo_KnifePush.LookAtStart",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 65,
	sound = { "csgo_knife/knife_push_lookat_start.ogg" }
} )

sound.Add( {
	name = "csgo_KnifePush.LookAtEnd",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 65,
	sound = { "csgo_knife/knife_push_lookat_end.ogg" }
} )

sound.Add( {
	name = "csgo_KnifePush.Draw",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 65,
	sound = { "csgo_knife/knife_push_draw.ogg" }
} )

sound.Add( {
	name = "KnifeBowie.draw",
	channel = CHAN_STATIC,
	volume = {0.7, 0.8},
	pitch = {99, 100},
	level = 65,
	sound = { "csgo_knife/knife_bowie_draw.ogg" }
} )

sound.Add( {
	name = "KnifeBowie.LookAtStart",
	channel = CHAN_STATIC,
	volume = {0.2, 0.2},
	pitch = {99, 100},
	level = 65,
	sound = { "csgo_knife/knife_bowie_inspect_start.ogg" }
} )

sound.Add( {
	name = "KnifeBowie.LookAtEnd",
	channel = CHAN_STATIC,
	volume = {0.2, 0.3},
	pitch = {99, 101},
	level = 65,
	sound = { "csgo_knife/knife_bowie_inspect_end.ogg" }
} )

if (SERVER) then
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom = false

end

if (CLIENT) then
	SWEP.PrintName          = "baseknife"
	SWEP.DrawAmmo           = false
	SWEP.DrawCrosshair      = true
	SWEP.ViewModelFOV       = 65
	SWEP.ViewModelFlip      = false
	SWEP.CSMuzzleFlashes    = true
	SWEP.UseHands           = true
end

SWEP.Category			= "GmodHub Knives"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.DrawWeaponInfoBox  	= false

SWEP.Weight					= 5
SWEP.AutoSwitchTo				= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage			    = -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo			    ="none"


SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			    ="none"

function SWEP:SetupDataTables() --This also used for variable declaration and SetVar/GetVar getting work
	self:NetworkVar("Float", 0, "InspectTime")
	self:NetworkVar("Float", 1, "IdleTime")
end

function SWEP:Initialize()
	self:SetSkin(self.SkinIndex or 0) -- Sets worldmodel skin
	self:SetHoldType(self.AreDaggers and "fist" or "knife") -- Avoid using SetWeaponHoldType! Otherwise the players could hold it wrong!
end

function SWEP:Think()
	self.Owner:GetViewModel():SetSkin(self.SkinIndex or 0) -- Maybe there is more sane way to change skingroup? Tell me if you know please.
	if CurTime()>=self:GetIdleTime() then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end
end

function SWEP:Deploy()
	self:SetInspectTime(0)
	self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	local NextAttack = 1
	self.Weapon:SetNextPrimaryFire(CurTime() + NextAttack)
	self.Weapon:SetNextSecondaryFire(CurTime() + NextAttack)
	return true
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

function SWEP:PrimaryAttack()
	if CurTime() < self.Weapon:GetNextPrimaryFire() then return end
	self:DoAttack(false)
end

function SWEP:SecondaryAttack()
	if CurTime() < self.Weapon:GetNextSecondaryFire() then return end
	self:DoAttack(true)
end

function SWEP:DoAttack(Altfire)
	local Weapon    = self.Weapon
	local Attacker  = self:GetOwner()
	local Range     = Altfire and 48 or 64
	local Forward 	= Attacker:GetAimVector()
	local AttackSrc = Attacker:EyePos()
	local AttackEnd = AttackSrc + Forward * Range
	local Act
	local Snd
	local Backstab
	local Damage

	Attacker:LagCompensation(true)

	local tracedata = {}

	tracedata.start     = AttackSrc
	tracedata.endpos    = AttackEnd
	tracedata.filter    = Attacker
	tracedata.mask      = MASK_SOLID
	tracedata.mins      = Vector(-16 , -16 , -18)
	tracedata.maxs      = Vector(16, 16 , 18)

	-- We should calculate trajectory twice. If TraceHull hits entity, then we use second trace, otherwise - first.
	-- It's needed to prevent head-shooting since in CS:GO you cannot headshot with knife
	local tr1 = util.TraceLine(tracedata)
	local tr2 = util.TraceHull(tracedata)
	local tr = IsValid(tr2.Entity) and tr2 or tr1

	Attacker:LagCompensation(false) -- Don't forget to disable it!

	local DidHit            = tr.Hit and not tr.HitSky
	-- local trHitPos          = tr.HitPos -- Unused
	local HitEntity         = tr.Entity
	local DidHitPlrOrNPC    = HitEntity and (HitEntity:IsPlayer() or HitEntity:IsNPC()) and IsValid(HitEntity)

	-- Calculate damage and deal hurt if we can
	if DidHit then
		if HitEntity and IsValid(HitEntity) then
			Backstab = DidHitPlrOrNPC and self:EntityFaceBack(HitEntity) -- Because we can only backstab creatures
			Damage = (Altfire and (Backstab and 100 or 50) ) or (Backstab and 75 ) or ((math.random(0,5) == 3) and 40) or 25

			if self.Primary.Damage > 0 then
				Damage = self.Primary.Damage
			end

			local damageinfo = DamageInfo()
			damageinfo:SetAttacker(Attacker)
			damageinfo:SetInflictor(self)
			damageinfo:SetDamage(Damage)
			damageinfo:SetDamageType(bit.bor(DMG_BULLET , DMG_NEVERGIB))
			damageinfo:SetDamageForce(Forward * 1000)
			damageinfo:SetDamagePosition(AttackEnd)
			HitEntity:DispatchTraceAttack(damageinfo, tr, Forward)

		else
			util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		end
	end

	--Change next attack time
	local NextAttack = Altfire and 1.0 or DidHit and 0.5 or 0.4
	Weapon:SetNextPrimaryFire(CurTime() + NextAttack)
	Weapon:SetNextSecondaryFire(CurTime() + NextAttack)

	--Send animation to attacker
	Attacker:SetAnimation(PLAYER_ATTACK1)

	--Send animation to viewmodel
	Act = DidHit and (Altfire and (Backstab and ACT_VM_SWINGHARD or ACT_VM_HITCENTER2) or (Backstab and ACT_VM_SWINGHIT or ACT_VM_HITCENTER)) or (Altfire and ACT_VM_MISSCENTER2 or ACT_VM_MISSCENTER)
	if Act then
		Weapon:SendWeaponAnim(Act)
		self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end

	--Play sound
	local StabSnd    = "csgo_knife.Stab"
	local HitSnd     = "csgo_knife.Hit"
	local HitwallSnd = "csgo_knife.HitWall"
	local SlashSnd   = "csgo_knife.Slash"
	Snd = DidHitPlrOrNPC and (Altfire and StabSnd or HitSnd) or DidHit and HitwallSnd or SlashSnd
	if Snd then Weapon:EmitSound(Snd) end

	return true
end

function SWEP:Reload()
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if (act == ACT_VM_IDLE_LOWERED and CurTime() < self:GetInspectTime()) then
		self:SetInspectTime(CurTime() + 0.1) -- We should press R repeately instead of holding it to loop
		return end

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self:SetInspectTime(CurTime() + 0.1)
	return true
end
