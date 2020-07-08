dash.IncludeSH 'shared.lua'

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

local vec_off = Vector(0, 0, 30)
local ang_off = Angle(0, 90, 90)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance()

	if (not inView) then return end

	color_white.a = 255 - (dist/1000)
	color_black.a = color_white.a

	local nextuse = self:GetNextUse()
	if (nextuse > CurTime()) then
		cam.Start3D2D(pos + vec_off, ang + ang_off, .1)
			draw.SimpleTextOutlined(string.FormattedTime(nextuse - CurTime(), '%01i:%02i'), '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		cam.End3D2D()
	else
		cam.Start3D2D(pos + vec_off, ang + ang_off, .1)
			draw.SimpleTextOutlined('Dumpster', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		cam.End3D2D()
	end
end
