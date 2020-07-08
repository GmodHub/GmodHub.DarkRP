function PLAYER:IsZiptied()
	return self:GetNetVar('Ziptied') == true
end

function PLAYER:IsCarrying()
	return self:GetNetVar('ZiptieCarrying') != nil
end

function PLAYER:IsBeingCarried()
	return self:GetNetVar('ZiptieCarrier') != nil
end

function PLAYER:GetCarried()
	return SERVER and self:GetNetVar('ZiptieCarrying') or Entity(self:GetNetVar('ZiptieCarrying') or 0)
end

function PLAYER:GetCarrier()
	return SERVER and self:GetNetVar('ZiptieCarrier') or Entity(self:GetNetVar('ZiptieCarrier') or 0)
end

function PLAYER:CanUseZipties()
	return (self:GetTeamTable().CanHostage or self:IsCP())
end

hook('Move', 'rp.Zipties.Move', function(pl, mv)
	if (pl:IsZiptied() or pl:IsCarrying()) then
		if (pl:GetMoveType() != MOVETYPE_LADDER) then
			mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(mv:GetButtons(), IN_JUMP)))
		end

		local mul = 0.25
		if (pl:IsCarrying() and pl:CanUseZipties()) then
			mul = 0.65
		end
		
		mv:SetMaxClientSpeed(rp.cfg.WalkSpeed * mul)
	end
end)