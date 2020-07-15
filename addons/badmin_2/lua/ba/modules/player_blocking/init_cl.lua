local blockedPlayers
if (file.Exists('gmh/blockedplayers.dat', 'DATA')) then
	blockedPlayers = pon.decode(file.Read('gmh/blockedplayers.dat', 'DATA'))
else
	blockedPlayers = {}
end

function PLAYER:IsBlocked()
	return blockedPlayers[self:SteamID()] == true
end

function PLAYER:Block(block, dontRewrite)
	if (self == LocalPlayer()) then return end
	
	self:SetMuted(block)

	if (!dontRewrite) then
		blockedPlayers[self:SteamID()] = block or nil
		file.Write('gmh/blockedplayers.dat', pon.encode(blockedPlayers))
	end
end

hook('OnEntityCreated', function(ent)
	if (ent:IsPlayer()) then
		if (ent:IsBlocked()) then
			ent:Block(true, true)
		end
	end
end)