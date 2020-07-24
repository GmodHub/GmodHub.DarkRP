include('shared.lua')

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(125000)

	if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), -90)

	cam.Start3D2D((self:GetPos() + self:GetUp() * self:OBBMaxs().z) + Vector(0, 0, 5), ang, 0.15)
		draw.SimpleTextOutlined('Полицейский Геном', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	cam.End3D2D()
end
