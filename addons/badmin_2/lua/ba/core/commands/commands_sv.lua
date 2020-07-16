hook("cmd.OnCommandError", function(pl, cmdobj, reason, used)
	if not pl then return end

	if (reason == cmd.ERROR_INVALID_COMMAND) then
		ba.notify_err(pl, term.Get('InvalidCommand'), used[1])
	elseif (reason == cmd.ERROR_MISSING_PARAM) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MissingArg'), used[2])
	elseif (reason == cmd.ERROR_INVALID_TIME) then
		ba.notify_err(pl, term.Get('InvalidTimeUnit'))
	elseif (reason == cmd.ERROR_COMMAND_COOLDOWN) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('WaitBeforCommand'), used[1], used[2])
	end
end)

hook("cmd.CanParamParse", function(pl, cmdobj, enum, value)
	if !IsValid(pl) or not isplayer(pl) then return true end
	if pl:IsBanned() then return false end
	if pl:IsJailed() and (cmd ~= 'motd') and not pl:HasAccess('*') then return false end

	if (cmdobj:GetFlag() and not pl:HasFlag(cmdobj:GetFlag())) then
	//	rp.Notify(pl, NOTIFY_ERROR, term.Get('NeedFlagToUseCommand'), cmdobj:GetFlag(), cmdobj:GetName())
		ba.notify_err(pl, term.Get('NeedFlagToUseCommand'), cmdobj:GetFlag(), cmdobj:GetName())
		return false
	elseif (cmdobj:GetAuthRequired() and not ba.IsAuthed(pl)) then
		return false
	elseif (not cmdobj:GetIgnoreImmunity() and cmdobj.ConCommand == "ba" and isplayer(value) and value != pl and not pl:GetRankTable():CanTarget(value:GetRankTable())) then
		ba.notify_err(pl, term.Get('SameWeight'))
		ba.notify_err(value, term.Get('TriedToRunCommand'), pl, cmdobj:GetName())
		return false
	end
end)
