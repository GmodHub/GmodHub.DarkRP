function ba.IsSteamID(info)
	return (isstring(info) and info:match('^STEAM_%d:%d:%d+$'))
end

function ba.InfoTo64(info)
	return (isplayer(info) and info:SteamID64() or util.SteamIDTo64(info))
end

function ba.InfoTo32(info)
	return (isplayer(info) and info:SteamID() or (ba.IsSteamID(info) and info or util.SteamIDFrom64(info)))
end

function PLAYER:NameID()
	return (self:Name() .. '(' .. self:SteamID() .. ')')
end

function PLAYER:SetBVar(var, val)
	if (self._ba == nil) then
		self._ba = {}
	end
	self._ba[var] = val
end

function PLAYER:GetBVar(var)
	if (self._ba == nil) then
		self._ba = {}
	end
	return self._ba[var]
end
