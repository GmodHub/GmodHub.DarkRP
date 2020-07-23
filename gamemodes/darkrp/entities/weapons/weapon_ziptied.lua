AddCSLuaFile()

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ''

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ''

function SWEP:Initialize()
	self:SetHoldType('duel')
	self.CreatedTime = CurTime()
	self.LastPerc = 0
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
	if (self.Owner:GetNetVar('ZiptieCutting') != nil) then return end

	self.struggleTime = self.struggleTime or self.Owner:CallSkillHook(SKILL_ZIPTIE_BREAK_FREE, rp.cfg.ZiptieStruggleTime)

	if (CurTime() < self.CreatedTime + self.struggleTime) then
		local tleft = math.max(self.CreatedTime +  self.struggleTime - CurTime(), 0)
		local min = math.floor(tleft / 60)
		local sec = math.floor(tleft - (min * 60))
		min = "0" .. min
		if (sec < 10) then sec = "0" .. sec end
		tleft = min .. ":" .. sec

		rp.ui.DrawCenteredProgress("Вы связаны! Можно выбраться через " ..  tleft)
	end
	/*else
		local w, h = surface.GetTextSize("Move around to break free!")
		w = w + 16
		local x = (ScrW() - w) * 0.5
		local y = ScrH() * 0.15

		surface.SetDrawColor(rp.col.Outline)
		surface.DrawOutlinedRect(x, y, w, h)

		surface.SetDrawColor(rp.col.Background)
		surface.DrawRect(x, y, w, h)

		surface.SetTextPos(x + 8, y)
		surface.SetTextColor(200, 50, 50, math.abs(math.sin(RealTime() * 2)) * 255)
		surface.DrawText("Move around to break free!")

		local perc = math.min((LocalPlayer():GetNetVar('ZiptieStruggle') or 0) / 100, 1)
		if (perc > 0) then
			local calcPerc = Lerp(0.05, self.LastPerc, perc)
			self.LastPerc = calcPerc
			surface.SetDrawColor(rp.col.Green)
			surface.DrawRect(x + calcPerc * w, y, 5, h)
		end

	end*/
end

function SWEP:Think()
	if (CLIENT) then return end

	self.struggleTime = self.struggleTime or self.Owner:CallSkillHook(SKILL_ZIPTIE_BREAK_FREE, rp.cfg.ZiptieStruggleTime)

	local pl = self.Owner
	if (pl.ZiptieTime < CurTime() - self.struggleTime and !pl:GetStruggle("Ziptie")) then
		pl:StartStruggle("Ziptie")
	end
end

net('rp.ZiptieStruggleReset', function(len)
	local newTime = net.ReadFloat()

	local wep = LocalPlayer():GetActiveWeapon()
	if (IsValid(wep) and wep:GetClass() == 'weapon_ziptied') then
		wep.CreatedTime = newTime
	end
end)
