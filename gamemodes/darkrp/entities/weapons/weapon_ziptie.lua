AddCSLuaFile()

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.Slot = 3

SWEP.PrintName = "Стяжки"
SWEP.WorldModel = "models/props/cs_office/Snowman_arm.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ''

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ''

sound.Add({
	name = "sup_rp_ziptie",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "gmh/ziptie.ogg"
})

function SWEP:Equip()
	self.Owner:EmitSound("sup_rp_ziptie")
	timer.Simple(0.4, function()
		if (!IsValid(self)) then return end

		self.Owner:StopSound("sup_rp_ziptie")
	end)

	if (!self.Owner:CanUseZipties()) then
		rp.Notify(self.Owner, NOTIFY_ERROR, term.Get('ClassNoWeaponKnowledge'))
	end
end

function SWEP:Initialize()
	self:SetHoldType('duel')
end

function SWEP:PrimaryAttack()
	if (!self.Owner:CanUseZipties()) then
		return false
	end

	local tr = self.Owner:GetEyeTrace()
	if (IsValid(tr.Entity) and tr.Entity:IsPlayer() and !tr.Entity:IsZiptied() and !tr.Entity:IsCarrying() and !tr.Entity:IsArrested() and !tr.Entity:IsSOD()) then
		if (tr.Entity:GetPos():DistToSqr(self.Owner:GetPos()) > 3500) then return end
		if (self.Owner:InSpawn() or tr.Entity:InSpawn()) then return end

		self.Ziptying = {
			Targ = tr.Entity,
			LastPerc = 0,
			Time = CurTime()
		}

		if (SERVER) then
			self.Owner:EmitSound("sup_rp_ziptie")
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	local z = self.Ziptying
	if (z) then
		if (!self.Owner:CanUseZipties()) then
			self.Ziptying = nil

			if (SERVER) then
				self.Owner:StopSound("sup_rp_ziptie")
			end

			return
		end

		if (!self.Owner:KeyDown(IN_ATTACK) or !IsValid(z.Targ) or !z.Targ:Alive() or z.Targ:IsZiptied() or z.Targ:IsArrested() or z.Targ:IsSOD() or (z.Targ:GetPos():DistToSqr(self.Owner:GetPos()) > 3500)) then
			self.Ziptying = nil

			if (SERVER) then
				if (IsValid(z.Targ) and z.Targ:GetPos():DistToSqr(self.Owner:GetPos()) > 3500) then
					self.Owner:Notify(NOTIFY_ERROR, term.Get('CantZiptieDistance'))
				end

				self.Owner:StopSound("sup_rp_ziptie")
			end

			return
		end

		if (CurTime() - z.Time >= rp.cfg.ZiptieTime) then
			self.Ziptying = nil

			if (SERVER) then
				self.Owner:TakeKarma(2)
				self.Owner:Notify(NOTIFY_ERROR, term.Get('LostKarma'), 2, 'похищение ребёнка')

				hook.Call('playerZiptiedPlayer', nil, self.Owner, z.Targ)

				z.Targ:Ziptie()

				if not self.Owner:IsCP() and (z.Targ:IsCP() or z.Targ:IsMayor()) then
					self.Owner:Wanted(z.Targ, "Похищение")
				end

				if not self.Owner:IsCP() and (self.Owner:CloseToCPs()) then
					self.Owner:Wanted(nil, "Похищение")
				end

				self.Owner:StopSound("sup_rp_ziptie")
				self.Owner:StripWeapon('weapon_ziptie')
			end
		end
	end
end

function SWEP:DrawHUD()
	local z = self.Ziptying
	if (!z) then return end

	local perc = math.min((CurTime() - z.Time) / rp.cfg.ZiptieTime, 1)

	local str = "Связываем.."
	local w, h = surface.GetTextSize(str)
	w = w + 16
	local x = (ScrW() - w) * 0.5
	local y = ScrH() * 0.15

	surface.SetDrawColor(rp.col.Outline)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(rp.col.Background)
	surface.DrawRect(x, y, w, h)

	surface.SetTextPos(x + 8, y)
	surface.SetTextColor(200, 50, 50, 255)
	surface.DrawText(str)

	if (perc > 0) then
		local calcPerc = Lerp(0.05, z.LastPerc, perc)
		z.LastPerc = calcPerc
		surface.SetDrawColor(rp.col.Green)
		surface.DrawRect(x + calcPerc * w, y, 5, h)
	end
end

function SWEP:DrawWorldModel()
end
