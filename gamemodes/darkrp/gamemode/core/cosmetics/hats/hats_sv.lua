
/*rp.AddCommand('buyapparel', function(pl, args)
	if not args[1] or not rp.hats.list[args[1]] or table.HasValue(pl:GetNetVar('HatData') or {}, args[1]) then return end

	local hat = rp.hats.list[args[1]]

	if not pl:CanAfford(hat.price) then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('CannotAfford'))
		return
	end

	local HatData = pl:GetNetVar('HatData') or {}
	table.insert(HatData, args[1])
	pl:SetNetVar('HatData', HatData)

	ba.data.SetHat(pl, hat.model, function()
		pl:TakeMoney(hat.price)
		rp.Notify(pl, NOTIFY_GREEN, rp.Term('HatPurchased'), hat.name, rp.FormatMoney(hat.price))
	end)
end)

rp.AddCommand('setapparel', function(pl, text, args)
	if not args[1] or not rp.hats.list[args[1]] or not pl:GetNetVar('HatData') or not table.HasValue(pl:GetNetVar('HatData') or {}, args[1]) then return end

	rp.Notify(pl, NOTIFY_GREEN, rp.Term('HatEquipped'))
	ba.data.SetHat(pl, args[1])
end)


rp.AddCommand('removeapparel', function(pl, text, args)
	rp.Notify(pl, NOTIFY_GREEN, rp.Term('HatRemoved'))
	ba.data.SetHat(pl, nil)
end)
