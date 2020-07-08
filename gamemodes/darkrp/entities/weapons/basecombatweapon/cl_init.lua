include("shared.lua")

function SWEP:SetDormant(bDormant)
	// If I'm going from active to dormant and I'm carried by another player, holster me.
	if (not self:IsDormant() and bDormant and not self:IsCarriedByLocalPlayer()) then
		self:Holster(NULL)
	end

	_R.Entity.SetDormant(self, bDormant)
end

function SWEP:ShouldDrawCrosshair()
	return self.DrawCrosshair
end

function SWEP:FireAnimationEvent(origin, angles, event, options)
	return false
end

-- Fix; crosshair

