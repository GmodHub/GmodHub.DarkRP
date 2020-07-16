ba.jailedPlayers = ba.jailedPlayers or {}

ba.jailRoom = ba.svar.Get('jailroom') and pon.decode(ba.svar.Get('jailroom'))[1] or nil
ba.svar.Create('jailroom', nil, false, function(svar, old_value, new_value)
	ba.jailRoom = pon.decode(new_value)[1]
end)

function ba.jailPlayer(pl, time, reason)
	ba.jailedPlayers[pl:SteamID()] = ba.jailedPlayers[pl:SteamID()] or {
		time 	= time,
		reason 	= reason
	}

	if not timer.Exists('Jail' .. pl:SteamID()) then
		timer.Create('Jail' .. pl:SteamID(), time, 1, function()
			if IsValid(pl) then
				ba.unJailPlayer(pl)
				ba.notify_staff(term.Get('PlayerJailReleased'), pl)
				ba.notify(pl, term.Get('YouJailReleased'))
			end
		end)
	end

	if (reason ~= nil) then
		pl:SetNetVar('JailedInfo', {Time = time + CurTime(), Reason = reason})
	end

	if not pl:Alive() then
		pl:Spawn()
	end

	pl:SetBVar('CanNoclip', false)
	pl:SetBVar('VoiceMuted', true)
	pl:SetBVar('ChatMuted', true)

	pl:SetMoveType(MOVETYPE_WALK)
	pl:GodEnable()

	local pos = util.FindEmptyPos(ba.jailRoom)
	pl:SetPos(pos)
end

function ba.unJailPlayer(pl)
	ba.jailedPlayers[pl:SteamID()] = nil
	timer.Destroy('Jail' .. pl:SteamID())

	pl:GodDisable()
	pl:Spawn()

	pl:SetNetVar('JailedInfo', nil)
	pl:SetBVar('CanNoclip', nil)
	pl:SetBVar('VoiceMuted', nil)
	pl:SetBVar('ChatMuted', nil)
end

hook.Add('PlayerEntityCreated', 'jails.PlayerEntityCreated', function(pl)
	if pl:IsJailed() then
		timer.Simple(0, function()
			local dat = ba.jailedPlayers[pl:SteamID()]
			ba.jailPlayer(pl, dat.time, dat.reason)
		end)
	end
end)

hook.Add('PlayerDeath', 'jails.PlayerDeath', function(pl)
	if pl:IsJailed() then
		pl:Spawn()
		timer.Simple(0, function()
			ba.jailPlayer(pl)
		end)
	end
end)

hook.Add('CanTool', 'jails.CanTool', function(pl)
	if pl:IsJailed() then
		return false
	end
end)

hook.Add('playerCanChangeTeam', 'jails.playerCanChangeTeam', function(pl)
	if pl:IsJailed() then
		return false
	end
end)
