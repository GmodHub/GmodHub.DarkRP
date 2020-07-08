dash.IncludeSH 'shared.lua'

local mat_locked = Material("sup/entities/biometric/locked.png", "smooth")
local mat_unlocked = Material("sup/entities/biometric/unlocked.png", "smooth")

function ENT:Draw()
	self.BaseClass.Draw(self)

	local distance = LocalPlayer():EyePos():DistToSqr(self:GetPos())
	if (distance > 562500) then return end

	local pos = self:GetPos() + (self:GetUp() * 2.52) + (self:GetRight() * 15)
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 90)

	cam.Start3D2D(pos, ang, 0.05)
		local x, y, w, h = 0, -45, 315, 265

		draw.Box(x, y, w, h, ui.col.Black)

	local tX = (w * 0.5)
		draw.SimpleText(rp.FormatMoney(self:Getprice()), 'ui.24', tX, y + 5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(self:GetOneTimeUse() and 'One Time Use' or 'Permanent Entry', 'ui.22', tX, (y + h) - 5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

		local status = self:GetStatus()

		if (status == 1) then -- unlocked
			surface.SetDrawColor(25, 225, 25, 255)
			surface.SetMaterial(mat_unlocked)
			surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
		elseif (status == 2) then -- locked & denied
			surface.SetDrawColor(225, 25, 25, 255)
			surface.SetMaterial(mat_locked)
			surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
		else -- locked
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mat_locked)
			surface.DrawTexturedRect(x + (w * 0.5) - 64, y + (h * 0.5) - 64, 128, 128)
		end

	cam.End3D2D()
end

function ENT:Initialize()
	self.LookTime = 0
end

function ENT:Think()
	self:UpdateLever()
end

function ENT:UpdateLever()
	self.PosePosition = self.PosePosition or 0

	self.PosePosition = math.Approach(self.PosePosition, self:IsBusy() and 1 or 0, 0.1)

	self:SetPoseParameter("switch", self.PosePosition)
	self:InvalidateBoneCache()
end