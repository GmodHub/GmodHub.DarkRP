hook("cmd.OnCommandError", function(caller, cmdobj, reason, used)
	if caller and isplayer(caller) then
		if (reason == cmd.ERROR_INVALID_COMMAND) then
			ba.notify_err(caller, term.Get('InvalidCommand'), used[1])
		elseif (reason == cmd.ERROR_MISSING_PARAM) then
			rp.Notify(caller, NOTIFY_ERROR, term.Get('MissingArg'), used[2])
		elseif (reason == cmd.ERROR_INVALID_TIME) then
			ba.notify_err(caller, term.Get('InvalidTimeUnit'))
		elseif (reason == cmd.ERROR_COMMAND_COOLDOWN) then
			rp.Notify(caller, NOTIFY_ERROR, term.Get('WaitBeforCommand'), used[1], used[2])
		end
	else
		if (reason == cmd.ERROR_INVALID_COMMAND) then
			MsgC("[bAdmin] Команда ", used[1], " не существует! \n")
		elseif (reason == cmd.ERROR_MISSING_PARAM) then
			MsgC("[bAdmin] Пропущен аргумент: ", used[2], " \n")
		elseif (reason == cmd.ERROR_INVALID_TIME) then
			MsgC("[bAdmin] Указан неправильный формат времени! \n")
		elseif (reason == cmd.ERROR_COMMAND_COOLDOWN) then
			MsgC("[bAdmin] Пожалуйста подождите перед следующим использованием! \n")
		end
	end
end)

hook("cmd.CanParamParse", function(pl, cmdobj, enum, value)
	if !IsValid(pl) or not isplayer(pl) then return true end

	if (not cmdobj:GetIgnoreImmunity() and cmdobj.ConCommand == "ba" and isplayer(value) and value != pl and not pl:GetRankTable():CanTarget(value:GetRankTable())) then
		ba.notify_err(pl, term.Get('SameWeight'))
		ba.notify_err(value, term.Get('TriedToRunCommand'), pl, cmdobj:GetName())
		return false
	end
end)

hook("cmd.CanRunCommand", function(pl, cmdobj, args)
	if !IsValid(pl) or not isplayer(pl) then return true end

	if pl:IsBanned() then return false end
	if pl:IsJailed() and (cmdobj ~= 'motd') and not pl:HasAccess('*') then return false end

	if (cmdobj:GetAuthRequired() and not ba.IsAuthed(pl)) then
		return false
	elseif (cmdobj:GetFlag() and not pl:HasFlag(cmdobj:GetFlag())) then
		ba.notify_err(pl, term.Get('NeedFlagToUseCommand'), cmdobj:GetFlag(), cmdobj:GetName())
		return false
	end
end)
