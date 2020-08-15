/*if (SERVER) then
	util.AddNetworkString 'ba.FullServerRedirect'

	hook.Add('playerRankLoaded', 'PerformFullServerRedirect', function(pl)
		if (player.GetCount() >= info.MaxSlots) then
			local afk = table.Filter(player.GetAll(), function(v) return v:IsAFK(1800) end)
			table.sort(afk, function(a, b) return a.NotAFK > b.NotAFK end)

			local target = afk[1]

			if (not IsValid(target)) and (pl:GetRank() ~= 'vip') and (not pl:IsAdmin()) then
				target = pl
			end

			if IsValid(target) then
				net.Start('ba.FullServerRedirect')
					net.WriteBool(target == pl)
				net.Send(target)
			end
		end
	end)

	return
end

cvar.Register 'FullServerRedirect'
cvar.Register 'AFKRedirect'

hook.Add('ba.GetLoadInAlerts', 'ba.reservedslots.GetLoadInAlerts', function()
	--	cvar.SetValue('FullServerRedirect', 'Danktown') -- testing

	local server = cvar.GetValue('FullServerRedirect') or cvar.GetValue('AFKRedirect')

	if isstring(server) then
		local reason = ''
		if cvar.GetValue('AFKRedirect') then
			reason = 'You were redirected to our ' .. info.ChatPrefix .. ' server for being afk because our ' .. server .. ' server was too full.'
		else
			reason = 'You were redirected to our ' .. info.ChatPrefix .. ' server because our ' .. server .. ' server was too full.\nFor access reserved slots you may purchase VIP by clicking the \'Credit Shop\' button below.'
		end

		cvar.SetValue('FullServerRedirect', nil)
		cvar.SetValue('AFKRedirect', nil)

		return reason
	end
end)

net('ba.FullServerRedirect', function()
	hook.Remove('InitPostEntity', 'fullserver.InitPostEntity')
	cvar.SetValue(net.ReadBool() and 'FullServerRedirect' or 'AFKRedirect', info.ChatPrefix)
	hook.Add('Think', function()
		if IsValid(LocalPlayer()) then
			LocalPlayer():ConCommand('connect ' .. info.AltServerIP)
		end
	end)
end)
