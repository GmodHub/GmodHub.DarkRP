-------------------------------------------------
-- Mute
-------------------------------------------------
term.Add('AdminMutedPlayer', '# has muted # for #.')
term.Add('AdminMutedYou', '# has muted you for #.')
term.Add('AdminUnmutedYou', '# has unmuted you.')
term.Add('AdminUnmutedPlayer', '# has unmuted #.')
term.Add('YouAreUnmuted', 'You have been unmuted.')
term.Add('PlayerAlreadyMuted', '# is already muted!')
term.Add('PlayerNotMuted', '# is not muted!')

ba.AddCommand('Mute', function(pl, targ, time)
	if (not targ:IsChatMuted()) or (not targ:IsVoiceMuted()) then
		targ:ChatMute(time, function()
			ba.notify(targ, term.Get('YouAreUnmuted'))
		end)
		targ:VoiceMute(time)

		ba.notify(targ, term.Get('AdminMutedYou'), pl, string.FormatTime(time))
		return ba.NOTIFY_STAFF, term.Get('AdminMutedPlayer'), pl, targ, string.FormatTime(time)
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerAlreadyMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.TIME)
:SetFlag 'M'
:SetHelp 'Mutes your targets chat and voice'

ba.AddCommand('UnMute', function(pl, targ)
	if (targ:IsChatMuted() or targ:IsVoiceMuted()) then
		targ:UnChatMute()
		targ:UnVoiceMute()
		ba.notify(targ, term.Get('AdminUnmutedYou'), pl)
		return ba.NOTIFY_STAFF, term.Get('AdminUnmutedPlayer'), pl, targ
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerNotMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Umutes your targets chat and voice'

-------------------------------------------------
-- Mute Chat
-------------------------------------------------
term.Add('AdminUnmutedPlayerChat', '# has unmuted #\'s chat.')
term.Add('AdminUnmutedYouChat', '# has unmuted your chat.')
term.Add('YouAreUnmutedChat', 'Your chat has been unmuted.')
term.Add('AdminMutedPlayerChat', '# has muted #\'s chat for #.')
term.Add('AdminMutedYouChat', '# has muted your chat for #.')

ba.AddCommand('MuteChat', function(pl, targ, time)
	if (not targ:IsChatMuted()) then
		targ:ChatMute(time, function()
			ba.notify(targ, term.Get('YouAreUnmutedChat'))
		end)
		ba.notify(targ, term.Get('AdminMutedYouChat'), pl, string.FormatTime(time))
		return ba.NOTIFY_ERROR, term.Get('AdminMutedPlayerChat'), pl, targ, string.FormatTime(time)
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerAlreadyMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.TIME)
:SetFlag 'M'
:SetHelp 'Mutes your targets chat'

ba.AddCommand('UnMuteChat', function(pl, targ, time)
	if targ:IsChatMuted() then
		targ:UnChatMute()
		ba.notify(targ, term.Get('AdminUnmutedYouChat'), pl)
		return ba.NOTIFY_STAFF, term.Get('AdminUnmutedPlayerChat'), pl, targ
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerNotMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Unmutes your targets chat'

-------------------------------------------------
-- Mute Voice
-------------------------------------------------
term.Add('AdminUnmutedPlayerVoice', '# has unmuted #\'s voice.')
term.Add('AdminUnmutedYouVoice', '# has unmuted your voice.')
term.Add('YouAreUnmutedVoice', 'Your voice has been unmuted.')
term.Add('AdminMutedPlayerVoice', '# has muted #\'s voice for #.')
term.Add('AdminMutedYouVoice', '# has muted your voice for #.')

ba.AddCommand('MuteVoice', function(pl, targ, time)
	if (not targ:IsVoiceMuted()) then
		targ:VoiceMute(time, function()
			ba.notify(targ, term.Get('YouAreUnmutedVoice'))
		end)
		ba.notify(targ, term.Get('AdminMutedYouVoice'), pl, string.FormatTime(time))
		return ba.NOTIFY_STAFF, term.Get('AdminMutedPlayerVoice'), pl, targ, string.FormatTime(time)
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerAlreadyMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.TIME)
:SetFlag 'M'
:SetHelp 'Mutes your targets voice'

ba.AddCommand('UnMuteVoice', function(pl, targ, time)
	if targ:IsVoiceMuted() then
		targ:UnVoiceMute()
		ba.notify(targ, term.Get('AdminUnmutedYouVoice'), pl)
		return ba.NOTIFY_STAFF, term.Get('AdminUnmutedPlayerVoice'), pl, targ
	end

	return ba.NOTIFY_ERROR, term.Get('PlayerNotMuted'), pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Unmutes your targets voice'

-------------------------------------------------
-- Spectate
-------------------------------------------------
term.Add('AdminIsSpectating', '# is currently spectating someone!')
term.Add('SpectateTargInvalid', 'You must choose a valid target!')

local specPlayers = {}
local handleSpectate

ba.AddCommand('Spectate', function(pl, targ)
	if (not pl:Alive()) then
		pl:Spawn()
	end

	if pl:InVehicle() then
		pl:ExitVehicle()
	end

	if (targ ~= nil) and targ:GetBVar('Spectating') then
		return ba.NOTIFY_ERROR, term.Get('AdminIsSpectating'), targ
	elseif (targ ~= nil) then
		if (!pl:GetBVar('Spectating')) then
			pl:SetBVar('PreSpectatePos', pl:GetPos())
			local preSpecWeapons = {}

			for _, wep in ipairs(pl:GetWeapons()) do
				preSpecWeapons[#preSpecWeapons + 1] = wep:GetClass()
			end
			pl:SetBVar('PreSpectateWeapons', preSpecWeapons)

			pl:StripWeapons()
			pl:Flashlight(false)
			pl:Spectate(OBS_MODE_IN_EYE)

			pl:SetBVar('Spectating', true)
			pl:SetNetVar('Spectating', true)

			specPlayers[#specPlayers + 1] = {pl = pl, targ = targ}
		else
			local patchedtable = false
			for k, v in ipairs(specPlayers) do
				if (v.pl == pl) then
					v.targ = targ
					patchedtable = true
					break
				end
			end

			if (!patchedtable) then
				pl:SetBVar('Spectating', nil)
				return
			end
		end

		pl:SpectateEntity(targ)
	elseif pl:GetBVar('Spectating') then
		pl:SetBVar('Spectating', nil)
	else
		return ba.NOTIFY_ERROR, term.Get('SpectateTargInvalid')
	end
end)
:AddParam(cmd.PLAYER_ENTITY, cmd.OPT_OPTIONAL)
:SetFlag 'A'
:SetHelp 'Spectates your target/untoggles spectate'
:AddAlias 'spec'


hook.Add('PlayerDeath', 'UnSpectateAdmin', function(pl)
	if pl:GetBVar('Spectating') then
		pl:SetBVar('Spectating', nil)
	end
end)

if (CLIENT) then
	hook.Add('HUDShouldDraw', 'ba.HUDShouldDraw', function(name, pl)
		if (name == 'PlayerDisplay') and IsValid(pl) and pl:GetNetVar('Spectating') then return false end -- Use this for your gamemode or whatever.
	end)
else
	handleSpectate = function()
		for i=#specPlayers, 1, -1 do
			local v = specPlayers[i]
			if not v.pl:IsValid() or not v.targ:IsValid() or not v.pl:GetBVar('Spectating') then
				table.remove(specPlayers, i)
				if not v.pl:IsValid() then return end

				local pos = util.FindEmptyPos(v.pl:GetBVar('PreSpectatePos'))

				v.pl:SetNetVar('Spectating', nil)
				v.pl:SetBVar('Spectating', nil)
				v.pl:UnSpectate()
				v.pl:Spawn()
				v.pl:SetPos(pos)

				for _, wep in ipairs(v.pl:GetBVar('PreSpectateWeps') or {}) do
					v.pl:Give(wep)
				end
				continue
			end
			v.pl:SetPos(v.targ:EyePos())
		end
	end
	hook.Add('Think', 'ba.HandleSpectate', handleSpectate)
end

nw.Register 'Spectating'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()
