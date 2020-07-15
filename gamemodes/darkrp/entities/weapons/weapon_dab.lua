SWEP.PrintName = "Dab"
SWEP.Author = "Dexter Barnes"
SWEP.Contact = "Addon Page"
SWEP.Purpose = "Cool kid memes"
SWEP.Instructions = "Left Click: Dab.\nRight Click: Dab with that bass-boosted sound effect."
SWEP.Category = "RP"
SWEP.DrawCrosshair = false
SWEP.Base = "weapon_base"
SWEP.Slot = 2
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "None"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
	if self.Owner:OnGround() then
		self.Owner:DoAnimationEvent(ACT_HL2MP_RUN_CHARGING)
		self:ApplyBHop()
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:OnGround() then
		self.Owner:DoAnimationEvent(ACT_HL2MP_RUN_CHARGING)
		self:ApplyBHop()
		self:EmitSound("gmh/dab.ogg",50,math.random(98,102))
	end
end

function SWEP:ApplyBHop()
	if (not self.Owner:IsGA()) then return end
	self.Owner:SetVelocity(Vector(self.Owner:GetForward().x,self.Owner:GetForward().y,0)*300)
end

function SWEP:Think() end
function SWEP:Reload() end