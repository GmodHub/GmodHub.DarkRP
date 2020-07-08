AddCSLuaFile()

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "AWP"
	SWEP.CSMuzzleFlashes = true

	SWEP.AimPos = Vector(5.62, -5, 1.63)
	SWEP.AimAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-2.599, -8.11, -0.709)
	SWEP.SprintAng = Vector(0, -62.559, 0)

	SWEP.ViewModelMovementScale = 1.25

	SWEP.ScopeTexture = Material "swb/scope_rifle"
	SWEP.ScopeOverrideMaterialIndex = 6
	SWEP.ScopeFlipX = true
	SWEP.TranslateY = -0.06
	SWEP.ScopeTexture = Material "sup/swb/scopes/scope3.png"

	SWEP.DelayedZoom = true
	SWEP.SimulateCenterMuzzle = true

	SWEP.AdjustableZoom = true
	SWEP.MinZoom = 3
	SWEP.MaxZoom = 17.5
	SWEP.ZoomSteps = 4

	SWEP.IconLetter = "r"
	killicon.AddFont("swb_awp", "SWB_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

	SWEP.MuzzleEffect = "swb_sniper"
end

SWEP.HasScope = true
SWEP.PlayBackRate = 1
SWEP.PlayBackRateSV = 1
SWEP.FadeCrosshairOnAim = true
SWEP.PreventQuickScoping = true

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

SWEP.SpeedDec = 40
SWEP.BulletDiameter = 8.58
SWEP.CaseLength = 69.20

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
SWEP.ViewModel = Model("models/weapons/22_snip_awp.mdl")	-- Weapon view model
SWEP.WorldModel = Model("models/weapons/3_snip_awp.mdl")	-- Weapon world model

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Rifle"

SWEP.FireDelay = 1.5
SWEP.FireSound = Sound("Alt_Weapon_AWP.1")
SWEP.Recoil = 5

SWEP.HipSpread = 0.06
SWEP.AimSpread = 0.0001
SWEP.VelocitySensitivity = 2.2
SWEP.MaxSpreadInc = 0.05
SWEP.SpreadPerShot = 0.05
SWEP.SpreadCooldown = 1.44
SWEP.Shots = 1
SWEP.Damage = 100
SWEP.DeployTime = 1