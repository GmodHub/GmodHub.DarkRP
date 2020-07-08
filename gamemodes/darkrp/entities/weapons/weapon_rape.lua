/*if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName = "Pick Pocket"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Instructions = "Left click to rape someone"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_lockpick.mdl")
SWEP.WorldModel = Model('models/sup/weapons/lockpick/lockpick.mdl')

SWEP.Spawnable = true
SWEP.Category = "RP"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.RapeCooldown = 180

local RapistVoices = {
	"vo/npc/male01/likethat.wav",
	"vo/coast/odessa/male01/nlo_cheer02.wav",
	"vo/coast/odessa/male01/nlo_cheer03.wav",
	"vo/coast/odessa/male01/nlo_cheer04.wav",
	"player/crit_death1.wav",
	"player/crit_death2.wav",
	"player/crit_death3.wav",
	"player/crit_death4.wav",
	"player/crit_death5.wav",
	"bot/come_to_papa.wav",
	"bot/im_pinned_down.wav",
	"bot/oh_man.wav",
	"bot/yesss.wav",
	"bot/pain4",
	"bot/pain5",
	"bot/pain8",
	"bot/pain9",
	"bot/pain10",
	"bot/stop_it.wav",
	"bot/help.wav",
	"bot/i_could_use_some_help.wav",
	"bot/i_could_use_some_help_over_here.wav",
	"bot/they_got_me_pinned_down_here.wav",
	"bot/this_is_my_house.wav",
	"bot/need_help.wav",
	"bot/i_am_dangerous.wav",
	"bot/yikes.wav",
	"noo.wav",
	"bot/whos_the_man.wav",
	"bot/hang_on_im_coming.wav",
	"hostage/hpain/hpain1.wav",
	"hostage/hpain/hpain2.wav",
	"hostage/hpain/hpain3.wav",
	"hostage/hpain/hpain4.wav",
	"hostage/hpain/hpain5.wav",
	"hostage/hpain/hpain6.wav",
	"vo/k_lab/al_youcoming.wav",
	"vo/k_lab/kl_ahhhh.wav",
}

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:Deploy()
	if (CLIENT) then return end

	self:SetNextFire(self:GetOwner().RapeCooldown or CurTime())
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end

	local pl = self:GetOwner()
	local target = pl:GetEyeTrace().Entity

	if (self:GetNextFire() > CurTime()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(self:GetNextFire() - CurTime()))
		return
	end

	if (not IsValid(target)) or (not target:IsPlayer()) or (pl:EyePos():DistToSqr(target:GetPos()) > 28900) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GetCloser'))
		return
	end

	if pl:InSpawn() or target:InSpawn() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NotAllowedInSpawn'), 'rape')
		return
	end

	if pl:IsZiptied() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NoRangeOfMotion'))
		return
	end

	if target:IsFrozen() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('TargetFrozen'))
		return
	end

	rp.Notify(pl, NOTIFY_ERROR, term.Get('LostKarmaNR'), 2)
	pl:TakeKarma(10)

	hook.Call('PlayerPickPocket', nil, pl, target)

	pl.RapeCooldown = CurTime() + self.RapeCooldown
	self:SetNextFire(pl.RapeCooldown)

	local rand = math.random(0, 10)


	if (not pl:IsWanted()) and (not pl:IsArrested()) and pl:CloseToCPs() then
		pl:Wanted(nil, "Rape")
	end

end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "NextFire")
end

if CLIENT then
	function SWEP:DrawHUD()
		if (not LocalPlayer():Alive()) then return end

		local w, h = 150, 25
		local x, y = ScrW() - w - 30, ScrH() - h - 30

		rp.ui.DrawProgress(x, y, w, h, 1 - math.max(self:GetNextFire() - CurTime(), 0)/self.RapeCooldown)
	end
end
