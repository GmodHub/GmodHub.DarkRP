term.Add('SeeConsole', 'See console for output.')

-------------------------------------------------
-- Reload
-------------------------------------------------
ba.AddCommand('Reload', function(pl)
	RunConsoleCommand('changelevel', game.GetMap())
end)
:SetFlag '*'
:SetHelp 'Reloads the map'

-------------------------------------------------
-- Reload
-------------------------------------------------
ba.AddCommand('Restart', function(pl)
	game.GetWorld():Remove() -- do the hack
end)
:SetFlag '*'
:SetHelp 'Restarts the server'

-------------------------------------------------
-- Bots
-------------------------------------------------
ba.AddCommand('Bots', function(pl, number)
	for i = 1, tonumber(number) do
		RunConsoleCommand('bot')
	end
end)
:AddParam(cmd.NUMBER)
:SetFlag '*'
:SetHelp 'Spawns bots'

ba.AddCommand('KickBots', function(pl)
	for k, v in ipairs(player.GetBots()) do
		v:Kick()
	end
end)
:SetFlag '*'
:SetHelp 'Kicks all bots'

-------------------------------------------------
-- Previous offences
-------------------------------------------------
ba.AddCommand 'PO'
:RunOnClient(function(target)
	gui.OpenURL('https://superiorservers.co/bans/' .. ba.InfoTo32(target))
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetHelp 'Show\'s a players previous bans'
:SetIgnoreImmunity(true)

-------------------------------------------------
-- Lookup
-------------------------------------------------
local white = Color(220,220,220)
local ws = '\n           '
ba.AddCommand('Lookup', function(pl, target)
	ba.notify(pl, term.Get('SeeConsole'))
end)
:RunOnClient(function(target)

	MsgC(white, '---------------------------\n')
	MsgC(white, target:Name() ..'\n')
	MsgC(white, '---------------------------\n')

	MsgC(white, 'SteamID:' .. ws .. target:SteamID() ..'\n')

	MsgC(white, 'Rank:' .. ws .. target:GetRank() ..'\n')

	MsgC(white, 'Play Time:' .. ws .. ba.str.FormatTime(target:GetPlayTime()) ..'\n')
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetHelp 'Show\'s a players rank info'
:SetIgnoreImmunity(true)

-------------------------------------------------
-- Who
-------------------------------------------------
local white = Color(200,200,200)
ba.AddCommand('Who', function(pl)
	ba.notify(pl, term.Get('SeeConsole'))
end)
:RunOnClient(function()
	MsgC(white, '--------------------------------------------------------\n')
	MsgC(white, '          SteamID      |      Name      |      Rank\n')
	MsgC(white, '--------------------------------------------------------\n')

	for k, v in ipairs(player.GetAll()) do
		local id 	= v:SteamID()
		local nick 	= v:Name()
		local text 	= string.format("%s%s %s%s ", id, string.rep(" ", 2 - id:len()), nick, string.rep(" ", 20 - nick:len()))
		text 		= text .. v:GetRank()
		MsgC(white, text .. '\n')
	end
end)
:SetHelp 'Show\'s the ranks for all users online'

-------------------------------------------------
-- Profile
-------------------------------------------------
ba.AddCommand 'Profile'
:RunOnClient(function(target)
	ba.ui.OpenAuthLink('/profile/' .. ba.InfoTo64(target))
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetHelp 'Execs lua on your target'
:SetIgnoreImmunity(true)

-------------------------------------------------
-- Exec
-------------------------------------------------
ba.AddCommand('Exec', function(pl, target, lua)
	target:SendLua([[RunString(]] .. lua .. [[)]])
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetFlag '*'
:SetHelp 'Execs lua on your target'

-------------------------------------------------
-- Exec
-------------------------------------------------
local moveCmdCategories = {
	['afk'] = function(players) return table.Filter(players, function(v) return v:IsAFK() end) end,
	['dead'] = function(players) return table.Filter(players, function(v) return (not v:Alive()) end) end,
	['all'] = function(players) return players end
}

local servers = { // make a cfg or something one day
	['rp'] = 'rp.superiorservers.co',
	['rp2'] = '31.130.42.26:27015',
}

ba.AddCommand('Move', function(pl, category, server)
	local str = category
	local cat = str:lower()
	local eval

	local ip = servers[server:lower()]

	if (not ip) then return end

	local eval = moveCmdCategories[cat]
	if eval then
		local players = eval(player.GetAll())
		table.sort(players, function(a, b) return (a.NotAFK or 0) > (b.NotAFK or 0) end)

		local count = 0
		for k, v in ipairs(players) do
			count = count + 1

			if (count > 5) then break end

			v:SendLua([[LocalPlayer():ConCommand('connect ]] .. ip.. [[')]])
		end

		ba.notify(pl, term.Get('AdminMovedPlayers'), tostring(count))
	else
		local targ = player.Find(str)

		if (targ) then
			targ:SendLua([[LocalPlayer():ConCommand('connect ]] .. ip .. [[')]])
			return
		else
			ba.notify(pl, term.Get('PlayerNotFound'), str)
		end
	end
end)
:AddParam(cmd.STRING)
:AddParam(cmd.STRING)
:SetFlag '*'
:SetHelp('Moves the given set of players to the other server. Categories: ' .. table.ConcatKeys(moveCmdCategories, ', ') .. '.')
