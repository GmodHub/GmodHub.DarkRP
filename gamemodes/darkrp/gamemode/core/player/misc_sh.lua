function PLAYER:CanAfford(amount)
	if SERVER and (not rp.data.IsLoaded(self)) then return false end

	if amount then
		amount = math.floor(amount)
		return (amount >= 0) and ((self:GetMoney() - amount) >= 0)
	end
	return false
end
