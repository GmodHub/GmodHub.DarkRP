term.Add('NoPMResponder', 'There\'s nobody to respond to!')

nw.Register 'IsTyping'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()
	:SetNoSync()

chat.Register 'PM'
	:Write(function(pl, targ, msg)
		net.WritePlayer(pl)
		net.WritePlayer(targ)
		net.WriteString(msg)
	end)
	:Read(function()
		local pl, targ = net.ReadPlayer(), net.ReadPlayer()
		
		if (pl:IsBlocked()) then return end

		local isTarget = (targ == LocalPlayer())
		local user = (isTarget and pl or targ)

		if cvar.GetValue('PMNotify') and isTarget then
			surface.PlaySound('friends/message.wav')
			system.FlashWindow()
		end

		CHATBOX.DoEmotes = IsValid(pl) and pl:IsVIP()
		CHATBOX.PendingChatTab = IsValid(pl) and ('[PM] ' .. user:Name())
		return ui.col.Yellow, '[PM '.. (isTarget and 'FROM' or 'TO') .. '] ', user:GetChatTag(), user:GetJobColor(), user:Name(), ': ', ui.col.White, net.ReadString()
	end)
	:Filter(function(pl, targ, msg)
		return {targ, pl}
	end)


function PLAYER:IsTyping()
	return (self:GetNetVar('IsTyping') == true)
end

ba.AddCommand('pm', function(pl, targ, message)
	if pl:IsChatMuted() then return end // Should really do this at a higher level some day

	chat.Send('PM', pl, targ, message)

	targ.LastPM = pl
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetChatCommand()
:SetIgnoreImmunity(true)

ba.AddCommand('re', function(pl, message)
	if pl:IsChatMuted() then return end

	local targ = pl.LastPM

	if IsValid(targ) then
		chat.Send('PM', pl, targ, message)
		targ.LastPM = pl
	else
		return NOTIFY_ERROR, term.Get('NoPMResponder')
	end
end)
:AddParam(cmd.STRING)
:SetChatCommand()
:SetIgnoreImmunity(true)