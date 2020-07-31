util.AddNetworkString 'rp.ScoreboardStats'

net('rp.ScoreboardStats', function(len, pl)
	if (not pl:GetNetVar('OS')) and (not pl:GetNetVar('Country')) then
		local cc = net.ReadString()
		local o = net.ReadUInt(2)
		if (o ~= 1) then
			pl:SetNetVar('OS', o)
		end
		if (cc ~= 'US') then
			pl:SetNetVar('Country', string.lower(cc))
		end
	end
end)

hook('PlayerEntityCreated', 'rp.ScoreBoardCountry', function(pl)
	net.Start('rp.ScoreboardStats')
		net.WriteString(pl:NiceIP())
	net.Send(pl)
end)
