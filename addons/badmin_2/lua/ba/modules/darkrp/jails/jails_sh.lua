term.Add('PlayerJailReleased', '# has been released from jail.')
term.Add('YouJailReleased', 'You have been released from jail.')

nw.Register 'JailedInfo'
	:Write(function(v)
		net.WriteUInt(v.Time, 32)
		net.WriteString(v.Reason)
	end)
	:Read(function()
		return {
			Time = net.ReadUInt(32),
			Reason = net.ReadString()
		}
	end)
	:SetLocalPlayer()

function PLAYER:IsJailed()
	return (self:GetNetVar('JailedInfo') ~= nil)
end

-------------------------------------------------
-- Jail
-------------------------------------------------
term.Add('JailNotSet', 'The jailroom is not set!')
term.Add('JailTimeRestriction', 'You cannot jail for longer than 10 minutes!')
term.Add('PlayerAlreadyJailed', '# is already jailed!')
term.Add('AdminJailedPlayer', '# has jailed # for #. Reason: #.')
term.Add('AdminJailedYou', '# has jailed you for #. Reason: #.')

ba.AddCommand('Jail', function(pl, target, time, reason)
	if (not ba.svar.Get('jailroom')) then
		return ba.NOTIFY_ERROR, term.Get('JailNotSet')
	end

	if (time > 600) and (not pl:HasAccess('G')) then
		return ba.NOTIFY_ERROR, term.Get('JailTimeRestriction')
	end

	if target:IsJailed() then
		ba.notify_err(pl, term.Get('PlayerAlreadyJailed'), pl)
	else
		ba.jailPlayer(target, time, reason, pl)

		local niceTime = string.FormatTime(time)
		ba.notify_staff(term.Get('AdminJailedPlayer'), pl, target, niceTime, reason)
		ba.notify(target, term.Get('AdminJailedYou'), pl, niceTime, reason)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.TIME)
:AddParam(cmd.STRING)
:SetFlag 'M'
:SetHelp 'Jails your target'
:SetCooldown(0)

-------------------------------------------------
-- Unjail
-------------------------------------------------
term.Add('AdminUnjailedPlayer', '# has unjailed #.')
term.Add('AdminUnjailedYou', '# has unjailed you.')
term.Add('PlayerNotJailed', '# is not jailed!')

ba.AddCommand('Unjail', function(pl, target, time, reason)
	if (not ba.svar.Get('jailroom')) then
		return ba.NOTIFY_ERROR, term.Get('JailNotSet')
	end

	if (not target:IsJailed()) then
		ba.notify_err(pl, term.Get('PlayerNotJailed'), target)
	else
		ba.unJailPlayer(target, true)
		ba.notify_staff(term.Get('AdminUnjailedPlayer'), pl, target)
		ba.notify(target, term.Get('AdminUnjailedYou'), pl)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Unjails your target'
:SetCooldown(0)

-------------------------------------------------
-- Set Admin Room
-------------------------------------------------
term.Add('JailroomSet', 'The jailroom has been set to your current position.')

ba.AddCommand('SetJailRoom', function(pl)
	ba.svar.Set('jailroom', pon.encode({pl:GetPos()}))
	ba.notify(pl, term.Get('JailroomSet'))
end)
:SetFlag '*'
:SetHelp 'Sets the jailroom to your current position'


if (CLIENT) then
	net('ba.jails.OpenMotd', function()
		ba.OpenMoTD()
	end)

	hook.Add('HUDPaint', 'jail.HUDPaint', function()
		if LocalPlayer():IsJailed() then
			local var = LocalPlayer():GetNetVar('JailedInfo')
			draw.SimpleText('You are in admin jail for (' .. math.Round(var.Time - CurTime(), 0) .. 's): ' .. var.Reason, 'BannedInfo', ScrW() * 0.5, ScrH() * 0.2, ui.col.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end
