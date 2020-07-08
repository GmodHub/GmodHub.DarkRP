ba.bans = ba.bans or {
	Cache = {},
}

local db = ba.data.GetDB()

function ba.bans.SyncAll(cback)
	db:Query('SELECT * FROM `ba_bans` WHERE unban_time > ' .. os.time() .. ' OR unban_time = 0', function(data)
		ba.bans.Cache = {}
		for k, v in ipairs(data) do
			ba.bans.Cache[v.steamid] = v
		end
		if cback then cback(data) end
	end)
end
timer.Create('ba.SyncBans', 60, 0, ba.bans.SyncAll)
ba.bans.SyncAll()

function ba.bans.Sync(steamid64, cback)
	db:Query('SELECT * FROM `ba_bans` WHERE steamid=? AND (unban_time>' .. os.time() .. ' OR unban_time=0)', steamid64, function(data)
		if data[1] then
			ba.bans.Cache[steamid64] = {
				['a_steamid'] 	= data[1]['a_steamid'],
				['a_name'] 		= data[1]['a_name'],
				['unban_time'] 	= data[1]['unban_time'],
				['reason'] 		= data[1]['reason'],
				['ip'] 			= data[1]['p_ip'],
				['name'] 		= data[1]['p_name'],
				['ban_time'] 	= data[1]['ban_time'],
				['steamid'] 	= data[1]['p_steamid'],
			}
			if cback then cback(data[1]) end
		end
	end)
end

function ba.bans.IsBanned(steamid64)
	if (ba.bans.Cache[steamid64] ~= nil) and ((ba.bans.Cache[steamid64].unban_time > os.time()) or (ba.bans.Cache[steamid64].unban_time == 0)) then
		return true, ba.bans.Cache[steamid64]
	end
	return false
end
ba.IsBanned = ba.bans.IsBanned

function ba.bans.Ban(pl, reason, ban_len, admin, cback)
	local p_steamid 	= ba.InfoTo64(pl)
	local p_ip 			= (ba.IsPlayer(pl) and pl:IPAddress() or '0')
	local p_name 		= (ba.IsPlayer(pl) 	and pl:Name() or (ba.data.GetName(p_steamid) or 'Unknown'))
	local a_steamid 	= (ba.IsPlayer(admin) and admin:SteamID64() or 0)
	local a_name 		= (ba.IsPlayer(admin) and admin:Name() or 'Console')
	local ban_time 		= os.time()
	local unban_time 	= ((ban_len == 0) and 0 or (ban_time + ban_len))

	db:query_ex('INSERT INTO ba_bans(steamid, ip, name, reason, a_steamid, a_name, ban_time, ban_len, unban_time)VALUES("?","?","?","?","?","?","?","?","?");', {p_steamid, p_ip, p_name, reason, a_steamid, a_name, ban_time, ban_len, unban_time}, function(data)
		ba.bans.Cache[p_steamid] = {
			['a_steamid'] 	= a_steamid,
			['a_name'] 		= a_name,
			['unban_time'] 	= unban_time,
			['reason'] 		= reason,
			['ip'] 			= p_ip,
			['name'] 		= p_name,
			['ban_time'] 	= ban_time,
			['steamid'] 	= p_steamid,
		}
		hook.Call('OnPlayerBan', ba, pl)

		if (hook.Call('KickOnPlayerBan', ba, pl, reason, ban_len, admin) ~= false) and ba.IsPlayer(pl) then pl:Kick(reason) end

		if cback then cback(data) end
	end)
end
ba.Ban = ba.bans.Ban

function ba.bans.Unban(steamid, reason, cback)
	db:query_ex('UPDATE ba_bans SET unban_time="?", unban_reason="?" WHERE steamid="?" AND unban_time>? OR steamid="?" AND unban_time=0;', {os.time(), reason, steamid, os.time(), steamid}, function(data)
		ba.bans.Cache[steamid] = nil
		hook.Call('OnPlayerUnban', ba, steamid)
		if cback then cback(data) end
	end)
end
ba.Unban = ba.bans.Unban

function ba.bans.UpdateBan(steamid, reason, time, admin, cback)
	local a_steamid = (ba.IsPlayer(admin) and admin:SteamID64() or 0)
	local a_name = (ba.IsPlayer(admin) and admin:Name() or 'Console')
	local ban_time = os.time()
	local ban_len = time
	local unban_time = ((ban_len == 0) and 0 or (ban_time + ban_len))

	db:query_ex('UPDATE ba_bans SET reason="?", a_steamid="?", a_name="?", ban_time="?", ban_len="?", unban_time="?" WHERE steamid="?" AND unban_time>? OR steamid="?" AND unban_time=0;', {reason, a_steamid, a_name, ban_time, ban_len, unban_time, steamid, os.time(), steamid}, function(data)
		ba.bans.Sync(steamid, function()
			ba.bans.Cache[steamid]['a_steamid'] 	= a_steamid
			ba.bans.Cache[steamid]['a_name'] 		= a_name
			ba.bans.Cache[steamid]['unban_time'] 	= unban_time
			ba.bans.Cache[steamid]['reason'] 		= reason
			ba.bans.Cache[steamid]['ban_time'] 		= ban_time

			if cback then cback(data) end
		end)
	end)
end
ba.UpdateBan = ba.bans.UpdateBan


local msg = [[
Ты забанен!
-------------------------------------
Дата бана: %s
Дата разбана: %s
Админ: %s
Причина: %s
-------------------------------------
Аппеляция vk.com/mrkubu
]]

function ba.bans.CheckPassword(steamid, ip, pass, cl_pass, name)
	local banned, data = ba.bans.IsBanned(steamid)
	if banned then
		local banDate = os.date('%m/%d/%y - %H:%M', data.ban_time)
		local unbanDate = ((data.unban_time == 0) and 'Never' or os.date('%m/%d/%y - %H:%M', data.unban_time))
		local admin = data.a_name .. '(' .. util.SteamIDFrom64(data.a_steamid) .. ')'

		return false, string.format(msg, banDate, unbanDate, admin, data.reason)
	end
end
hook.Add('CheckPassword', 'ba.Bans.CheckPassword', ba.bans.CheckPassword)
