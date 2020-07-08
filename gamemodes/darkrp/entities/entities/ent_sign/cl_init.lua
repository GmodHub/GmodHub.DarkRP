dash.IncludeSH 'shared.lua'

local color_black = ui.col.Black

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 85)
	ang:RotateAroundAxis(ang:Right(), 1)

	cam.Start3D2D(self:GetPos() + (self:GetUp() * 30) + (self:GetForward() * 0.1), ang, 0.022)
		draw.SimpleText(self:GetText1(), '3d2d', 0, -150, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(self:GetText2(), '3d2d', 0, -50, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(self:GetText3(), '3d2d', 0, 50, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end
