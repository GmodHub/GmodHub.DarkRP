/*local db = rp._Stats

-- Creation & Modification
function rp.orgs.Exists(name, cback)
	db:Query('SELECT COUNT("Name") FROM orgs WHERE Name=?;', name, function(count)
		cback(count[1]['COUNT("Name")'] and tonumber(count[1]['COUNT("Name")']) > 0)
	end)
end

function rp.orgs.Create(steamid, name, color, callback)
	db:Query('INSERT INTO orgs(Owner, Name, Color, MoTD) VALUES(?, ?, ?, ?);', steamid, name, color:ToHex(), 'Welcome to ' .. name .. '!', function()
		db:Query('INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD) VALUES(?, ?, ?, ?, ?, ?, ?),(?, ?, ?, ?, ?, ?, ?);', name, 'Owner', 100, 1, 1, 1, 1, name, 'Member', 1, 0, 0, 0, 0, function()
			rp.orgs.lookup[name] = {
				Name = name,
				Members = {},
				Ranks = {
					Owner = {
						Org = name,
						RankName = 'Owner',
						Weight = 100,
						Invite = true,
						Kick = true,
						Rank = true,
						MoTD = true,
						Banner = true,
						Withdraw = true,
					},
					Members = {
						Org = name,
						RankName = 'Member',
						Weight = 1,
						Invite = false,
						Kick = false,
						Rank = false,
						MoTD = false,
						Banner = false,
						Withdraw = false,
					}
				}
			}

			rp.orgs.Join(steamid, name, 'Owner', callback)
		end)
	end)
end

function rp.orgs.Remove(name, callback)
	db:Query('DELETE FROM orgs WHERE Name=?;', name, function()
		db:Query('DELETE FROM org_player WHERE Org=?;', name, function()
			db:Query('DELETE FROM org_rank WHERE Org=?;', name, function()
				db:Query('DELETE FROM org_banner WHERE Org=?;', name, function()
					for k, v in ipairs(rp.orgs.GetOnlineMembers(name)) do
						v:SetOrg(nil, nil)
						v:SetOrgData(nil)
						rp.Notify(v, NOTIFY_ERROR, term.Get('OrgDisbanded'), name)
					end

					rp.orgs.lookup[name] = nil

					if callback then callback() end
				end)
			end)
		end)
	end)
end

function rp.orgs.Quit(steamid, callback)
	db:Query('DELETE FROM org_player WHERE SteamID=?;', steamid, callback)
end

function rp.orgs.SetMoTD(org, motd, darkmode, callback)
	db:Query('UPDATE orgs SET MoTD=? WHERE Name=?', motd, org, function() -- this line was not playing nice
		for k, v in ipairs(rp.orgs.GetOnlineMembers(org)) do
			local dat = v:GetOrgData()
			dat.MoTD.Text = motd
			dat.MoTD.Dark = darkmode
			v:SetOrgData(dat)
		end
		if callback then callback() end
	end)
end

function rp.orgs.SetName(org, name, callback)
	db:Query('UPDATE orgs SET Name=? WHERE Name=?', name, org, function()
		db:Query('UPDATE org_player SET Org=? WHERE Org=?', name, org, function()
			db:Query('UPDATE org_rank SET Org=? WHERE Org=?', name, org, function()

				for k, v in ipairs(rp.orgs.GetOnlineMembers(org)) do
					local color = v:GetOrgColor()
					v:SetOrg(name, color)
				end
				if callback then callback() end
			end)
		end)
	end)
end

function rp.orgs.SetColor(org, color, callback)
	db:Query('UPDATE orgs SET Color=? WHERE Name=?', color:ToHex(), org, function()
		for k, v in ipairs(rp.orgs.GetOnlineMembers(org)) do
			v:SetOrg(org, color)
		end
		if callback then callback() end
	end)
end

//-----------------------------------------------------------------------------
// Bank:
//-----------------------------------------------------------------------------

function rp.orgs.SetBank(org, amt, callback)
	db:Query('UPDATE orgs SET Bank=? WHERE Name=?', amt, org, function()
		rp.orgs.lookup[org].Bank = amt
		if callback then callback() end
	end)
end

function rp.orgs.Join(steamid, org, rank, callback)
	rp.orgs.lookup[org].Members[steamid] = {
		SteamID = steamid,
		Org = org,
		Rank = rank
	}

	db:Query('INSERT INTO org_player(SteamID, Org, Rank) VALUES(?, ?, ?);', steamid, org, rank, callback)
end

function rp.orgs.Kick(steamid, callback)

	db:Query('DELETE FROM org_player WHERE SteamID=?;', steamid, function()
		if callback then callback() end
	end)
end

function rp.orgs.GetMembers(org, callback)
	db:Query("SELECT * FROM org_rank WHERE Org = ? ORDER BY Weight DESC;", org, function(ranks)
		db:Query('SELECT org_player.SteamID, org_player.Rank, player_data.Name FROM org_player LEFT JOIN player_data ON org_player.SteamID = player_data.SteamID WHERE org_player.Org = ?;', org, function(members)
			db:Query('SELECT * FROM orgs WHERE Name = ?', org, function(OrgData)

				rp.orgs.lookup[org] = {
					Name = OrgData[1].Name,
					Ranks = {},
					Members = {},
					RanksOrdered = ranks,
					HasUpgrade = tobool(OrgData[1].HasUpgrade),
					Bank = OrgData[1].Bank
				}

				for k, v in ipairs(ranks) do
					rp.orgs.lookup[org].Ranks[v.RankName] = v
				end

				for k, v in ipairs(members) do
					rp.orgs.lookup[org].Members[v.SteamID] = v

					if tobool(v.HasUpgrade) then
						rp.orgs.lookup[org].Upgraded = true
					end
				end

				rp.orgs.lookup[org].IsUpgraded = function() return rp.orgs.lookup[org].HasUpgrade end
				rp.orgs.lookup[org].Upgrade = function()
					rp.orgs.lookup[org].HasUpgrade = true
					db:Query('UPDATE orgs SET HasUpgrade=? WHERE Name=?', 1, org)
				end

				if (callback) then callback(members, ranks) end
			end)
		end)
	end)
end

function rp.orgs.GetMemberCount(name, cback)
	db:Query('SELECT COUNT("Name") FROM org_player WHERE Org=?;', name, function(count)
		cback(count[1]['COUNT("Name")'] and tonumber(count[1]['COUNT("Name")']) or 0)
	end)
end

function rp.orgs.RecalculateWeights(org, ranks)
	table.SortByMember(ranks, 'Weight', true)

	local mems = rp.orgs.GetOnlineMembers(org)

	for k, v in ipairs(ranks) do
		local newWeight = 1 + math.floor(((k - 1) / (#ranks - 1)) * 99)

		if (newWeight != v.Weight) then
			for _, pl in pairs(mems) do
				local od = pl:GetOrgData()
				if (od.Rank == v.RankName) then
					od.Weight = v.Weight
					pl:SetOrgData(od)
				end
			end

			db:Query('UPDATE org_rank SET Weight=? WHERE Org=? AND RankName=?', newWeight, org, v.RankName)
		end

		rp.orgs.lookup[org].Ranks[v.RankName].Weight = newWeight
	end
end
