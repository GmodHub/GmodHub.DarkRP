util.AddNetworkString 'ba.logs.RequestPlayerEvents'
util.AddNetworkString 'ba.logs.UpdateSubscription'
util.AddNetworkString 'ba.logs.RequestCategory'
util.AddNetworkString 'ba.logs.Live'

local max_entries 	= ba.logs.MaxEntries
local log_data 		= ba.logs.Data
local player_logs 	= ba.logs.PlayerEvents
local log_mt 		= ba.log_mt

local db 			= ba.data.GetDB()

local net 			= net
local ipairs 		= ipairs
local IsValid 		= IsValid
local type 			= type
local table_insert 	= table.insert
local player_GetAll = player.GetAll
local os_date 		= os.date
local os_time 		= os.time

function log_mt:Log(term, ...)
	local tab = log_data[self:GetName()]
	table_insert(tab, 1, {Time = os.time(), Term = term, Data = {...}})

	net.Start('ba.logs.Live')
		net.WriteUInt(term, 8)
		net.WriteUInt(self:GetID(), 5)
		for k, v in ipairs({...}) do
            if isplayer(v) and !v:IsBot()  then
                net.WriteBit(0)
                net.WritePlayer(v)
            else
                net.WriteBit(1)
                net.WriteString(tostring(v))
            end
		end
	net.Send(table.Filter(player.GetAll(), function(v) return v:GetBVar('LiveLogs') end))

	if (#tab > max_entries) then
		tab[#tab] = nil
	end
end

function log_mt:PlayerLog(players, term, ...)
	for _, pl in ipairs((type(players) == 'table') and players or {players}) do
		local tab = player_logs[pl:SteamID()]
		if (not tab) then
			player_logs[pl:SteamID()] = {}
			tab = player_logs[pl:SteamID()]
		end
		local len = #tab
		table_insert(tab, 1, {Time = os.time(), Term = term, Data = {...}})

		if (#tab > max_entries) then
			tab[#tab] = nil
		end
	end
	return self:Log(term, ...)
end

net('ba.logs.RequestCategory', function(len, pl)
    if not pl:HasFlag('M') then return end
    local cat = ba.logs.GetByID(net.ReadUInt(5))
    local logs = log_data[cat:GetName()] or {}

    net.Start 'ba.logs.RequestCategory'
        if (table.Count(logs) <= 0) then
                net.WriteBool(false)
                net.WriteUInt(cat:GetID(), 5)
            net.Send(pl)
            return
        end
        net.WriteBool(true)
        net.WriteUInt(cat:GetID(), 5)
        net.WriteUInt(table.Count(logs), 7)

        for k,v in pairs(logs) do
            net.WriteUInt(v.Term, 8)
            net.WriteUInt(v.Time, 32)

            net.WriteUInt(table.Count(v.Data), 4)
            for k, v in pairs(v.Data) do
                net.WriteString(tostring(v))
			end
        end
    net.Send(pl)
end)

net("ba.logs.RequestPlayerEvents", function(len, pl)
    if not pl:HasFlag('M') then return end
    local steamid = net.ReadString()
	local logs = player_logs[steamid] or {}

	net.Start 'ba.logs.RequestPlayerEvents'
        if (table.Count(logs) <= 0) then
                net.WriteBool(false)
            net.Send(pl)
            return
        end
        net.WriteBool(true)
        net.WriteUInt(table.Count(logs), 7)

        for k,v in pairs(logs) do
            net.WriteUInt(v.Term, 8)
            net.WriteUInt(v.Time, 32)

            net.WriteUInt(table.Count(v.Data), 4)
            for k, v in pairs(v.Data) do
                net.WriteString(tostring(v))
            end
        end
    net.Send(pl)
end)

net("ba.logs.UpdateSubscription", function(len, pl)
    if not pl:HasFlag('M') then return end
    pl:SetBVar('LiveLogs', tobool(net.ReadBit()))
end)

/*
hook.Add('playerRankLoaded', 'ba.logs.playerRankLoaded', function(pl)
	db:Query('REPLACE INTO ba_iplog VALUES(?,?,?);', pl:SteamID64(), os.time(), pl:NiceIP())
end)
