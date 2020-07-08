AddCSLuaFile()
AddCSLuaFile("sh_bullets.lua")
AddCSLuaFile("cl_model.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_calcview.lua")
AddCSLuaFile("sh_ammotypes.lua")
AddCSLuaFile("sh_move.lua")
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("cl_playerbindpress.lua")

include("sh_bullets.lua")
include("sh_ammotypes.lua")
include("sh_move.lua")
include("sh_sounds.lua")

game.AddParticles("particles/swb_muzzle.pcf")

PrecacheParticleSystem("swb_pistol_large")
PrecacheParticleSystem("swb_pistol_med")
PrecacheParticleSystem("swb_pistol_small")
PrecacheParticleSystem("swb_rifle_large")
PrecacheParticleSystem("swb_rifle_med")
PrecacheParticleSystem("swb_rifle_small")
PrecacheParticleSystem("swb_shotgun")
PrecacheParticleSystem("swb_silenced")
PrecacheParticleSystem("swb_silenced_small")
PrecacheParticleSystem("swb_sniper")

if CLIENT then
	include("cl_calcview.lua")
	include("cl_playerbindpress.lua")
	include("cl_model.lua")
	include("cl_hud.lua")

	SWEP.DrawCrosshair = false
	SWEP.BounceWeaponIcon = false
	SWEP.DrawWeaponInfoBox = false
	SWEP.CurFOVMod = 0
	SWEP.BobScale = 0
	SWEP.SwayScale = 0
	SWEP.FadeCrosshairOnAim = true
	SWEP.DrawAmmo = true
	SWEP.DrawTraditionalWorldModel = true
	SWEP.CrosshairEnabled = true
	SWEP.ViewbobEnabled = true
	SWEP.ViewbobIntensity = 1
	SWEP.ReloadViewBobEnabled = true
	SWEP.RVBPitchMod = 1
	SWEP.RVBYawMod = 1
	SWEP.RVBRollMod = 1
	SWEP.BulletDisplay = 0
	SWEP.Shell = "mainshell"
	SWEP.ShellScale = 1
	SWEP.CSMuzzleFlashes  = true
	SWEP.ZoomWait = 0
	SWEP.CrosshairParts = {left = true, right = true, upper = true, lower = true}
	SWEP.FireModeDisplayPos = "middle"
	SWEP.SwimPos = Vector(0, 0, -2.461)
	SWEP.SwimAng = Vector(-26.57, 0, 0)
	SWEP.ZoomAmount = 15
end

SWEP.ReloadState = {
	NONE = 0,
	START = 1,
	TWO = 2
}

SWEP.FadeCrosshairOnAim = true

if SERVER then
	include("sv_hooks.lua")
	SWEP.PlayBackRateSV = 1
end

SWEP.AimMobilitySpreadMod = 0.5
SWEP.PenMod = 1
SWEP.AmmoPerShot = 1
SWEP.SWBWeapon = true
SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 50
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= ""
SWEP.AnimPrefix		= "fist"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"

SWEP.PlayBackRateHip = 1
SWEP.PlayBackRate = 1
SWEP.ReloadSpeed = 1

SWEP.Chamberable = true
SWEP.UseHands = true
SWEP.CanPenetrate = true
SWEP.CanRicochet = true
SWEP.AddSafeMode = true
SWEP.Suppressable = false
SWEP.SprintingEnabled = true
SWEP.HolsterUnderwater = true
SWEP.HolsterOnLadder = true

SWEP.BurstCooldownMul = 1.75
SWEP.BurstSpreadIncMul = 0.5
SWEP.BurstRecoilMul = 0.85
SWEP.DeployTime = 1
SWEP.Shots = 1
SWEP.FromActionToNormalWait = 0

SWB_IDLE = 0
SWB_RUNNING = 1
SWB_AIMING = 2
SWB_ACTION = 3

SWEP.FireModeNames = {["auto"] = {display = "FULL-AUTO", auto = true, burstamt = 0, buldis = 5},
	["semi"] = {display = "SEMI-AUTO", auto = false, burstamt = 0, buldis = 1},
	["double"] = {display = "DOUBLE-ACTION", auto = false, burstamt = 0, buldis = 1},
	["bolt"] = {display = "BOLT-ACTION", auto = false, burstamt = 0, buldis = 1},
	["pump"] = {display = "PUMP-ACTION", auto = false, burstamt = 0, buldis = 1},
	["break"] = {display = "BREAK-ACTION", auto = false, burstamt = 0, buldis = 1},
	["2burst"] = {display = "2-ROUND BURST", auto = true, burstamt = 2, buldis = 2},
	["3burst"] = {display = "3-ROUND BURST", auto = true, burstamt = 3, buldis = 3},
	["safe"] = {display = "SAFE", auto = false, burstamt = 0, buldis = 0}}

local math = math

function SWEP:IsEquipment() -- I have no idea what I'm doing, help
	return WEPS.IsEquipment(self)
end

function SWEP:CalculateEffectiveRange()
	self.EffectiveRange = self.CaseLength * 10 - self.BulletDiameter * 5 -- setup realistic base effective range
	self.EffectiveRange = self.EffectiveRange * 39.37 -- convert meters to units
	self.EffectiveRange = self.EffectiveRange * 0.25
	self.DamageFallOff = (100 - (self.CaseLength - self.BulletDiameter)) / 200
	self.PenStr = (self.BulletDiameter * 0.5 + self.CaseLength * 0.35) * (self.PenAdd and self.PenAdd or 1)
	self.PenetrativeRange = self.EffectiveRange * 0.5
end

function SWEP:Initialize()
	self:SetSpreadUpdateTime(0)
	self:SetSpreadUpdateValue(0)

	self:SetHoldType(self.NormalHoldType)
	self:CalculateEffectiveRange()
	self.CHoldType = self.NormalHoldType

	if self.AddSafeMode then
		table.insert(self.FireModes, #self.FireModes + 1, "safe")
	end

	t = self.FireModes[1]
	self.FireMode = t
	t = self.FireModeNames[t]

	self.Primary.Auto = t.auto
	self.BurstAmount = t.burstamt

	self.Primary.ClipSize_Orig = self.Primary.ClipSize

	if CLIENT then
		self.ViewModelFOV_Orig = self.ViewModelFOV
		self.BulletDisplay = t.buldis
		self.FireModeDisplay = t.display

		if self.WM then
			self.WMEnt = ClientsideModel(self.WM, RENDERGROUP_BOTH)
			self.WMEnt:SetNoDraw(true)
		end
	end

	self:SetReloadDelay(-1)
end

function SWEP:GetCurrentCone(unpredicted)
	local owner = self:GetOwner()
	local state = self.dt.State

	local basecone

	if state == SWB_AIMING then
		basecone = self.AimSpread

		if owner.Expertise then
			basecone = basecone * (1 - owner.Expertise["steadyaim"].val * 0.0015)
		end
	else
		basecone = self.HipSpread

		if owner.Expertise then
			basecone = basecone * (1 - owner.Expertise["wepprof"].val * 0.0015)
		end
	end

	local vel = self:GetOwner():GetVelocity():Length()
	return math.Clamp(basecone + self:GetCurrentSpreadUpdate(unpredicted) +
		(vel / 10000 * self.VelocitySensitivity) * (state == SWB_AIMING and self.AimMobilitySpreadMod or 1)
		+ self:GetCurrentViewAffinity(unpredicted),
	0, 0.09 + self.MaxSpreadInc)
end

function SWEP:GetCurrentSpreadUpdate(unpredicted)
	local updatetime = self:GetSpreadUpdateTime(unpredicted)
	local value = self:GetSpreadUpdateValue(unpredicted)
	if (updatetime < CurTime()) then
		value = math.Clamp(value - 0.1333 * (CurTime() - updatetime), 0, self.MaxSpreadInc)
	end
	return value
end

function SWEP:GetCurrentViewAffinity(unpredicted)
	local value = math.Clamp(self:GetViewAffinity(unpredicted) - (self.ShotgunReload and 0.13 or 0.18) * (CurTime() - self:GetViewAffinityTime()) / self.FireDelay, 0, 2)
	return value
end

--[[
local function Accessor(varname, istime)
	SWEP["Unpredicted"..varname] = 0
	SWEP["Set"..varname] = function(self, time)
	print(varname, time)
		self["Set_"..varname](self, time)
		self["Unpredicted"..varname] = (istime and UnPredictedCurTime() - CurTime() or 0) + time
	end

	SWEP["Get"..varname] = function(self, unpredicted)
		if (unpredicted) then
			return self["Unpredicted"..varname]
		else
			return self["Get_"..varname](self, time)
		end
	end
end
Accessor("SpreadUpdateTime", true)
Accessor("SpreadUpdateValue")
Accessor("ViewAffinity")]]


function SWEP:SetupDataTables()
	self:DTVar("Int", 0, "State")
	self:DTVar("Int", 1, "Shots")
	self:DTVar("Bool", 0, "Suppressed")
	self:DTVar("Bool", 1, "Safe")
	self:NetworkVar("Int", 2, "ShotgunReloadState")
	self:NetworkVar("Float", 2, "ReloadDelay")
	self:NetworkVar("Float", 3, "ReloadWait")
	self:NetworkVar("Float", 4, "SpreadUpdateTime")
	self:NetworkVar("Float", 5, "SpreadUpdateValue")
	self:NetworkVar("Float", 6, "ViewAffinity")
	self:NetworkVar("Float", 7, "ViewAffinityTime")
end

local vm, CT, vel

function SWEP:Deploy()
	if self.dt.Suppressed then
		self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	else
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	self.dt.State = SWB_IDLE
	local CT = CurTime()

	self:SetNextSecondaryFire(CT + self.DeployTime)
	self:SetNextPrimaryFire(CT + self.DeployTime)
	return true
end

function SWEP:Holster()
	if self:GetReloadDelay() ~= -1 then
		return false
	end

	self:SetShotgunReloadState(self.ReloadState.NONE)
	self:SetReloadDelay(-1)
	self.dt.State = SWB_IDLE
	return true
end

local mag

function SWEP:Reload()
	local CT = CurTime()

	if self:GetReloadDelay() ~= -1 or CT < self:GetReloadWait() or self.dt.State == SWB_ACTION or self:GetShotgunReloadState() != 0 then
		return
	end

	if self.Owner:KeyDown(IN_USE) and self.dt.State != SWB_RUNNING then
		self:CycleFiremodes()
		return
	end

	mag = self:Clip1()

	if (self.Chamberable and mag >= self.Primary.ClipSize + 1) or (not self.Chamberable and mag >= self.Primary.ClipSize) or self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then
		return
	end

	if self.dt.State != SWB_RUNNING then
		self.dt.State = SWB_IDLE
	end

	if self.ShotgunReload then
		self:SetShotgunReloadState(self.ReloadState.START)
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		self:SetReloadDelay(CT + self.ReloadStartWait)
	else
		if self.Chamberable then
			if mag == 0 then
				self.Primary.ClipSize = self.Primary.ClipSize_Orig
			else
				self.Primary.ClipSize = self.Primary.ClipSize_Orig + 1
			end
		end

		if self.dt.Suppressed then
			self:DefaultReload(ACT_VM_RELOAD_SILENCED)
		else
			self:DefaultReload(ACT_VM_RELOAD)
		end

		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
	--[[self:SendWeaponAnim(ACT_VM_RELOAD)

	vm = self.Owner:GetViewModel()
	vm:SetPlaybackRate(self.ReloadSpeed)
	dur = vm:SequenceDuration() / self.ReloadSpeed

	self.ReloadDelay = CT + dur]]--
	--self:SetNextPrimaryFire(CT + dur)
	--self:SetNextSecondaryFire(CT + dur)
end

function SWEP:CycleFiremodes()
	local t = self.FireModes

	if not t.last then
		t.last = 2
	else
		if not t[t.last + 1] then
			t.last = 1
		else
			t.last = t.last + 1
		end
	end

	if self.dt.State == SWB_AIMING then
		if self.FireModes[t.last] == "safe" then
			t.last = 1
		end
	end

	if self.FireMode != self.FireModes[t.last] and self.FireModes[t.last] then
		CT = CurTime()
		self:SelectFiremode(self.FireModes[t.last])
		self:SetNextPrimaryFire(CT + 0.25)
		self:SetNextSecondaryFire(CT + 0.25)
		self:SetReloadWait(CT + 0.25)
	end
end

function SWEP:SelectFiremode(n)
	if CLIENT then
		return
	end

	local t = self.FireModeNames[n]
	self.Primary.Automatic = t.auto
	self.FireMode = n
	self.BurstAmount = t.burstamt

	if self.FireMode == "safe" then
		self.dt.Safe = true -- more reliable than umsgs
	else
		self.dt.Safe = false
	end

	umsg.Start("SWB_FIREMODE")
		umsg.Entity(self.Owner)
		umsg.String(n)
	umsg.End()
end

local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
local GetAimVector = reg.Player.GetAimVector

local SP = game.SinglePlayer()

local mag, ammo

function SWEP:IndividualThink()
	if ((SP and SERVER) or not SP) and self.dt.State == SWB_AIMING then
		if not self.Owner:OnGround() or Length(GetVelocity(self.Owner)) >= self.Owner:GetWalkSpeed() * 1.35 or not self.Owner:KeyDown(IN_ATTACK2) then
			CT = CurTime()
			self.dt.State = SWB_IDLE
			self:SetNextSecondaryFire(CT + 0.2)
		end
	end
end

local wl, ws

function SWEP:Think()
	local CT = CurTime()
	if self.IndividualThink then
		self:IndividualThink()
	end

	if (not IsValid(self.Owner)) then return end

	-- HACK HACK, clientside velocity isn't updated here yet, look into the past on server
	local cur_vel = Length(GetVelocity(self.Owner))
	vel = cur_vel
	if (SERVER) then
		vel = self.LastVelocity or 0
		self.LastVelocity = cur_vel
	end

	wl = self.Owner:WaterLevel()

	if self.Owner:OnGround() then
		if wl >= 3 and self.HolsterUnderwater then
			if self:GetShotgunReloadState() == self.ReloadState.START then
				self:SetShotgunReloadState(2)
			end

			self.dt.State = SWB_ACTION
			self.FromActionToNormalWait = CT + 0.3
		else -- main reload code
			ws = self.Owner:GetWalkSpeed()

			if ((vel > ws * 1.2 and self:GetOwner():KeyDown(IN_SPEED)) or vel > ws * 3 or (self.ForceRunStateVelocity and vel > self.ForceRunStateVelocity)) and self.SprintingEnabled then
				self.dt.State = SWB_RUNNING
			elseif self.dt.State != SWB_AIMING and CT > self.FromActionToNormalWait and self.dt.State != SWB_IDLE then
				self.dt.State = SWB_IDLE
				self:SetNextPrimaryFire(CT + 0.3)
				self:SetNextSecondaryFire(CT + 0.3)
				self:SetReloadWait(CT + 0.3)
			end
		end
	else
		if (wl > 1 and self.HolsterUnderwater) or (self.Owner:GetMoveType() == MOVETYPE_LADDER and self.HolsterOnLadder) then
			if self:GetShotgunReloadState() == self.ReloadState.START then
				self:SetShotgunReloadState(2)
			end

			self.dt.State = SWB_ACTION
			self.FromActionToNormalWait = CT + 0.3
		else
			if CT > self.FromActionToNormalWait then
				if self.dt.State != SWB_IDLE then
					self.dt.State = SWB_IDLE
					self:SetNextPrimaryFire(CT + 0.3)
					self:SetNextSecondaryFire(CT + 0.3)
					self:SetReloadWait(CT + 0.3)
				end
			end
		end
	end

	if self.dt.Shots > 0 then
		if not self.Owner:KeyDown(IN_ATTACK) then
			if self.BurstAmount and self.BurstAmount > 0 then
				self.dt.Shots = 0
				self:SetNextPrimaryFire(CT + self.FireDelay * self.BurstCooldownMul)
				self:SetReloadWait(CT + self.FireDelay * self.BurstCooldownMul)
			end
		end
	end

	if self:GetShotgunReloadState() == self.ReloadState.START then
		if self.Owner:KeyPressed(IN_ATTACK) then
			self:SetShotgunReloadState(2)
		end

		if CT > self:GetReloadDelay() then
			self:SendWeaponAnim(ACT_VM_RELOAD)

			if SERVER then
				self.Owner:SetAnimation(PLAYER_RELOAD)
			end

			mag, ammo = self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo)

			self:SetClip1(mag + 1)
			self.Owner:SetAmmo(ammo - 1, self.Primary.Ammo)

			self:SetReloadDelay(CT + self.ReloadShellInsertWait)

			if mag + 1 == self.Primary.ClipSize or ammo - 1 == 0 then
				self:SetShotgunReloadState(2)
			end
		end
	elseif self:GetShotgunReloadState() == 2 then
		if CT > self:GetReloadDelay() then
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
			self:SetShotgunReloadState(self.ReloadState.NONE)
			self:SetNextPrimaryFire(CT + self.ReloadFinishWait)
			self:SetNextSecondaryFire(CT + self.ReloadFinishWait)
			self:SetReloadWait(CT + self.ReloadFinishWait)
			self:SetReloadDelay(-1)
		end
	end

	if self.dt.Safe then
		if self.CHoldType != self.RunHoldType then
			self:SetHoldType(self.RunHoldType)
			self.CHoldType = self.RunHoldType
		end
	else
		if self.dt.State == SWB_RUNNING or self.dt.State == SWB_ACTION then
			if self.CHoldType != self.RunHoldType then
				self:SetHoldType(self.RunHoldType)
				self.CHoldType = self.RunHoldType
			end
		else
			if self.CHoldType != self.NormalHoldType then
				self:SetHoldType(self.NormalHoldType)
				self.CHoldType = self.NormalHoldType
			end
		end
	end

	--[[if self.ReloadDelay and CT >= self.ReloadDelay then
		mag, ammo = self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo)

		if self.ReloadAmount then
			if SERVER then
				self:SetClip1(math.Clamp(mag + self.ReloadAmount, 0, self.Primary.ClipSize))
				self.Owner:RemoveAmmo(self.ReloadAmount, self.Primary.Ammo)
			end
		else
			if mag > 0 then
				if ammo >= self.Primary.ClipSize - mag then
					if SERVER then
						self:SetClip1(math.Clamp(self.Primary.ClipSize, 0, self.Primary.ClipSize))
						self.Owner:RemoveAmmo(self.Primary.ClipSize - mag, self.Primary.Ammo)
					end
				else
					if SERVER then
						self:SetClip1(math.Clamp(mag + ammo, 0, self.Primary.ClipSize))
						self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
					end
				end
			else
				if ammo >= self.Primary.ClipSize then
					if SERVER then
						self:SetClip1(math.Clamp(self.Primary.ClipSize, 0, self.Primary.ClipSize))
						self.Owner:RemoveAmmo(self.Primary.ClipSize, self.Primary.Ammo)
					end
				else
					if SERVER then
						self:SetClip1(math.Clamp(ammo, 0, self.Primary.ClipSize))
						self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
					end
				end
			end
		end

		self.ReloadDelay = nil
	end]]--
end

local mul

function SWEP:PrimaryAttack()
	local CT = CurTime()
	if self:GetShotgunReloadState() != self.ReloadState.NONE then
		return
	end

	if self:GetReloadDelay() ~= -1 then
		return
	end

	if self.dt.Safe then
		self:CycleFiremodes()
		return
	end

	mag = self:Clip1()

	if mag == 0 then
		self:EmitSound("SWB_Empty", 100, 100)
		self:SetNextPrimaryFire(CT + 0.25)
		return
	end

	if self.dt.State == SWB_RUNNING or self.dt.State == SWB_ACTION then
		return
	end

	if self.BurstAmount and self.BurstAmount > 0 then
		if self.dt.Shots >= self.BurstAmount then
			return
		end

		self.dt.Shots = self.dt.Shots + 1
	end


	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if self.dt.Suppressed then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
	else
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end

	if self.FireAnimFunc then
		self:FireAnimFunc()
	else
		if self.dt.State == SWB_AIMING then
			if mag - self.AmmoPerShot <= 0 and self.DryFire then
				if self.dt.Suppressed then
					self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
				else
					self:SendWeaponAnim(ACT_VM_DRYFIRE)
				end
			else
				if self.dt.Suppressed then
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
				else
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				end
			end

			if self.FadeCrosshairOnAim then
				self.Owner:GetViewModel():SetPlaybackRate(self.PlayBackRateSV or 1)
			end
		else
			if mag - self.AmmoPerShot <= 0 and self.DryFire then
				if self.dt.Suppressed then
					self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
				else
					self:SendWeaponAnim(ACT_VM_DRYFIRE)
				end
			else
				if self.dt.Suppressed then
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
				else
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				end
			end

			if self.FadeCrosshairOnAim then
				self.Owner:GetViewModel():SetPlaybackRate(self.PlayBackRateHip or 1)
			end
		end
	end

	if IsFirstTimePredicted() then
		if self.dt.Suppressed then
			self:EmitSound(self.FireSoundSuppressed, 105, 100)
		else
			self:EmitSound(self.FireSound, 105, 100)
		end
	end

	self:FireBullet(self.Damage * (self.dt.Suppressed and 0.9 or 1), self:GetCurrentCone(), self.Shots)

	mul = 1

	if self.Owner:Crouching() then
		mul = mul * 0.75
	end

	if self.Owner.Expertise then
		mul = mul * (1 - self.Owner.Expertise["wepprof"].val * 0.002)

		if SERVER then
			if self.dt.State == SWB_AIMING then
				self.Owner:ProgressStat("steadyaim", self.Recoil * 1.5)
				self.Owner:ProgressStat("wepprof", self.Recoil * 0.5)
			else
				self.Owner:ProgressStat("wepprof", self.Recoil * 1.5)
			end

			self.Owner:ProgressStat("rechandle", self.Recoil)
		end
	end

	local spread = self:GetCurrentSpreadUpdate()
	if self.BurstAmount > 0 then
		spread = math.Clamp(spread + self.SpreadPerShot * self.BurstSpreadIncMul * mul, 0, self.MaxSpreadInc)
	else
		spread = math.Clamp(spread + self.SpreadPerShot * mul, 0, self.MaxSpreadInc)
	end
	self:SetSpreadUpdateTime(CurTime() + .077)
	self:SetSpreadUpdateValue(spread)
	self:SetViewAffinity(self:GetCurrentViewAffinity() + 0.2)
	self:SetViewAffinityTime(CurTime())

	if CLIENT and IsFirstTimePredicted() then
		if self.dt.State == SWB_AIMING then
			self.FireMove = 1
		else
			self.FireMove = 0.4
		end
	end

	self:MakeRecoil()

	self:TakePrimaryAmmo(self.AmmoPerShot)
	self:SetNextPrimaryFire(CT + self.FireDelay)
	self:SetNextSecondaryFire(CT + self.FireDelay)
	self:SetReloadWait(CT + (self.WaitForReloadAfterFiring and self.WaitForReloadAfterFiring or self.FireDelay))
end

local ang

function SWEP:MakeRecoil(mod)
	mod = mod and mod or 1

	if self.Owner:Crouching() then
		mod = mod * 0.75
	end

	if self.dt.State == SWB_AIMING then
		mod = mod * 0.85
	end

	if self.dt.Suppressed then
		mod = mod * 0.85
	end

	if self.BurstAmount > 0 then
		mod = mod * self.BurstRecoilMul
	end

	if self.Owner.Expertise then
		mod = mod * (1 - self.Owner.Expertise["rechandle"].val * 0.0015)
	end

	local ads = self.dt.State == SWB_AIMING and self.HasScope
	if (SP and SERVER) or (not SP and CLIENT and IsFirstTimePredicted()) then
		ang = self.Owner:EyeAngles()
		local mult = 0.2 + (ads and 0 or 0.3)
		ang.p = ang.p - self.Recoil * mult * mod

		if (not ads) then
			ang.y = ang.y + math.random(-1, 1) * self.Recoil * mult * mod
		end

		self.Owner:SetEyeAngles(ang)
	end

	self.Owner:ViewPunch(Angle(-self.Recoil * (0.5 + (ads and 0 or 0.75)) * mod, 0, 0))
end

function SWEP:SecondaryAttack()
	if self:GetShotgunReloadState() != self.ReloadState.NONE then
		return
	end

	if self:GetReloadDelay() ~= -1 then
		return
	end

	if self.dt.Safe then
		self:CycleFiremodes()
		return
	end

	if self.dt.State == SWB_RUNNING or self.dt.State == SWB_ACTION or self.dt.State == SWB_AIMING then
		return
	end

	if self.Suppressable and self.Owner:KeyDown(IN_USE) then
		self:ToggleSuppressor()
		return
	end

	if not self.Owner:OnGround() or Length(GetVelocity(self.Owner)) >= self.Owner:GetWalkSpeed() * 1.2 then
		return
	end

	CT = CurTime()

	self.dt.State = SWB_AIMING

	if (IsFirstTimePredicted()) then
		self.AimTime = CurTime() + 0.25
	end

	if self.PreventQuickScoping then
		self:SetSpreadUpdateValue(math.Clamp(self:GetCurrentSpreadUpdate() + 0.03, 0, self.MaxSpreadInc))
		self:SetSpreadUpdateTime(CurTime())
	end

	self:SetNextSecondaryFire(CT + 0.1)
end

function SWEP:ToggleSuppressor()
	if self.dt.Suppressed then
		self:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
	else
		self:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
	end

	vm = self.Owner:GetViewModel()
	dur = vm:SequenceDuration()
	CT = CurTime()

	self:SetNextPrimaryFire(CT + dur)
	self:SetNextSecondaryFire(CT + dur)
	self:SetReloadWait(CT + dur)
	self.dt.Suppressed = !self.dt.Suppressed
end

function SWEP:Equip()
end

if CLIENT then
	local EP, EA2, FT

	function SWEP:ViewModelDrawn()
		EP, EA2, FT = EyePos(), EyeAngles(), FrameTime()

		if IsValid(self.Hands) then
			self.Hands:SetRenderOrigin(EP)
			self.Hands:SetRenderAngles(EA2)
			self.Hands:FrameAdvance(FT)
			self.Hands:SetupBones()
			self.Hands:SetParent(self.Owner:GetViewModel())
			self.Hands:DrawModel()
		end
	end

	local wm, pos, ang
	local GetBonePosition = debug.getregistry().Entity.GetBonePosition

	local ply, wep

	local function SWB_ReceiveFireMode(um)
		ply = um:ReadEntity()
		Mode = um:ReadString()

		if IsValid(ply) then
			wep = ply:GetActiveWeapon()
			wep.FireMode = Mode

			if IsValid(ply) and IsValid(wep) and wep.SWBWeapon then
				if wep.FireModeNames then
					t = wep.FireModeNames[Mode]

					wep.Primary.Automatic = t.auto
					wep.BurstAmount = t.burstamt
					wep.FireModeDisplay = t.display
					wep.BulletDisplay = t.buldis
					wep.CheckTime = CurTime() + 2

					if ply == LocalPlayer() then
						ply:EmitSound("weapons/smg1/switch_single.wav", 70, math.random(92, 112))
					end
				end
			end
		end
	end

	usermessage.Hook("SWB_FIREMODE", SWB_ReceiveFireMode)
end