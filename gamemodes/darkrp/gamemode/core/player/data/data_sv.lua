rp.data = rp.data or {}
local db = rp._Stats

function rp.data.LoadPlayer(pl, cback)
	db:Query('SELECT * FROM player_data WHERE SteamID=' .. pl:SteamID64() .. ';', function(_data)
		local data = _data[1] or {}

		if IsValid(pl) then
			if (#_data <= 0) then
				db:Query('INSERT INTO player_data(SteamID, Name, Money, Karma, Pocket, Skills, ActiveApparel) VALUES(?, ?, ?, ?, ?, ?, ?);', pl:SteamID64(), pl:SteamName(), rp.cfg.StartMoney, rp.cfg.StartKarma, '{}', '[]', '[]')
				pl:SetRPName(rp.names.Random(), true)
			end

			if data.Name and (data.Name ~= pl:SteamName()) then
				pl:SetNetVar('Name', data.Name)
			end

			if data.Skills then
				local skills = util.JSONToTable(data.Skills)
				pl:SetNetVar('Skills', skills)
			end

			db:Query('SELECT * FROM player_apparel WHERE SteamID=' .. pl:SteamID64() .. ';', function(hats)
				nw.WaitForPlayer(pl, function()
					if hats[1] then
						local HatData = {}
						for k, v in ipairs(hats) do
							HatData[k] = v.UID
						end
						pl:SetNetVar('OwnedApparel', HatData)
					end

					if data.ActiveApparel then
						pl:SetNetVar('ActiveApparel', util.JSONToTable(data.ActiveApparel))
					end
				end)
			end)

			db:Query('SELECT * FROM org_player LEFT JOIN orgs ON org_player.Org = orgs.UID WHERE org_player.SteamID=' .. pl:SteamID64() .. ';', function(data)
				local d = data[1]
				if d then
					d.OrgData = {}
					db:Query('SELECT * FROM org_rank WHERE Org = "' .. d.Org .. '" AND RankName = "' .. d.Rank .. '";', function(data)
						local _d = data[1]
						if _d then
							d.OrgData.Perms = _d
							local orgColor = Color()
							orgColor:SetHex(d.Color)

							pl:SetOrg(d.Name, orgColor)
							pl:SetOrgData({
								UID = d.UID,
								HasUpgrade = d.HasUpgrade,
								Rank = d.Rank,
								MoTD = {
									Text = d.MoTD,
									Dark = d.Dark
								},
								Perms = {
									Weight = _d.Weight,
									Owner = (_d.Weight == 100),
									Invite = _d.Invite,
									Kick = _d.Kick,
									Rank = _d.Rank,
									MoTD = _d.MoTD,
									Banner = _d.Banner,
									Withdraw = _d.Withdraw,
								}
							})
						end
					end)
				end
			end)

			nw.WaitForPlayer(pl, function()
				pl:SetNetVar('Money', data.Money or rp.cfg.StartMoney)
				pl:SetNetVar('Karma', data.Karma or rp.cfg.StartKarma)
				pl:SetNetVar('Credits', data.Credits or 0)
				pl:SetNetVar("Energy", CurTime() + rp.cfg.HungerRate)

				pl:ChatPrint('Вам доступно ' .. pl:GetCredits() .. ' кредитов.')

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

function rp.data.SetCredits(steamid, amount, cback)
	db:Query('UPDATE player_data SET Credits=? WHERE SteamID=' .. steamid .. ';', amount, cback)
end

function rp.data.SetPocket(steamid64, data, cback)
	db:Query('UPDATE player_data SET Pocket=? WHERE SteamID=' .. steamid64 .. ';', data, cback)
end

function rp.data.SaveActiveApparel(pl)
	local steamid64 = pl:SteamID64()
	local activeApparel = util.TableToJSON(pl:GetApparel())
	db:Query('UPDATE player_data SET ActiveApparel=? WHERE SteamID=' .. steamid64 .. ';', activeApparel)
end

function rp.data.AddApparel(pl, uid, cback)
	local steamid64 = pl:SteamID64()
	if (uid ~= nil) then
		db:Query('REPLACE INTO player_apparel(SteamID, UID) VALUES(?, ?);', steamid64, uid, function() -- We assume you own it
			if IsValid(pl) then
				pl:AddApparel(uid)
			end
			if cback then cback() end
		end)
	end
end

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

function PLAYER:SetRPName(name, firstRun)
	name = string.Trim(name)
	name = string.sub(name, 1, 20)

	local lowername = string.lower(tostring(name))
	rp.data.GetNameCount(name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		if taken then
			if firstRun then
				self:SetRPName(name .. "1", firstRun)
				rp.Notify(self, NOTIFY_ERROR, term.Get('SteamRPNameTaken'))
			else
				rp.Notify(self, NOTIFY_ERROR, term.Get('RPNameTaken'))
				return ""
			end
		else
			rp.NotifyAll(NOTIFY_GENERIC, term.Get('ChangeName'), self:SteamName(), name)
			rp.data.SetName(self, name)
		end
	end)
end

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
	if (self:GetKarma() - amount) <= 0 then amount = self:GetKarma() end
	self:AddKarma(-math.abs(amount))
end

function PLAYER:AddCredits(amount, note, cback)
	self:SetNetVar('Credits', self:GetCredits() + amount)
	rp.data.SetCredits(self:SteamID64(), self:GetCredits(), function()
		if (cback) then cback() end
	end)
end

function PLAYER:TakeCredits(amount, note, cback)
	self:SetNetVar('Credits', self:GetCredits() - amount)
	rp.data.SetCredits(self:SteamID64(), self:GetCredits(), function()
		if (cback) then cback() end
	end)
end
