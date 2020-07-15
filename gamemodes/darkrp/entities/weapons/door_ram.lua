AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName = 'Таран'
	SWEP.Slot = 2
	SWEP.Instructions = 'Left click to open doors and unfreeze props\nRight click to ready the ram'
end

SWEP.ViewModel = Model('models/weapons/c_rpg.mdl')
SWEP.WorldModel = Model('models/weapons/w_rocket_launcher.mdl')

SWEP.Primary.Sound = Sound('Canals.d1_canals_01a_wood_box_impact_hard3')

SWEP.Primary.Delay = 1

function SWEP:Deploy()
	if (not IsValid(self.Owner)) then return end

	self.HasDeployed = true
	self.Ironsights = false

	self.NewJump = 0
	self.OldJump = self.Owner:GetJumpPower() or 200
end

function SWEP:OnRemove()
	if (not IsValid(self.Owner)) or (not self.HasDeployed) or CLIENT then return end

	self.Owner:SetJumpPower(self.OldJump)
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:UnLockDoor(door)
	if door.Locked then
		door:DoorLock(false)
	end

	door:Fire('open', '', .6)
	door:Fire('setanimation', 'open', .6)
end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) or (not self.Ironsights) or CLIENT then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self.Owner:LagCompensation(true)
		local tr = self.Owner:GetEyeTrace()
	self.Owner:LagCompensation(false)

	local ent = tr.Entity
	if (not IsValid(ent)) or (self.Owner:EyePos():Distance(tr.HitPos) > self.HitDistance) then return end

	if ent:IsDoor() then
		local tar = ent:GetPropertyOwner()
		if IsValid(tar) and tar:IsWarranted() then
			self:Ram()

			self:UnLockDoor(ent)
			return
		end

		if ent:IsPropertyTeamOwned() then
			for _, t in ipairs(ent:GetPropertyInfo().Teams) do
				for _, pl in ipairs(team.GetPlayers(t)) do
					if pl:IsWarranted() then
						self:Ram()

						self:UnLockDoor(ent)

						return
					end
				end
			end
		end

		self.Owner:Notify(NOTIFY_ERROR, term.Get('MustTargetPlayerWithWarrant'))
	elseif ent:IsProp() then
		local tar = ent:CPPIGetOwner()
		if IsValid(tar) and tar:IsWarranted() then
			ent:Fade()

			tar.WarrantFadedProps = tar.WarrantFadedProps or {}
			tar.WarrantFadedProps[#tar.WarrantFadedProps + 1] = ent

			self:Ram()
		else
			self.Owner:Notify(NOTIFY_ERROR, term.Get('MustTargetPlayerWithWarrant'))
		end
	end
end

if SERVER then
	hook.Add('PlayerUnWarranted', 'ram.PlayerUnWarranted', function(pl)
		if pl.WarrantFadedProps then
			for k, v in ipairs(pl.WarrantFadedProps) do
				if IsValid(v) and v:IsFaded() then
					v:UnFade()
				end
			end
		end

		pl.WarrantFadedProps = nil
	end)
end

function SWEP:SecondaryAttack()
	if (not IsValid(self.Owner)) then return end

	if self.LastIron and (self.LastIron > (CurTime() - 0.5)) then return end

	self.Ironsights = (not self.Ironsights)
	self.LastIron = CurTime()

	if self.Ironsights then
		self.Owner:SetJumpPower(self.NewJump)
	else
		self.Owner:SetJumpPower(self.OldJump)
	end
end

function SWEP:Ram()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:EmitSound(self.Primary.Sound)
	self.Owner:ViewPunch(Angle(-10, math.random(-5, 5), 0))
end

function SWEP:GetViewModelPosition(pos, ang)
	local Mul = 1
	if self.LastIron and (self.LastIron > (CurTime() - 0.25)) then
		Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1)
	end

	if self.Ironsights then
		Mul = 1-Mul
	end

	ang:RotateAroundAxis(ang:Right(), - 15 * Mul)
	return pos,ang
end

if CLIENT then
	function SWEP:DrawHUD()
		if (not LocalPlayer():Alive()) then return end

		local w, h = 150, 25
		local x, y = ScrW() - w - 30, ScrH() - h - 30

		rp.ui.DrawProgress(x, y, w, h, (self.Primary.Delay - math.max(0, (self:GetNextPrimaryFire() - CurTime())))/self.Primary.Delay)
	end
end
