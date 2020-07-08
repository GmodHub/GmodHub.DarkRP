AddCSLuaFile()

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "FN P90"
	SWEP.CSMuzzleFlashes = true

	SWEP.AimPos = Vector(3.09, -7, 0.39)
	SWEP.AimAng = Vector(0.089, 0, 0)

	SWEP.SprintPos = Vector(-5.38, -3.35, 1.48)
	SWEP.SprintAng = Vector(-17.362, -70, 0)

	SWEP.ScopeOverrideMaterialIndex = 4
	SWEP.ScopeFOV = 12
	SWEP.ScopeFlipX = true
	SWEP.ScopeRotate = 0
	SWEP.ScopeTexture = Material "sup/swb/scopes/p90.png"

	SWEP.OverrideMouseSensitivity = 1

	SWEP.ViewModelMovementScale = 0.85
	SWEP.Shell = "smallshell"

	SWEP.IconLetter = "m"
	killicon.AddFont("swb_mp5", "SWB_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

	SWEP.MuzzleEffect = "swb_rifle_med"
end

SWEP.HasScope = true
SWEP.FadeCrosshairOnAim = true

SWEP.PlayBackRate = 30
SWEP.PlayBackRateSV = 12
SWEP.SpeedDec = 20
SWEP.BulletDiameter = 5.7
SWEP.CaseLength = 28

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.NormalHoldType = "ar2"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"auto", "semi"}
SWEP.Base = "swb_base"
SWEP.Category = "SUP Weapons"

SWEP.Author			= "aStonedPenguin"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= true
SWEP.ViewModel = Model("models/weapons/22_smg_p90.mdl")	-- Weapon view model
SWEP.WorldModel = Model("models/weapons/3_smg_p90.mdl")	-- Weapon world model

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.FireDelay = 0.0666
SWEP.FireSound = Sound("Alt_Weapon_P90.1")
SWEP.Recoil = 0.9

SWEP.HipSpread = 0.043
SWEP.AimSpread = 0.007
SWEP.VelocitySensitivity = 1.5
SWEP.MaxSpreadInc = 0.05
SWEP.SpreadPerShot = 0.01
SWEP.SpreadCooldown = 0.1
SWEP.Shots = 1
SWEP.Damage = 18
SWEP.DeployTime = 1
SWEP.BurstCooldownMul = 3.5