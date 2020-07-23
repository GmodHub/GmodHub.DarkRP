function PLAYER:AddOwnedApparel(uid)
    local OwnedApparel = self:GetNetVar('OwnedApparel') or {}
    OwnedApparel[uid] = true
	self:SetNetVar('OwnedApparel', OwnedApparel)
end

function PLAYER:AddApparel(uid)
    local hat = rp.hats.List[uid]
    local activeApparel = self:GetApparel()

    for k,v in pairs(hat.slots) do
        activeApparel[k] = uid
    end

    self:SetNetVar('ActiveApparel', activeApparel)
    rp.data.SaveActiveApparel(self)
end

function PLAYER:RemoveApparel(slot)
    local activeApparel = self:GetNetVar('ActiveApparel') or {}
    activeApparel[slot] = nil

    self:SetNetVar('ActiveApparel', activeApparel)
end

rp.AddCommand('buyapparel', function(pl, hat)
    if not rp.hats.List[hat] or not pl:GetNetVar('OwnedApparel') or pl:HasApparel(hat) then return end

	local hat = rp.hats.List[hat]

	if not pl:CanAfford(hat.price) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end
    pl:TakeMoney(hat.price)

	rp.data.AddApparel(pl, hat.UID, function()
        pl:AddOwnedApparel(hat.UID)
        pl:AddApparel(hat.UID)
		rp.Notify(pl, NOTIFY_GREEN, term.Get('ApparelPurchased'), hat.name, rp.FormatMoney(hat.price))
	end)
end)
:AddParam(cmd.STRING)

rp.AddCommand('setapparel', function(pl, hat)
	if not rp.hats.List[hat] or not pl:GetNetVar('OwnedApparel') or not pl:HasApparel(hat) then return end

	rp.Notify(pl, NOTIFY_GREEN, term.Get('ApparelEquiped'), rp.hats.List[hat].name)
    pl:AddApparel(hat)
end)
:AddParam(cmd.STRING)

rp.AddCommand('removeapparel', function(pl, slot)
    if not pl:GetApparel()[slot] or not rp.hats.List[pl:GetApparel()[slot]] then return end

	rp.Notify(pl, NOTIFY_GREEN, term.Get('ApparelRemoved'), rp.hats.List[pl:GetApparel()[slot]].name)
    pl:RemoveApparel(slot)
end)
:AddParam(cmd.NUMBER)
