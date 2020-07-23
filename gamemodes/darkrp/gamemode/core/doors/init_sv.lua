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
	pl:SetVar('PropertyOwned', self:EntIndex())
end

function ENTITY:UnOwnProperty(pl)
	if pl:GetVar('PropertyOwned') then
		pl:SetVar('PropertyOwned', nil)
	end

	self:DoorLock(false)
	nw.SetGlobal(self:GetPropertyNetworkID(), nil)
end

function ENTITY:CoOwnProperty(pl)
	local data = self:GetPropertyData() or {}
	data.CoOwners =  data.CoOwners or {}
	data.CoOwners[#data.CoOwners + 1] = pl

	nw.SetGlobal(self:GetPropertyNetworkID(), data)
end

function ENTITY:UnCoOwnProperty(pl)
	local data = self:GetPropertyData() or {}
	table.RemoveByValue(data.CoOwners or {}, pl)

	nw.SetGlobal(self:GetPropertyNetworkID(), data)
end

function ENTITY:SetPropertyOrgOwn(bool)
	local data = self:GetPropertyData() or {}
	data.OrgOwn = bool
	nw.SetGlobal(self:GetPropertyNetworkID(), data)
end

function ENTITY:SetPropertyTitle(title)
	local data = self:GetPropertyData() or {}
	data.Title = title
	nw.SetGlobal(self:GetPropertyNetworkID(), data)
end

function PLAYER:SellProperty(all, sell)
	for k, v in ipairs(ents.GetAll()) do
		if IsValid(v) and v:IsDoor() then
			if v:GetPropertyOwner() == self then
				if sell then
					self:AddMoney(v:GetPropertySellPrice())
					rp.Notify(self, NOTIFY_SUCCESS, term.Get('PropertySold'), v:GetPropertyName(), rp.FormatMoney(v:GetPropertySellPrice()))
				end
				v:UnOwnProperty(self)
			elseif v:IsPropertyCoOwner(self) then
				v:UnCoOwnProperty(self)
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
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyBought'), ent:GetPropertyName(), rp.FormatMoney(cost), 0)
		ent:OwnProperty(pl)
	end

end)

rp.AddCommand('sellproperty', function(pl)
	local ent = pl:GetEyeTrace().Entity
	if not pl:GetVar('PropertyOwned') then
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyNoneLeft'))
		return
	end

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		pl:AddMoney(ent:GetPropertySellPrice())
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertySold'), ent:GetPropertyName(), rp.FormatMoney(ent:GetPropertySellPrice()))
		ent:UnOwnProperty(pl)
	else
		pl:SellProperty(false, true)
	end

end)

rp.AddCommand('addcoowner', function(pl, co)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (co ~= nil) and (co ~= pl) and not ent:IsPropertyCoOwner(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then

		if rp.question.Exists(ent:GetPropertyNetworkID() .. '' .. co:SteamID64()) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('PropertyCoOwnerVotePending'), co, ent:GetPropertyName())
			return
		end

		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerAdded'), co, ent:GetPropertyName())
		rp.Notify(co, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerAddedYou'), pl, ent:GetPropertyName())

		rp.question.Create(pl:Name() .. " пригласил вас стать совладельцом " .. ent:GetPropertyName(), 30, ent:GetPropertyNetworkID() .. '' .. co:SteamID64(), function(co, answer)
			if tobool(answer) then
				ent:CoOwnProperty(co)
			end
		end, false, co)

	end
end)
:AddParam(cmd.PLAYER_ENTITY)

rp.AddCommand('removecoowner', function(pl, co)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (co ~= nil) and ent:IsPropertyCoOwner(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerRemoved'), co, ent:GetPropertyName())
		rp.Notify(co, NOTIFY_SUCCESS, term.Get('PropertyCoOwnerRemovedYou'), pl, ent:GetPropertyName())
		ent:UnCoOwnProperty(co)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)


rp.AddCommand('setpropertytitle', function(pl, text)
	if (text == '') then return end

	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_GENERIC, term.Get('PropertySetTitle'), text)
		ent:SetPropertyTitle(string.sub(text, 1, 22))
	end
end)
:AddParam(cmd.STRING)

rp.AddCommand('setpropertyorgowned', function(pl)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and (ent:GetPropertyOwner() == pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) and pl:GetOrg() then
		rp.Notify(pl, NOTIFY_GENERIC, ent:IsPropertyOrgOwned() and term.Get('PropertOrgDisabled') or term.Get('PropertOrDEnabled'), ent:GetPropertyName() )
		ent:SetPropertyOrgOwn(not ent:IsPropertyOrgOwned())
	end
end)

// Hooks

hook.Add( "PlayerCanAccessProperty", "PropertyCanAccess", function(pl, ent)
	if not IsValid(ent) or not ent:IsDoor() then return false end
	if (ent:GetPos():DistToSqr(pl:GetPos()) > 13225) then return false end
	if (ent:IsPropertyTeamOwned() and table.HasValue(ent:GetPropertyInfo().Teams, pl:Team())) then return true end
	if (ent:GetPropertyOwner() == pl) or ent:IsPropertyCoOwner(pl) then return true end
	if ent:IsPropertyOrgOwned() and (pl:GetOrg() == ent:GetPropertyOwner():GetOrg()) then return true end

	return false
end)
