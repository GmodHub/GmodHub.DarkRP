SWEP.PrintName 					= 'Pocket'
SWEP.Slot 						= 1
SWEP.SlotPos 					= 1
SWEP.DrawAmmo 					= false
SWEP.DrawCrosshair 				= false

SWEP.Author 					= 'KingofBeast\n Updated by aStonedPenguin'
SWEP.Instructions				= 'Left click with your crosshair on an item to pocket it.'
SWEP.Contact 					= ''
SWEP.Purpose 					= ''

SWEP.ViewModel 					= 'models/weapons/v_hands.mdl'
SWEP.WorldModel					= ''

SWEP.ViewModelFOV 				= 62
SWEP.ViewModelFlip 				= false

SWEP.Spawnable 					= false
SWEP.Category 					= 'RP'
SWEP.Primary.ClipSize 			= -1
SWEP.Primary.DefaultClip 		= 0
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 				= ''

SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= 0
SWEP.Secondary.Automatic 		= false
SWEP.Secondary.Ammo 			= ''

function SWEP:PreDrawViewModel(vm)
	vm:SetMaterial('engine/occlusionproxy')
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Deploy()
	if timer.Exists("KeyHands") then timer.Remove("KeyHands") end -- Fucking SWEP function order
	--if not self.UseHands then self.UseHands = true end
	timer.Create("KeyHands", 1, 1, function() self.UseHands = false end)
	self:SetHoldType("normal")
end

function SWEP:OnRemove()
	if timer.Exists("KeyHands") then timer.Remove("KeyHands") end

	if not IsValid(self.Owner) then return end

	local vm = self.Owner:GetViewModel()
	if IsValid(vm) then vm:SetMaterial("") end
end

function SWEP:Holster()
	self:OnRemove()
	return true
end
