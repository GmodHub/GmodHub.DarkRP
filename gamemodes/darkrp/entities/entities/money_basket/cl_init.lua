include('shared.lua')

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_bg = Color(10,10,10)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(125000)

	if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a
	color_bg.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), -90)

	cam.Start3D2D((pos + self:GetForward() * (self:OBBMaxs().y - 4.25)), ang, 0.020)
		draw.Box(-550,-325,1100,650, color_bg)
		draw.SimpleTextOutlined(IsValid(self:Getowning_ent()) and self:Getowning_ent():Name() or 'Unknown', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Money: $' .. self:Getmoney(), '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end