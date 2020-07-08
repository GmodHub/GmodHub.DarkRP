include 'shared.lua'

ENT.Mode = 1
ENT.ModeTime = 0
ENT.DingsLeft = 0

local colors = {
	rp.col.Black,
	rp.col.Green,
	rp.col.Red,
}

function ENT:Think()
	if (self.Mode != 1) then
		if (SysTime() > self.ModeTime) then
			if (self.DingsLeft == 0) then
				self.Mode = 1
				return
			end

			self:EmitSound('ambient/alarms/klaxon1.wav')
			self.DingsLeft = self.DingsLeft - 1
			self.ModeTime = SysTime() + 0.9
		end
	end
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	cam.Start3D2D(self:GetPos() + ang:Up() * 0.65, ang, 0.1)
		draw.Box(-225, -606, 460, 144, colors[self.Mode])
	cam.End3D2D()
end

net('rp_metaldetector_fail', function(len)
	local ent = net.ReadEntity()
	if (IsValid(ent) and ent:GetClass() == "metal_detector") then
		ent.Mode = 3
		ent.DingsLeft = 3
		ent.ModeTime = SysTime()
	end
end)

net('rp_metaldetector_pass', function(len)
	local ent = net.ReadEntity()
	if (IsValid(ent) and ent:GetClass() == "metal_detector") then
		ent.Mode = 2
		ent.DingsLeft = 0
		ent.ModeTime = SysTime() + 0.9
		ent:EmitSound('HL1/fvox/bell.wav')
	end
end)