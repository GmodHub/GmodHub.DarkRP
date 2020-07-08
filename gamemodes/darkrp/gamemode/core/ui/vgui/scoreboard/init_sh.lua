local os_translations = {
	[1] = 'windows',
	[2]	= 'osx',
	[3] = 'linux'
}

function PLAYER:GetOS()
	return os_translations[self:GetNetVar('OS') or 1]
end

function PLAYER:GetCountry()
	return self:GetNetVar('Country') or 'us'
end

function PLAYER:GetPlayTimeRank()
	local lastRank = ''
	for k, v in ipairs(rp.cfg.PlayTimeRanks) do
		if (self:GetPlayTime() > v[2]) then
			lastRank = v[1]
		else
			return lastRank
		end
	end
	return lastRank
end

nw.Register 'OS'
	:Write(net.WriteUInt, 2)
	:Read(net.ReadUInt, 2)
	:SetPlayer()

nw.Register 'Country'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()
