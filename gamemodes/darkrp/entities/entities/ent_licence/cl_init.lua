dash.IncludeSH 'shared.lua'

local mat_license = Material 'gmh/hud/gunlicense.png'

local color_white = ui.col.White:Copy()

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(125000)

	if (not inView) then return end

	color_white.a = 255 - (dist/500)

	ang:RotateAroundAxis(ang:Up(), 90)

	cam.Start3D2D(pos + ang:Up() * 0.59, ang, 0.0095)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(mat_license)
		surface.DrawTexturedRect(-256, -512, 512, 512)

		draw.SimpleText('Gun License', '3d2d', 0, 150, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
