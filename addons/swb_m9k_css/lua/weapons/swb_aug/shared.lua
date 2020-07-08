AddCSLuaFile()

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Steyr AUG"
	SWEP.CSMuzzleFlashes = true

	SWEP.AimPos = Vector(2.84, -1.7, 0.59)
	SWEP.AimAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-3.701, -7.008,0)
	SWEP.SprintAng = Vector(-10.197, -63.111, -4.134)

	SWEP.ScopeOverrideMaterialIndex = 0
	SWEP.ScopeFOV = 12
	SWEP.ScopeFlipX = true
	SWEP.ScopeTexture = Material "sup/swb/scopes/scope2.png"

	SWEP.OverrideAimMouseSens = 0.5

	SWEP.ViewModelMovementScale = 1.15

	SWEP.ZoomAmount = 15
	SWEP.DelayedZoom = true
	SWEP.SimulateCenterMuzzle = true

	SWEP.IconLetter = "e"
	killicon.AddFont("swb_aug", "SWB_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

	SWEP.MuzzleEffect = "swb_rifle_med"
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
SWEP.BulletDiameter = 5.56
SWEP.CaseLength = 45

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
SWEP.ViewModel = Model("models/weapons/22_rif_aug.mdl")	-- Weapon view model
SWEP.WorldModel = Model("models/weapons/3_rif_aug.mdl")	-- Weapon world model

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Rifle"

SWEP.FireDelay = 0.08
SWEP.FireSound = Sound("Alt_Weapon_AUG.1")
SWEP.Recoil = 1.05

SWEP.HipSpread = 0.053
SWEP.AimSpread = 0.0015
SWEP.VelocitySensitivity = 2.1
SWEP.MaxSpreadInc = 0.05
SWEP.SpreadPerShot = 0.01
SWEP.SpreadCooldown = 0.15
SWEP.Shots = 1
SWEP.Damage = 26
SWEP.DeployTime = 1