dash.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

function ENT:Draw()
	local pl = LocalPlayer()

	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), -90)

	cam.Start3D2D(pos + ang:Right() * -26 + ang:Up() * 10, ang, 0.05)
		draw.SimpleTextOutlined('Medic lab', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Price: $' .. self.dt.price .. '/hp', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined('$' .. self.dt.price * (100 - math.Clamp(pl:Health(), 0, 100)) .. ' total', '3d2d', 0, 130, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end

function ENT:PlayerUse()
	self:BasicPriceMenu()
end