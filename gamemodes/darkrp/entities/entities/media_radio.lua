AddCSLuaFile()

ENT.Base				= 'media_base'
ENT.PrintName			= 'Radio'
ENT.Category 			= 'RP Media'
ENT.Spawnable			= true

ENT.MediaPlayer = true
ENT.RemoveOnJobChange 	= true

ENT.TimeLimit = 15
ENT.Model = 'models/props_lab/citizenradio.mdl'

function ENT:CanUse(pl)
	return pl:IsSuperAdmin() or (pl == self.ItemOwner) or (pl == self:CPPIGetOwner())
end

if (CLIENT) then
	function ENT:GetTickerText(str)
		if (not self:IsFrozen()) then
			return 'Freeze to play.', 40, 0
		end

		if self:IsPaused() then
			return 'Paused.', 60, 0
		end

		local tickertick = math.Remap(math.sin(CurTime()), -1, 1, 0, 1)

		surface.SetFont('Trebuchet18')
		local ts = surface.GetTextSize(str)

		local clippedextra = 0

		local extra = ts - 160
		local xmod = -extra*tickertick

		if xmod < 0 then
			str = str:sub(math.Round(math.abs(xmod) * 0.20))
		end

		local tsplus = xmod + extra
		if tsplus > 0 then
			local cutat = string.len(str) - math.Round(math.abs(tsplus) * 0.2)
			clippedextra = clippedextra - surface.GetTextSize(str:sub(cutat))

			str = str:sub(1, cutat)
		end

		return str, xmod + ts + clippedextra, TEXT_ALIGN_RIGHT
	end

	local color_red 	= ui.col.Red
	local color_white 	= ui.col.White
	local color_sup 	= ui.col.SUP
	function ENT:Draw()
		self:DrawModel()

		local pos = self:GetPos()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		pos = pos + ang:Up() * 8.5
		pos = pos + ang:Right() * -15.3
		pos = pos + ang:Forward() * -5.7

		cam.Start3D2D(pos, ang, 0.1)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, 170, 40)

			if self.Busy then
				local str, xmod, align = self:GetTickerText('Loading')
				draw.SimpleText(str, 'Trebuchet18', xmod, 8, ((not self:IsFrozen()) or self:IsPaused()) and color_red or color_white, align)
			elseif ((self:GetStart() + self:GetTime()) >= CurTime()) then
				draw.Box(0, 30, math.Clamp(170 * (CurTime() - self:GetStart())/self:GetTime(), 0, 170), 5, color_sup)
				draw.Outline(0, 30, 170, 5, color_white)

				local str, xmod, align = self:GetTickerText(self:GetTitle())
				draw.SimpleText(str, 'Trebuchet18', xmod, 8, ((not self:IsFrozen()) or self:IsPaused()) and color_red or color_white, align)
			else
				local str, xmod, align = self:GetTickerText('Press E to play something')
				draw.SimpleText(str, 'Trebuchet18', xmod, 8, ((not self:IsFrozen()) or self:IsPaused()) and color_red or color_white, align)
			end

		cam.End3D2D()
	end
end
