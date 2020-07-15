AddCSLuaFile()

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "SIG SG550"
	SWEP.CSMuzzleFlashes = true

	SWEP.AimPos = Vector(3.46, -3.4, 1.315)
	SWEP.AimAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-4.961, -5.907, 3.227)
	SWEP.SprintAng = Vector(-17.914, -65.316, -6.34)

	SWEP.ViewModelMovementScale = 1.15

	SWEP.ScopeOverrideMaterialIndex = 9
	SWEP.ScopeFlipX = true
	SWEP.TranslateY = -0.06
	SWEP.ScopeTexture = Material "gmh/swb/scopes/scope1.png"

	SWEP.DelayedZoom = true
	SWEP.SimulateCenterMuzzle = true

	SWEP.AdjustableZoom = true
	SWEP.MinZoom = 5
	SWEP.MaxZoom = 25
	SWEP.ZoomSteps = 4

	SWEP.MuzzleEffect = "muzzleflash_m14"
	SWEP.PosBasedMuz = true
	SWEP.IconLetter = "o"
	killicon.AddFont("swb_sg550", "SWB_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

	SWEP.MuzzleEffect = "swb_rifle_med"
	SWEP.MuzzlePosMod = {x = 7, y = 55, z = -3}
	SWEP.PosBasedMuz = true
end

SWEP.HasScope = true
SWEP.PlayBackRate = 1
SWEP.PlayBackRateSV = 1
SWEP.FadeCrosshairOnAim = true
SWEP.PreventQuickScoping = true

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

SWEP.SpeedDec = 30
SWEP.BulletDiameter = 5.56
SWEP.CaseLength = 45

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.NormalHoldType = "ar2"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"semi"}
SWEP.Base = "swb_base"
SWEP.Category = "SUP Weapons"

SWEP.Author			= "aStonedPenguin"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= true
SWEP.ViewModel = Model("models/weapons/22_snip_sg550.mdl")	-- Weapon view model
SWEP.WorldModel = Model("models/weapons/3_snip_sg550.mdl")	-- Weapon world model

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Rifle"

SWEP.FireDelay = 0.0857
SWEP.FireSound = Sound("Alt_Weapon_SG550.1")
SWEP.Recoil = 1.1

SWEP.HipSpread = 0.055
SWEP.AimSpread = 0.00025
SWEP.VelocitySensitivity = 2.2
SWEP.MaxSpreadInc = 0.05
SWEP.SpreadPerShot = 0.01
SWEP.SpreadCooldown = 0.15
SWEP.Shots = 1
SWEP.Damage = 28
SWEP.DeployTime = 1