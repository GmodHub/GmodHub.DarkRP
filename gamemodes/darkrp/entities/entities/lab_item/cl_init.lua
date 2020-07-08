dash.IncludeSH 'shared.lua'

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector
local CurTime = CurTime

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Right(), math.sin(CurTime() * math.pi) * -45)

	local stext
	if self:GetID() == 0 then
		stext = "Empty!"
	else
		stext = self:Getcount() .. "x "..self:GetGunName()
	end

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined(stext, '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Price: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined(stext, '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Price: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end

function ENT:PlayerUse()
	self:BasicPriceMenu()
end