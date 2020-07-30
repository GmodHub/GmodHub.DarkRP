AddCSLuaFile()

ENT.Base 		= 'drug_lab_base'
ENT.PrintName 	= 'Drug Lab'
ENT.Author 		= 'GmodHub'
ENT.Spawnable 	= true
ENT.Category 	= 'RP'

ENT.LabType = 'Наркотическая Лаборатория'
ENT.Model = 'models/props_lab/crematorcase.mdl'

if (CLIENT) then
	local LocalPlayer 	= LocalPlayer
	local Color 		= Color
	local cam 			= cam
	local draw 			= draw
	local Angle 		= Angle
	local Vector 		= Vector

	local off_vec = Vector(0,0,1.3)
	local color_text = Color(255,255,255)
	local color_textoutline = Color(0,0,0)

	local color_outline = Color(245,245,245)
	local color_grey 	= Color(50,50,50)
	local color_red 	= Color(255,50,50)
	local color_yellow 	= Color(255,255,50)
	local color_green 	= Color(50,255,50)

	local function barColor(perc)
		return ((perc <= .39) and color_red or ((perc <= .75) and color_yellow or color_green))
	end

	function ENT:Draw()
		self:DrawModel()

		local pos = self:GetPos()
		local ang = self:GetAngles()

		local inView, dist = self:InDistance(150000)

		if (not inView) then return end

		color_text.a = 255 - (dist/590)
		color_textoutline.a = color_text.a

		cam.Start3D2D(pos, Angle(0, LocalPlayer():EyeAngles().yaw - 90, 90) , 0.065)
			draw.SimpleTextOutlined(self.LabType, '3d2d', 0, -400, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_textoutline)
		cam.End3D2D()

		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 90)

		cam.Start3D2D(pos + off_vec, ang, 0.05)
			draw.OutlinedBox(-225, 220, 400, 60, color_grey, color_outline, 2)
			draw.Box(-221, 225, (392 * self:GetPerc()), 50, barColor(self:GetPerc()))
			draw.SimpleTextOutlined(math.Round(self:GetPerc() * 100, 0) .. '%', 'PrinterSmall', 0, 250, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_textoutline)
		cam.End3D2D()
	end
end
