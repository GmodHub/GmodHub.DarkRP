ba.data = ba.data or {
	IP 		= 'mazvov7p.beget.tech',
	User 	= 'mazvov7p_sup',
	Pass 	= '%cSuuP38',
	Table = 'mazvov7p_sup',
	Port 	= 3306,
	_uid 	= util.CRC(GetConVarString('ip') .. ':' .. GetConVarString('hostport'))
}


ba.data._db = ba.data._db or mysql.Connect(ba.data.IP, ba.data.User, ba.data.Pass, ba.data.Table, ba.data.Port)


--
-- Misc
--
function ba.data.GetDB()
	return ba.data._db
end

function ba.data.GetID()
	return (ba.svar.Get('sv_id') or 'NOT_SET')
end

function ba.data.GetUID()
	return ba.data._uid
end


--
-- 	Auth keys
--
local db = ba.data.GetDB()

function ba.data.CreateKey(pl, cback)
	local time = os.time()
	local key = pl:HashID()
	pl:SetBVar('LastKey', key)
	db:Query('INSERT INTO ba_keys(`Date`, `Key`) VALUES(' .. time .. ', "' .. key .. '");')
	return key
end

function ba.data.DestroyKey(key, cback)
	db:Query('DELETE * FROM ba_keys WHERE `Key`="' .. key .. '";')
end


--
-- Player data
--
function ba.data.LoadPlayer(pl, cback)
	local steamid 	= (pl:SteamID64() or '0')
	local name 		= pl:Name()

	db:Query('SELECT * FROM ba_users WHERE steamid=?', steamid, function(_data)
		local d 	= (_data[1]		or {})
		d.lastseen 	= (d.lastseen	or os.time()) --wtf
		d.playtime	= (d.playtime	or 0)

		pl:SetNetVar('PlayTime', d.playtime)
		pl:SetNetVar('FirstJoined', CurTime())

		if (#_data < 1) then -- you seem to be a new player let's create some data for you.
			db:Query('INSERT INTO ba_users(steamid, name, firstjoined, lastseen, playtime) VALUES(?, ?, ?, ?, 0)', steamid, name, os.time(), os.time())
			ba.notify_all(term.Get('PlayerFirstConnect'), name)
		else
			db:Query('UPDATE ba_users SET name=?, lastseen=? WHERE steamid=?;', name, os.time(), steamid)
			ba.notify_all(term.Get('PlayerConnect'), name, os.date("%m/%d/%Y" , d.lastseen))
		end

		if not d.firstjoined then -- You joined before we added merged this feature. We'll just pretend that you haven't ever joined!
			db:Query('UPDATE ba_users SET firstjoined=? WHERE steamid=?;', os.time(), steamid)
		end

		db:Query('SELECT * FROM ba_ranks WHERE steamid=? AND (sv_id=? OR sv_id="NO_ID");', steamid, ba.data.GetID(), function(data)
			local _d		= (data[1] or {})

			_d.expire_rank 	= ba.ranks.Get(tonumber(_d.expire_rank or 1)):GetName()
			_d.expire_time 	= (_d.expire_time or 0)
			_d.rank 		= tonumber(_d.rank or 1)

			pl:SetBVar('expire_rank', _d.expire_rank)
			pl:SetBVar('expire_time', _d.expire_time)

			local rank_id = ba.ranks.Get(_d.rank):GetID()
			if (rank_id ~= 1) then
				pl:SetNetVar('UserGroup', ba.ranks.Get(_d.rank):GetID())
			end

			if (#data < 1) then
				db:Query('INSERT INTO ba_ranks(steamid, sv_id, rank, expire_rank, expire_time) VALUES(?,?,?,?,?)', {steamid, ba.data.GetID(), 1, 1, 0})
			end

			if (_d.expire_time ~= 0) and (_d.expire_time < os.time()) then
				ba.data.SetRank(pl, _d.expire_rank, _d.expire_rank, 0, hook.Call('playerRankExpire', ba, pl, _d.expire_rank))
			end

			if cback then cback(data) end

			pl:SetBVar('DataLoaded', true)

			hook.Call('playerRankLoaded', ba, pl, _d)
		end)
	end)
end

function ba.data.SetRank(pl, rank, expire_rank, expire_time, cback)
	local steamid 	= ba.InfoTo64(pl)
	local sv_id 	= ba.data.GetID()
	local r 		= (rank 		or 1)
	local exr 		= (expire_rank 	or 'user')
	local ext 		= (expire_time 	or 0)
	local rank_obj 	= ba.ranks.Get(r)
	local rank_ex_obj = ba.ranks.Get(exr)

	local rank_id = rank_obj:GetID()
	local rank_ex_id = rank_ex_obj:GetID()

	if rank_obj:IsGlobal() then
		sv_id = 'NO_ID'

		db:Query('DELETE FROM ba_ranks WHERE steamid=?', {steamid, sv_id, rank_id, exr, ext}, function(data)
			db:Query('INSERT INTO ba_ranks(steamid, sv_id, rank, expire_rank, expire_time) VALUES(?,?,?,?,?)', steamid, sv_id, rank_id, rank_ex_id, ext, function(data)
				if isplayer(pl) then
					pl:SetBVar('expire_rank', exr)
					pl:SetBVar('expire_time', ext)
					if (rank_id == 1) then
						pl:SetNetVar('UserGroup', nil)
					else
						pl:SetNetVar('UserGroup', rank_id)
					end
				end
				hook.Call('playerSetRank', ba, pl, r, exr, ext)
				if cback then cback(data) end
			end)
		end)
	else
		db:Query('REPLACE INTO ba_ranks(steamid, sv_id, rank, expire_rank, expire_time) VALUES(?,?,?,?,?)', steamid, sv_id, rank_id, rank_ex_id, ext, function(data)
			if isplayer(pl) then
				pl:SetBVar('expire_rank', exr)
				pl:SetBVar('expire_time', ext)
				if (rank_id == 1) then
					pl:SetNetVar('UserGroup', nil)
				else
					pl:SetNetVar('UserGroup', rank_id)
				end
			end
			hook.Call('playerSetRank', ba, pl, r, exr, ext)
			if cback then cback(data) end
		end)
	end
end

function ba.data.UpdatePlayTime(pl)
	if not IsValid(pl) or not pl:GetBVar('DataLoaded') then return end
	db:Query('UPDATE ba_users SET lastseen=' .. os.time() .. ', playtime=' .. pl:GetPlayTime() .. ' WHERE steamid=' .. pl:SteamID64() .. ';')
end

-- Sync queries
function ba.data.GetRank(steamid64)
	local data = db:query_sync('SELECT rank FROM ba_ranks WHERE steamid=? AND (sv_id=? OR sv_id="NO_ID");', {steamid64, ba.data.GetID()})
	return (data[1] and data[1].rank or 'user')
end

function ba.data.GetName(steamid64)
	local data = db:query_sync('SELECT name FROM ba_users WHERE steamid=?;', {steamid64})
	return (data[1] and data[1].name)
end
