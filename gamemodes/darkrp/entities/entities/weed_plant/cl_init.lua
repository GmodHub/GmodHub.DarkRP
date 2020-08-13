include 'shared.lua'

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
	pos.z = (pos.z + 20) + (self:GetStage() * 15)

	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	cam.Start3D2D(pos, Angle(0, LocalPlayer():EyeAngles().yaw - 90, 90) , 0.045)
		draw.SimpleTextOutlined((self:GetStage() > 0 and 'Горшок Травы' or 'Горшок'), '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	cam.End3D2D()
end