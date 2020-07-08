function PLAYER:IsMayor()
	return rp.teams[self:Team()].mayor or false
end

function PLAYER:IsChief()
	return rp.teams[self:Team()].PoliceChief or false
end

function PLAYER:IsCP()
	return rp.teams[self:Team()].police or false
end

function PLAYER:IsGov()
	return self:IsCP() or self:IsMayor()
end

function PLAYER:IsArrested()
	return (self:GetNetVar('IsArrested') ~= nil)
end

function PLAYER:IsWanted()
	return (self:GetNetVar('IsWanted') == true)
end

function PLAYER:GetWantedInfo()
	return self:GetNetVar('WantedInfo')
end

function PLAYER:GetArrestInfo()
	return self:GetNetVar('ArrestedInfo')
end

function PLAYER:CloseToCPs()
	for k, v in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
		if v:IsPlayer() and v:IsCP() and v:Alive() and (not v:IsZiptied()) then
			return true
		end
	end

	return false
end
