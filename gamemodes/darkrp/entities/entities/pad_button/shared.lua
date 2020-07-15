AddCSLuaFile()

ENT.Type			= 'anim'
ENT.Base			= 'pad_base'
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.NetworkUse 		= true

if SERVER then
	function ENT:Initialize()
		self:SetModel('models/maxofs2d/button_05.mdl')

		self.BaseClass.Initialize(self)
	end
	
	function ENT:Use(activator, caller, type, value)
		if (not self.ToggleMode) and IsValid(activator) and activator:IsPlayer() then
			self.User = activator
		end

		self.BaseClass.Use(self, activator, caller, type, value)
	end

	function ENT:Think()
		if (not self.ToggleMode) and self:IsPropsFaded() and ((not IsValid(self.User)) or (not self.User:KeyDown(IN_USE)) or (self.User:GetPos():DistToSqr(self:GetPos()) > 7500)) then
			self.User = nil
			self:UnFadeProps()
		end

		self.BaseClass.Think(self)
	end

	function ENT:PlayerUse(pl)
		print("Based")
		if self:IsPropsFaded() then
			self:UnFadeProps()
		else
			self:FadeProps()
		end
	end
else
	function ENT:Think()
		self:UpdateLever()
	end

	function ENT:UpdateLever()
		self.PosePosition = self.PosePosition or 0

		self.PosePosition = math.Approach(self.PosePosition, self:IsPropsFaded() and 1 or 0, 0.1)

		self:SetPoseParameter("switch", self.PosePosition)
		self:InvalidateBoneCache()
	end
end

function ENT:CanHack()
	return false
end