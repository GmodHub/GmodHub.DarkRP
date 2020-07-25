include('shared.lua')

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	local owner = IsValid(self:Getowning_ent()) and self:Getowning_ent():Name() or 'unknown'

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 76.5)

	cam.Start3D2D(pos + (ang:Right() * -20) + (ang:Up() * -14.51) , ang, 0.0225)
		draw.SimpleTextOutlined(owner, '3d2d', 0, -80, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Пожертвования: $' .. self:Getmoney(), '3d2d', 0, -80, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end
