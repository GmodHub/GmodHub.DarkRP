term.Add('AdminKickedPlayer', '# кикнул #. Причина: #.')
term.Add('AdminBannedPlayer', '# забанил # на #. Причина: #.')
term.Add('AdminBannedExternalPlayer', '# (#) banned # (#) for # via #. Reason: #.')
term.Add('AdminPermaExternalPlayer', '# (#) banned # (#) via # permanently. Reason: #.')
term.Add('AdminUpdatedBan', '# обновил бан # до #. Reason: #.')
term.Add('BanReasonReserved', '"malicious activity" is a reserved ban reason.')
term.Add('PlayerAlreadyBanned', 'This player is already banned. You need flag "D" in order to update bans.')
term.Add('BanNeedsPermission', 'You need to specify the staff member who gave you permission to make this permaban. Add perm:(their name) to your reason.')
term.Add('AdminPermadPlayer', '# забанил # навсегда. Причина: #.')
term.Add('AdminUpdatedBanPerma', '# обновил бан игрока # до перманентного. Причина: #.')
term.Add('PlayerAlreadyPermad', 'This player is already banned! You need flag "D" in order to edit bans to permanent.')
term.Add('AdminUnbannedPlayer', '# разбанил #. Причина: #.')

-------------------------------------------------
-- Kick
-------------------------------------------------
ba.AddCommand('Kick', function(pl, target, reason)
	ba.notify_all(term.Get('AdminKickedPlayer'), pl, target, reason)
	target:Kick(reason)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetFlag 'A'
:SetHelp 'Kicks your target from the server'

-------------------------------------------------
-- Ban
-------------------------------------------------
local function checkReason(pl, reason)
	return (not IsValid(pl)) or pl:IsRoot() or (reason:lower():find('malicious activity') == nil)
end

ba.AddCommand('Ban', function(pl, target, time, reason)
	if (not checkReason(pl, reason)) then
		return ba.NOTIFY_ERROR, term.Get('BanReasonReserved')
	end

	ba.bans.IsBanned(ba.InfoTo64(target), function(banned, data)
		if (not banned) then
			ba.bans.Add(target, reason, time, pl, function()
				ba.notify_all(term.Get('AdminBannedPlayer'), pl, target, string.FormatTime(time), reason)
			end)
		elseif banned and (not isplayer(pl) or pl:HasAccess('D')) then
			ba.bans.Update(ba.InfoTo64(target), reason, time, pl, function()
				ba.notify_all(term.Get('AdminUpdatedBan'), pl, target, string.FormatTime(time), reason)
			end)
		else
			return ba.NOTIFY_ERROR, term.Get('PlayerAlreadyBanned')
		end
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:AddParam(cmd.TIME)
:AddParam(cmd.STRING)
:SetFlag 'M'
:SetHelp 'Bans your target from the server'

-------------------------------------------------
-- Perma
-------------------------------------------------
ba.AddCommand('Perma', function(pl, target, reason)
	if (not checkReason(pl, reason)) then
		 ba.NOTIFY_ERROR(term.Get('BanReasonReserved'))
	end

	ba.bans.IsBanned(ba.InfoTo64(target), function(banned, data)
		if (not banned) then
			if isplayer(pl) and (not pl:HasAccess("D")) then
				if (not string.find(reason:lower(), 'perm:')) then
					return ba.NOTIFY_ERROR, term.Get('BanNeedsPermission')
				end
			end

			ba.bans.Add(target, reason, 0, pl, function()
				ba.notify_all(term.Get('AdminPermadPlayer'), pl, target, reason)
			end)
		elseif banned and (not isplayer(pl) or pl:HasAccess('D')) then
			ba.bans.Update(ba.InfoTo64(target), reason, 0, pl, function()
				ba.notify_all(term.Get('AdminUpdatedBanPerma'), pl, target, reason)
			end)
		else
			return ba.NOTIFY_ERROR, term.Get('PlayerAlreadyPermad')
		end
	end)

end)
:AddParam(cmd.PLAYER_STEAMID32)
:AddParam(cmd.STRING)
:SetFlag 'D'
:SetHelp 'Bans your target from the server forever'

-------------------------------------------------
-- Unban
-------------------------------------------------
ba.AddCommand('Unban', function(pl, steamid, reason)
	ba.bans.Remove(ba.InfoTo64(steamid), reason, function()
		ba.notify_all(term.Get('AdminUnbannedPlayer'), pl, steamid, reason)
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:AddParam(cmd.STRING)
:SetFlag 'D'
:SetHelp 'Unbans your target from the server forever'


ba.AddCommand('UnbanId', function(pl, banId, reason)
	ba.bans.RemoveById(banId, reason, function()
		ba.notify_all(term.Get('AdminUnbannedPlayer'), pl, banId, reason)
	end)
end)
:AddParam(cmd.NUMBER)
:AddParam(cmd.STRING)
:SetFlag 'D'
:SetHelp 'Unbans a ban regardless of if it\'s active or not'
