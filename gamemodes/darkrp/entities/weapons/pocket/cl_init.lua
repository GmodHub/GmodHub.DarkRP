include("pocket_controls.lua")
include("pocket_vgui.lua")
include("shared.lua")

SWEP.PrintName = "Карманы"
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.FrameVisible = false

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	rp.inv.EnableMenu()

	return
end
