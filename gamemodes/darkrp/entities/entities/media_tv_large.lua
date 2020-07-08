AddCSLuaFile()

ENT.Base		= 'media_base'
ENT.PrintName	= 'Large TV'
ENT.Category 	= 'RP Media'
ENT.Spawnable	= true

ENT.MediaPlayer = true

ENT.Model 		= 'models/hunter/plates/plate2x3.mdl'

local color_black = Color(10, 10, 10)
function ENT:Initialize()
	self:SetMaterial('models/debug/debugwhite')
	self:SetColor(color_black)

	self.BaseClass.Initialize(self)
end

function ENT:CanUse(pl)
	return pl:IsSuperAdmin() or (pl == self:CPPIGetOwner())
end

if (CLIENT) then
	local vec = Vector(0,0,1.8)
	local ang = Angle(0,90,0)
	function ENT:Draw()
		self:DrawModel()
		cam.Start3D2D(self:LocalToWorld(vec), self:LocalToWorldAngles(ang), 0.074)
			self:DrawScreen(-960, -540, 1920, 1080)
		cam.End3D2D()
	end
end