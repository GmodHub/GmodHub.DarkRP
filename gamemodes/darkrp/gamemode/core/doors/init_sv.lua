util.AddNetworkString('rp.keysMenu')

function ENTITY:DoorLock(locked)
	self.Locked = locked
	if (locked == true) then
		self:Fire('lock', '', 0)
	elseif (locked == false) then
		self:Fire('unlock', '', 0)
	end
end

function ENTITY:OwnProperty(pl)

	nw.SetGlobal(self:GetPropertyNetworkID(), {Owner = pl, Title = self:GetPropertyName(), OrgOwn = false, CoOwners = {}})
	pl:SetVar('PropertyOwned', true)

end

function ENTITY:UnOwnProperty(pl)
	if pl:GetVar('PropertyOwned') then
		pl:SetVar('PropertyOwned', false)
	end

	self:DoorLock(false)
	nw.SetGlobal(self:GetPropertyNetworkID(), nil)
end

function ENTITY:DoorCoOwn(pl)
	local data = self:GetNetVar('DoorData') or {}
	data.CoOwners =  data.CoOwners or {}
	data.CoOwners[#data.CoOwners + 1] = pl
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorUnCoOwn(pl)
	local data = self:GetNetVar('DoorData') or {}
	table.RemoveByValue(data.CoOwners or {}, pl)
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorSetOrgOwn(bool)
	local data = self:GetPropertyData() or {}
	data.OrgOwn = bool
	self:SetNetVar('DoorData', data)
end

function ENTITY:SetPropertyTitle(title)
	local data = self:GetPropertyData() or {}
	data.Title = title
	nw.SetGlobal(self:GetPropertyNetworkID(), data)
end

function ENTITY:DoorSetTeam(t)
	self:SetNetVar('DoorData', {Team = t})
end

function ENTITY:DoorSetGroup(g)
	self:SetNetVar('DoorData', {Group = g})
end

function ENTITY:DoorSetOwnable(ownable)
	if (ownable == true) then
		self:SetNetVar('DoorData', false)
	elseif (ownable == false) then
		self:SetNetVar('DoorData', nil)
	end
end

function PLAYER:DoorUnOwnAll()
	for k, v in ipairs(ents.GetAll()) do
		if IsValid(v) and v:IsDoor() then
			if v:DoorOwnedBy(self) then
				v:DoorUnOwn()
			elseif v:DoorCoOwnedBy(self) then
				v:DoorUnCoOwn(self)
			end
		end
	end
end


//
// Commands
//
rp.AddCommand('buyproperty', function(pl, text, args)
	if pl:GetVar('PropertyOwned') then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PropertyAlreadyOwned'))
		return
	end

	local ent = pl:GetEyeTrace().Entity
	local cost = ent:GetPropertyPrice(pl)

	if !pl:CanAfford(cost) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	if IsValid(ent) and ent:IsDoor() and ent:IsPropertyOwnable() and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		pl:TakeMoney(cost)
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyBought'), ent:GetPropertyName(), rp.FormatMoney(cost), 30)
		ent:OwnProperty(pl)
	end

end)

rp.AddCommand('sellproperty', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then

		pl:AddMoney(ent:GetPropertySellPrice())
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertySold'), ent:GetPropertyName(), rp.FormatMoney(ent:GetPropertySellPrice()))
		ent:UnOwnProperty(pl)
	end

end)

rp.AddCommand('addcoowner', function(pl, co)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (co ~= nil) and (co ~= pl) and not ent:IsPropertyCoOwner(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerAdded'), co, ent:GetPropertyName())
		rp.Notify(co, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerAddedYou'), pl, ent:GetPropertyName())
		//ent:DoorCoOwn(co)
	end
end)
:AddParam(cmd.PLAYER_STEAMID32)

rp.AddCommand('removecoowner', function(pl, co)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (co ~= nil) and ent:IsPropertyCoOwner(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerRemoved'), co, ent:GetPropertyName())
		rp.Notify(co, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerRemovedYou'), pl, ent:GetPropertyName())
	//	ent:DoorUnCoOwn(co)
	end
end)
:AddParam(cmd.PLAYER_STEAMID32)


rp.AddCommand('setpropertytitle', function(pl, text)
	if (text == '') then return end

	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_GENERIC, term.Get('PropertySetTitle'), text)
		ent:SetPropertyTitle(string.sub(text, 1, 22))
	end
end)
:AddParam(cmd.STRING)

rp.AddCommand('orgown', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) and pl:GetOrg() then
		rp.Notify(pl, NOTIFY_GENERIC, (ent:DoorOrgOwned() and term.Get('OrgDoorDisabled') or term.Get('OrgDoorEnabled')))
		ent:DoorSetOrgOwn(not ent:DoorOrgOwned())
	end
end)

// Hooks

hook.Add( "PlayerCanAccessProperty", "PropertyCanAccess", function(pl, ent)

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then return true end

	return false
end)
