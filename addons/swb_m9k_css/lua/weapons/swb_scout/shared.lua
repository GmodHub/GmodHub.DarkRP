AddCSLuaFile()

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Steyr Scout"
	SWEP.CSMuzzleFlashes = true

	SWEP.AimPos =  Vector(3.365, -5, 1.49)
	SWEP.AimAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-7.165, -10.157, 2.756)
	SWEP.SprintAng = Vector(-19.017, -70, 0)

	SWEP.ViewModelMovementScale = 1.15

	SWEP.ScopeOverrideMaterialIndex = 3
	SWEP.ScopeFlipX = true
	SWEP.TranslateY = -0.06
	SWEP.ScopeTexture = Material "sup/swb/scopes/scope3.png"

	SWEP.DelayedZoom = true
	SWEP.SnapZoom = false
	SWEP.SimulateCenterMuzzle = true

	SWEP.AdjustableZoom = true
	SWEP.MinZoom = 5
	SWEP.MaxZoom = 15
	SWEP.ZoomSteps = 4

	SWEP.IconLetter = "n"
	killicon.AddFont("swb_scout", "SWB_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

	SWEP.MuzzleEffect = "swb_rifle_large"
end

SWEP.HasScope = true
SWEP.PlayBackRate = 1
SWEP.PlayBackRateSV = 1
SWEP.FadeCrosshairOnAim = true
SWEP.PreventQuickScoping = true

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

SWEP.SpeedDec = 25
SWEP.BulletDiameter = 7.62
SWEP.CaseLength = 51

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.NormalHoldType = "ar2"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"bolt"}
SWEP.Base = "swb_base"
SWEP.Category = "SUP Weapons"

SWEP.Author			= "aStonedPenguin"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= true
SWEP.ViewModel = Model("models/weapons/22_snip_scout.mdl")	-- Weapon view model
SWEP.WorldModel = Model("models/weapons/3_snip_scout.mdl")	-- Weapon world model

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Rifle"

SWEP.FireDelay = 1.3
SWEP.FireSound = Sound("Alt_Weapon_Scout.1")
SWEP.Recoil = 2

SWEP.HipSpread = 0.055
SWEP.AimSpread = 0.00015
SWEP.VelocitySensitivity = 2
SWEP.MaxSpreadInc = 0.05
SWEP.SpreadPerShot = 0.05
SWEP.SpreadCooldown = 1.25
SWEP.Shots = 1
SWEP.Damage = 75
SWEP.DeployTime = 1