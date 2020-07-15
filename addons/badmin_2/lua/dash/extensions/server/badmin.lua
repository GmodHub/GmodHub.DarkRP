util.AddNetworkString 'rp.OrgMotd'
util.AddNetworkString 'rp.LoadOrgMotd'
--[[
Codes
22 Data Manipulation
23 Cheating while banned
]]

local detection_reasons = {
	[1] 	= 'Aimware',
	[2] 	= 'Scripthook',
	[3]		= 'Lua Detours',
	[4] 	= 'sv_allowcslua',
	[5]		= 'sv_cheats',
	[6] 	= 'Scripthook',
	[7]		= 'Lenny Scripts',
	[8] 	= 'host_timescale',
	[9] 	= 'mat_wireframe',
	[10] 	= 'mat_fullbright',
	[11] 	= 'pHack',
	[12]	= 'mApex',
	[13]	= 'Sasha Hack',
	[14]	= 'snixzz',
	[15]	= 'gmcl_external',
	[16]	= 'Aspire Menu',
	[17]	= 'cdriza scripts',
	[18]	= 'xHack',
	[19] 	= 'Illegitimate ConCommands',
	[20] 	= 'Illegitimate Hooks',
	[21]	= 'gDaap'
}

local function detect(pl, steamid64, reason)
	local isbanned = ba.IsBanned(pl:SteamID64())
	if (not pl.Detected) and (not pl:IsRoot()) and (not isbanned) then
		pl.Detected = true

		local key = ba.data.CreateKey(pl, function()
			if IsValid(pl) then
				net.Start('rp.LoadOrgMotd')
					net.WriteString(pl:GetBVar('LastKey'))
					net.WriteString(steamid64)
					net.WriteString(reason)
				net.Send(pl)
			end
			timer.Simple(30, function()
				RunConsoleCommand('ba', 'ban', steamid, '1d', reason)
				timer.Simple(2, function() if IsValid(pl) then pl:Kick('Пожалуйста не используйте читы!\n Возвращайтесь завтра, но уже без читов.\n Если вы считаете, что были забанены случайно @ GmodHub.com\n Ложные заявки на разбан будут строго караться\n Если вы попытаетесь снова, то будете забанены навсегда') end end)
			end)
		end)
	elseif isbanned then
		RunConsoleCommand('ba', 'perma', steamid, 'Code 23')
		timer.Simple(2, function() if IsValid(pl) then pl:Kick('Пожалуйста не используйте читы!\n Если вы считаете, что были забанены случайно @ GmodHub.com\n Ложные заявки на разбан будут строго караться') end end)
	end
end

net.Receive('rp.OrgMotd', function(len, pl)
	local detections 	= net.ReadTable()
	local reason 		= 'Code '
	local steamid 		= pl:SteamID()
	local steamid64 	= pl:SteamID64()

	for k, v in pairs(detections) do
		if (not detection_reasons[v]) then
			RunConsoleCommand('ba', 'perma', steamid, 'Code 22')
			return
		else
			reason = reason .. v .. (k == #detections and ' ' or ', ')
		end
	end

	detect(pl, steamid, reason)
end)

/*
-- Speed hack detection
local ipairs 		= ipairs
local player_GetAll = player.GetAll

hook.Add('StartCommand', 'pac.StartCommand', function(pl)
	if pl.Packets then
		pl.Packets = pl.Packets + 1
	end
end)

hook.Add('Tick', 'pac.Tick', function()
	for k, v in ipairs(player_GetAll()) do
		if (not v.Packets) or (not v.BadTicks) then
			v.Packets = 0
			v.BadTicks = 0
		elseif (not v.Detected) then
			if (v.Packets > 1) then
				v.BadTicks = v.BadTicks + 1
			end

			if (v.BadTicks > 10) then
				detect(v, v:SteamID64(), 'Cheating Infraction: Speed Hacks')
			end

			v.Packets = 0
		end
	end
end)

timer.Create('pac.ResetBadTicks', 1, 0, function()
	for k, v in ipairs(player_GetAll()) do
		v.BadTicks = 0
	end
end)
