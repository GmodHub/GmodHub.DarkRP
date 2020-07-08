rp.data = rp.data or {}
local db = rp._Stats

function rp.data.LoadPlayer(pl, cback)
	db:Query('SELECT * FROM player_data WHERE SteamID=' .. pl:SteamID64() .. ';', function(_data)
		local data = _data[1] or {}

		if IsValid(pl) then
			if (#_data <= 0) then
				db:Query('INSERT INTO player_data(SteamID, Name, Money, Karma, Pocket) VALUES(?, ?, ?, ?, ?);', pl:SteamID64(), pl:SteamName(), rp.cfg.StartMoney, rp.cfg.StartKarma, '{}')
				pl:SetRPName(rp.names.Random(), true)
			end

			if data.Name and (data.Name ~= pl:SteamName()) then
				pl:SetNetVar('Name', data.Name)
			end

			/*db:Query('SELECT * FROM player_hats WHERE SteamID=' .. pl:SteamID64() .. ';', function(data)
				nw.WaitForPlayer(pl, function()
					local HatData = {}
					for k, v in ipairs(data) do
						HatData[k] = v.Model
						if (tonumber(v.Active) == 1) then
							pl:SetHat(v.Model)
						end
					end
				//	pl:SetNetVar('HatData', HatData)
				end)
			end)*/

			nw.WaitForPlayer(pl, function()
				pl:SetNetVar('Money', data.Money or rp.cfg.StartMoney)
				pl:SetNetVar('Karma', data.Karma or rp.cfg.StartKarma)

				local succ, tbl = pcall(pon.decode, data.Pocket)
				if (not istable(tbl)) then
					rp.inv.Data[pl:SteamID64()] = {}
				else
					rp.inv.Data[pl:SteamID64()] = tbl
				end

				pl:SendInv()

				pl:SetVar('DataLoaded', true)
				hook.Call('PlayerDataLoaded', GAMEMODE, pl, data)
			end)

			if cback then cback(data) end
		end
	end)
end

function GM:PlayerAuthed(pl)
	rp.data.LoadPlayer(pl)
end

function rp.data.SetName(pl, name, cback)
	db:Query('UPDATE player_data SET Name=? WHERE SteamID=' .. pl:SteamID64() .. ';', name, function(data)
		pl:SetNetVar('Name', name)
		if cback then cback(data) end
	end)
end

function rp.data.GetNameCount(name, cback)
	db:Query('SELECT COUNT(*) as `count` FROM player_data WHERE Name=?;', name, function(data)
		if cback then cback(tonumber(data[1].count) > 0) end
	end)
end

function rp.data.SetMoney(pl, amount, cback)
	db:Query('UPDATE player_data SET Money=? WHERE SteamID=' .. pl:SteamID64() .. ';', amount, cback)
end

function rp.data.PayPlayer(pl1, pl2, amount)
	if not IsValid(pl1) or not IsValid(pl2) then return end
	pl1:TakeMoney(amount)
	pl2:AddMoney(amount)
end

function rp.data.SetKarma(pl, amount, cback)
	if (pl:GetKarma() ~= amount) then
		db:Query('UPDATE player_data SET Karma=? WHERE SteamID=' .. pl:SteamID64() .. ';', amount, cback)
	end
end

function rp.data.SetPocket(steamid64, data, cback)
	db:Query('UPDATE player_data SET Pocket=? WHERE SteamID=' .. steamid64 .. ';', data, cback)
end
/*
function ba.data.SetHat(pl, mdl, cback)
	local steamid = pl:SteamID64()
	db:Query('UPDATE player_hats Set Active=0 WHERE SteamID=' .. steamid .. ';', function()
		if (mdl ~= nil) then
			db:Query('REPLACE INTO player_hats(SteamID, Model, Active) VALUES(?, ?, 1);', steamid, mdl, function() -- We assume you own it
				if IsValid(pl) then
					pl:SetHat(mdl)
				end
				if cback then cback() end
			end)
		else
			if IsValid(pl) then
				pl:SetHat(nil)
			end
			if cback then cback() end
		end
	end)
end*/

function rp.data.IsLoaded(pl)
	if IsValid(pl) and (pl:GetVar('DataLoaded') ~= true) then
		file.Append('data_load_err.txt', os.date() .. '\n' .. pl:Name() .. '\n' .. pl:SteamID() .. '\n' .. pl:SteamID64() .. '\n' .. debug.traceback() .. '\n\n')
		rp.Notify(pl, NOTIFY_ERROR, term.Get('DataNotLoaded'))
		return false
	end
	return true
end

hook('InitPostEntity', 'data.InitPostEntity', function()
	db:Query('UPDATE player_data SET Money=' .. rp.cfg.StartMoney .. ' WHERE Money <' ..  rp.cfg.StartMoney/2)
end)

--
--	Meta
--
local math = math

function PLAYER:AddMoney(amount)
	if not rp.data.IsLoaded(self) then return end

	local total = self:GetMoney() + math.floor(amount)
	rp.data.SetMoney(self, total)
	self:SetNetVar('Money', total)
end

function PLAYER:TakeMoney(amount)
	self:AddMoney(-math.abs(amount))
end

function PLAYER:AddKarma(amount, cback)
	if not rp.data.IsLoaded(self) then return end

	local add = hook.Call('PlayerGainKarma', GAMEMODE, self)

	if (add == false) then
		return add
	end

	if cback then
		cback(amount)
	end

	local total = self:GetKarma() + math.floor(amount)
	rp.data.SetKarma(self, total)
	self:SetNetVar('Karma', total)
end

function PLAYER:TakeKarma(amount)
	self:AddKarma(-math.abs(amount))
end
