rp.orgs = rp.orgs or {}
rp.orgs.lookup = rp.orgs.lookup or {}

// org
util.AddNetworkString('rp.OrgsMenu')
util.AddNetworkString('rp.SetOrgMoTD')
util.AddNetworkString('rp.SetOrgColor')
util.AddNetworkString('rp.SetOrgName')
util.AddNetworkString('rp.SetOrgNameResponse')
util.AddNetworkString('rp.QuitOrg')
util.AddNetworkString('rp.OrgLog')

// Bank
util.AddNetworkString('rp.OrgBankDeposit')
util.AddNetworkString('rp.OrgBankWithdraw')

// Ranks
util.AddNetworkString('rp.AddEditOrgRank')
util.AddNetworkString('rp.RenameOrgRank')
util.AddNetworkString('rp.RemoveOrgRank')

// Members
util.AddNetworkString('rp.OrgInvite')
util.AddNetworkString('rp.OrgInviteResponse')
util.AddNetworkString('rp.OrgKick')
util.AddNetworkString('rp.OrgSetRank')
util.AddNetworkString('rp.PromoteOrgLeader')

local db = rp._Stats
local badb = ba.data.GetDB()

function rp.orgs.Exists(name, cback)
	db:Query('SELECT COUNT("Name") FROM orgs WHERE Name=?;', name, function(count)
		cback(count[1]['COUNT("Name")'] and tonumber(count[1]['COUNT("Name")']) > 0)
	end)
end

function rp.orgs.CanTarget(pl, targID)
	if (!pl:GetOrg()) then return false end
	if (pl:SteamID64() == targID) then return false end
	if (not targID:IsSteamID64()) then return false end

	db:Query('SELECT * FROM org_player WHERE SteamID = ? AND Org = ?;', targID, pl:GetOrgUID(), function(targetRank)
		if not targetRank[1] then return false end
		db:Query("SELECT * FROM org_rank WHERE RankName=? ORDER BY Weight DESC;", targetRank[1].Rank, function(rank)
			if rank[1].Weight >= pl:GetOrgData().Perms.Weight then return false end
		end)
	end)
	return true

end

function rp.orgs.Upgrade(pl)
	db:Query('UPDATE orgs SET HasUpgrade=? WHERE UID=?', 1, pl:GetOrgUID(), function()
		rp.orgs.Log(pl:GetOrgUID(), "улучшил статус банды до премиальной!", pl)
		for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
			local orgData = v:GetOrgData()
			orgData.HasUpgrade = true
			v:SetOrgData(orgData)
		end
	end)
end

function rp.orgs.RecalculateWeights(uid, ranks)
	table.SortByMember(ranks, 'Weight', true)

	local mems = rp.orgs.GetOnlineMembers(uid)

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

			db:Query('UPDATE org_rank SET Weight=? WHERE Org=? AND RankName=?', newWeight, uid, v.RankName)
		end
	end
end

// Misc

function rp.orgs.Log(UID, log, pl)
	if pl then
		log = pl:Name() .. "(" .. pl:SteamID() .. ") " .. log
	end
	db:Query('INSERT INTO org_logs(Org, Time, String) VALUES(?, ?, ?);', UID, os.time(), log)
end

function rp.orgs.GetLogs(UID, cback)
	db:Query('SELECT * FROM org_logs WHERE Org=?;', UID, cback)
end

//-----------------------------------------------------------------------------
// Networks:
//-----------------------------------------------------------------------------

// Orgs

net("rp.OrgsMenu", function(len,pl)
	if not pl:GetOrg() then
			db:Query("SELECT * FROM org_invites LEFT JOIN orgs ON org_invites.Org = orgs.UID WHERE SteamID=?", pl:SteamID64(), function(invites)
				net.Start('rp.OrgsMenu')
					net.WriteBool(false)
					if (invites[1]) then
						net.WriteUInt(table.Count(invites), 4)
						for k,v in pairs(invites) do
							net.WriteUInt(v.Org, 14)
							net.WriteString(v.Name)
						end
					else
						net.WriteUInt(0, 4)
					end
				net.Send(pl)
			end)
		return
	end

	db:Query("SELECT * FROM orgs WHERE UID=?;", pl:GetOrgUID(), function(orgdata)
		db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC;", pl:GetOrgUID(), function(ranks)
			db:Query('SELECT org_player.SteamID, org_player.Rank, player_data.Name FROM org_player LEFT JOIN player_data ON org_player.SteamID = player_data.SteamID WHERE org_player.Org = ?;', pl:GetOrgUID(), function(members)
				orgdata = orgdata[1]
				net.Start('rp.OrgsMenu')
					net.WriteBool(true)
					net.WriteBool(orgdata.HasUpgrade)
					net.WriteUInt(table.Count(ranks), 5)
					for k, v in pairs(ranks) do
						net.WriteString(v.RankName)
						net.WriteUInt(v.Weight, 7)
						net.WriteBool(v.Invite)
						net.WriteBool(v.Kick)
						net.WriteBool(v.Rank)
						net.WriteBool(v.MoTD)
						net.WriteBool(v.Banner)
						net.WriteBool(v.Withdraw)
					end

					net.WriteUInt(table.Count(members), 8)

				for k, v in ipairs(members) do
					badb:Query('SELECT lastseen FROM ba_users WHERE steamid=?', v.SteamID, function(_data)
						net.WriteString(v.SteamID)
						net.WriteString(v.Name)
						net.WriteString(v.Rank) -- fix for players being a rank that doesnt exist

						if player.Find(v.SteamID) then
							net.WriteBool(true)
						else
							net.WriteBool(false)
							net.WriteUInt(os.time() - _data[1].lastseen, 32)
						end

						// trick to send after lastseen response
						if (table.Count(members) == k) then
							net.WriteUInt(orgdata.Bank, 32)
							net.Send(pl)
						end
					end)
				end
			end)
		end)
	end)
end)

net('rp.SetOrgMoTD', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('MoTD') then return end
	local motd = net.ReadString() or ""
	local dark = pl:IsOrgUpg() and net.ReadBit() or 0

	db:Query('UPDATE orgs SET MoTD=?, Dark=? WHERE UID=?', motd, dark, pl:GetOrgUID(), function()
		for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
			local dat = v:GetOrgData()
			dat.MoTD.Text = motd
			dat.MoTD.Dark = dark
			v:SetOrgData(dat)
		end
		rp.orgs.Log(pl:GetOrgUID(), "изменил MoTD банды", pl)
		rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgMOTDChanged'), pl:GetOrg())
	end)
end)

net('rp.SetOrgColor', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Owner') then return end
	local color = Color(net.ReadRGB()) or color_white

	db:Query('UPDATE orgs SET Color=? WHERE UID=?', color:ToHex(), pl:GetOrgUID(), function()
		for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
			v:SetOrgColor(color)
		end
		rp.orgs.Log(pl:GetOrgUID(), "изменил цвет банды на " .. color:ToHex(), pl)
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgColorChanged'))
	end)
end)

net('rp.SetOrgName', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Owner') then return end
	local name = net.ReadString() or ""
	local oldName = pl:GetOrg()
 	name = string.Trim(name or '')

	if (string.len(name) < 2) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameShort'))
		return
	end

	if (string.len(name) > 20) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameLong'))
		return
	end

	if not pl:CanAfford(rp.cfg.OrgRenameCost) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	rp.orgs.Exists(name, function(exists)
		if (exists) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgRenameFailed'))
			return
		end

		pl:TakeMoney(rp.cfg.OrgRenameCost)

		db:Query('UPDATE orgs SET Name=? WHERE UID=?', name, pl:GetOrgUID(), function()
			for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
				v:SetOrgName(name)
			end
			net.Start("rp.SetOrgNameResponse")
				net.WriteBool(true)
				net.WriteTerm(term.Get('OrgRenamed'), oldName, name)
			net.Send(pl)
			rp.orgs.Log(pl:GetOrgUID(), "переименовал банду из " .. oldName .. " в " .. name, pl)
		end)
	end)
end)

net('rp.QuitOrg', function(len, pl)
	if not pl:GetOrg() then return end

	if pl:HasOrgPerm('Owner') then
		local name = pl:GetOrg()
		db:Query('DELETE FROM orgs WHERE UID=?;', pl:GetOrgUID(), function()
			db:Query('DELETE FROM org_player WHERE Org=?;', pl:GetOrgUID(), function()
				db:Query('DELETE FROM org_rank WHERE Org=?;', pl:GetOrgUID(), function()
					db:Query('DELETE FROM org_logs WHERE Org=?;', pl:GetOrgUID(), function()
						db:Query('DELETE FROM org_invites WHERE Org=?;', pl:GetOrgUID(), function()
							for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
								v:ClearOrgVars()
								rp.Notify(v, NOTIFY_ERROR, term.Get('OrgDisbanded'), name)
							end
						end)
					end)
				end)
			end)
		end)
	else
		db:Query('DELETE FROM org_player WHERE SteamID=?;', pl:SteamID64(), function()
			rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrgUID()), NOTIFY_ERROR, term.Get('OrgPlayerQuit'), pl, pl:GetOrg())
			pl:ClearOrgVars()
		end)
	end
end)

// Bank

net('rp.OrgBankDeposit', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Withdraw') then return end

	local amt = math.floor(tonumber(net.ReadUInt(32)))
	local tax = math.floor(amt * rp.cfg.OrgBankTax)
	amt = math.floor(amt * (1 - rp.cfg.OrgBankTax)) -- taxed amount

	if not pl:CanAfford(amt) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	db:Query("SELECT Bank FROM orgs WHERE UID=?;", pl:GetOrgUID(), function(orgdata)
		if (orgdata[1].Bank + amt > rp.cfg.OrgBasicBankMax) and not pl:IsOrgUpg() then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgBankFull'), rp.FormatMoney(amt))
			return
		end

		pl:TakeMoney(amt)

		db:Query('UPDATE orgs SET Bank=? WHERE UID=?', orgdata[1].Bank + amt, pl:GetOrgUID(), function()
			rp.orgs.Log(pl:GetOrgUID(), "пополнил банк банды на ".. rp.FormatMoney(amt), pl)
			rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgBankDeposited'), rp.FormatMoney(amt), rp.FormatMoney(tax))
		end)
	end)
end)

net('rp.OrgBankWithdraw', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Withdraw') then return end

	local amt = math.floor(tonumber(net.ReadUInt(32)))

	db:Query("SELECT Bank FROM orgs WHERE UID=?;", pl:GetOrgUID(), function(orgdata)
		if (amt <= 0) or ((orgdata[1].Bank - amt) < 0) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgBankInsufficient'))
		end

		db:Query('UPDATE orgs SET Bank=? WHERE UID=?', orgdata[1].Bank - amt, pl:GetOrgUID(), function()
			pl:AddMoney(amt)
			rp.orgs.Log(pl:GetOrgUID(), "снял с банка банды ".. rp.FormatMoney(amt), pl)
			rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgBankWithdrawn'), rp.FormatMoney(amt))
		end)
	end)
end)

// Ranks
net('rp.AddEditOrgRank', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Rank') then return end

	local create = net.ReadBool()
	local rankName = net.ReadString() or ""
	if pl:GetOrgRank() == rankName then return end
	local weight = net.ReadUInt(7) or -1

	local invite = net.ReadBit()
	local kick = net.ReadBit()
	local canRank = net.ReadBit()
	local motd = net.ReadBit()
	local banner = net.ReadBit()
	local withdraw = net.ReadBit()

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrgUID(), function(ranks)
		if create then
			if (#ranks >= (pl:IsOrgUpg() and rp.cfg.OrgMaxRanksPremium or rp.cfg.OrgMaxRanks)) then
				rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgMaxRanks'))
				return
			end

			if weight > 100 or weight < 0 then return end
			if utf8.len(rankName) > 20 or utf8.len(rankName) <= 0 then
				rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgRankNameLength'))
				return
			end

			for k,v in pairs(ranks) do
				if v.RankName == rankName then
					rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgRankNameTaken'))
					return
				end
			end

			db:Query("INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD, Banner, Withdraw) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);", pl:GetOrgUID(), rankName, weight, invite, kick, canRank, motd, banner, withdraw, function()
				rp.orgs.RecalculateWeights(pl:GetOrgUID(), ranks)
				rp.orgs.Log(pl:GetOrgUID(), "создал ранг ".. rankName, pl)
				rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankCreated'), rankName)
			end)
		else
			for k, v in ipairs(ranks) do
				if (v.RankName == rankName) then
					if weight > 100 or weight < 0 then return end
					if utf8.len(rankName) > 20 or utf8.len(rankName) <= 0 then
						rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgRankNameLength'))
						return
					end

					if (weight != v.Weight) then
						if (v.Weight == 100 or v.Weight == 1) then
							rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgReorderLimit'))
							return
						end

						v.Weight = weight
						rp.orgs.RecalculateWeights(pl:GetOrgUID(), ranks)
						return
					end

					db:Query('UPDATE org_rank SET Invite=?, Kick=?, Rank=?, MoTD=?, Banner=?, Withdraw=? WHERE Org=? AND RankName=?;', invite, kick, canRank, motd, banner, withdraw, pl:GetOrgUID(), rankName, function()
						rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankUpdated'), rankName)
						rp.orgs.Log(pl:GetOrgUID(), "изменил ранг ".. rankName, pl)

						for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
							if (v:GetOrgRank() == rankName) then
								local orgData = v:GetOrgData()
								orgData.Rank = rankName
								orgData.Perms = {
									Weight 	= weight,
									Owner 	= (weight == 100),
									Invite 	= tobool(invite),
									Kick 	= tobool(kick),
									Rank 	= tobool(canRank),
									MoTD 	= tobool(motd),
									Banner = tobool(banner),
									Withdraw = tobool(withdraw),
								}
								v:SetOrgData(orgData)
							end
						end
					end)
					return
				end
			end
		end
	end)
end)

net('rp.RenameOrgRank', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Rank') then return end

	local rankName = net.ReadString() or ""
	local newName = net.ReadString() or ""

	if utf8.len(newName) > 20 or utf8.len(newName) <= 0 or not rankName then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgRankNameLength'))
		return
	end

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrgUID(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				db:Query("UPDATE org_rank SET RankName=? WHERE Org=? AND RankName=?", newName, pl:GetOrgUID(), rankName, function()
					db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?;", newName, pl:GetOrgUID(), rankName)

					rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankRename'), rankName, newName)
					rp.orgs.Log(pl:GetOrgUID(), "переименовал ранг ".. rankName .. " в ".. newName, pl)

					for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
						if (v:GetOrgRank() == rankName) then
							local orgData = v:GetOrgData()
							orgData.Rank = newName
							v:SetOrgData(orgData)
						end
					end
				end)
			end
		end
	end)
end)

net('rp.RemoveOrgRank', function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Rank') then return end

	local rankName = net.ReadString() or ""

	db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC", pl:GetOrgUID(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				if (k == 1 or k == #ranks) then
					rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgDeleteLimit'))
					return
				end

				local nextRank = ranks[k+1]
				db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?", nextRank.RankName, pl:GetOrgUID(), rankName)
				db:Query("DELETE FROM org_rank WHERE Org=? AND RankName=?", pl:GetOrgUID(), rankName)
				for _, ply in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrgUID())) do
					local od = ply:GetOrgData()

					if (od.Rank == rankName) then
						od = {
							Rank 	= nextRank.RankName,
							Perms 	= {
								Weight 	= nextRank.Weight,
								Owner 	= (nextRank.Weight == 100),
								Invite 	= tobool(nextRank.Invite),
								Kick 	= tobool(nextRank.Kick),
								Rank 	= tobool(nextRank.Rank),
								MoTD 	= tobool(nextRank.MoTD),
								Banner = tobool(nextRank.Banner),
								Withdraw = tobool(nextRank.Withdraw)
							}
						}

						ply:SetOrgData(od)
					end
				end
				rp.orgs.Log(pl:GetOrgUID(), "удалил ранг ".. rankName, pl)
				rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankDelete'), rankName)

				return
			end
		end
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgUnknownRank'), rankName)
	end)
end)

// Members

net("rp.OrgInvite", function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Invite') then return end

	local targ = net.ReadPlayer()
	if not targ then return end

	if (targ:GetOrg()) then return end
	local org = pl:GetOrg()

	db:Query('SELECT org_player.SteamID, org_player.Rank, player_data.Name FROM org_player LEFT JOIN player_data ON org_player.SteamID = player_data.SteamID WHERE org_player.Org = ?;', pl:GetOrgUID(), function(members)
		if (!IsValid(pl)) then return end

		local lim = (pl:IsOrgUpg() and rp.cfg.OrgMaxMembersPremium or rp.cfg.OrgMaxMembers)
		if (table.Count(members) >= lim) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgMemberLimit'), lim)
			return
		end

		if (!pl:CanAfford(rp.cfg.OrgInviteCost)) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
			return
		end

		if not IsValid(targ) then return end

		db:Query("SELECT * FROM org_invites WHERE SteamID=?", pl:SteamID64(), function(invites)
			if invites and table.Count(invites) >= 10 then
				rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgTooManyInvites'))
				return
			end

			for k,v in pairs(invites) do
				if v.Org == pl:GetOrgUID() then
					rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgInvitedAlready'), pl:GetOrg())
					return
				end
			end
			pl:TakeMoney(rp.cfg.OrgInviteCost)

			db:Query('INSERT INTO org_invites(SteamID, Org, Expire) VALUES(?, ?, ?);', targ:SteamID64(), pl:GetOrgUID(), os.time() + 172800, function()
				rp.orgs.Log(pl:GetOrgUID(), "пригласил ".. targ:Name() .. "(".. targ:SteamID()..")", pl)
				rp.Notify(pl, NOTIFY_SUCCESS, term.Get("OrgPlayerInvited"), targ, rp.cfg.OrgInviteCost)
			end)

		end)


	end)

end)

net("rp.OrgInviteResponse", function(len, pl)
	if pl:GetOrg() then return end

	local UID = net.ReadUInt(14) or 0
	local answer = net.ReadBool() or false

	db:Query("SELECT * FROM org_invites WHERE SteamID=? AND Org=?", pl:SteamID64(), UID, function(invites)
		if (invites[1]) then
			if answer then
				db:Query("SELECT * FROM orgs WHERE UID=?;", UID, function(orgdata)
					if not orgdata[1] then return end
					orgdata = orgdata[1]
					db:Query("SELECT * FROM org_rank WHERE Org=? AND Weight=1;", UID, function(data)
						db:Query('INSERT INTO org_player(SteamID, Org, Rank) VALUES(?, ?, ?);', pl:SteamID64(), UID, data[1].RankName, function()
							local orgColor = Color()
							orgColor:SetHex(orgdata.Color)
							pl:SetOrg(orgdata.Name, orgColor)
							local orgdata = {
								UID = orgdata.UID,
								HasUpgrade = orgdata.HasUpgrade,
								Rank = data[1].RankName,
								MoTD = {
									Text = orgdata.MoTD,
									Dark = orgdata.Dark,
								},
								Perms = {
									Weight = data[1].Weight,
									Owner = (data[1].Weight == 100),
									Invite = tobool(data[1].Invite),
									Kick = tobool(data[1].Kick),
									Rank = tobool(data[1].Rank),
									MoTD = tobool(data[1].MoTD),
									Banner = tobool(data[1].Banner),
									Withdraw = tobool(data[1].Withdraw),
								}
							}

							pl:SetOrgData(orgdata)
							rp.orgs.Log(pl:GetOrgUID(), "принял приглашение вступления в банду", pl)
							rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrgUID()), NOTIFY_SUCCESS, term.Get('OrgMemberJoined'), pl, pl:GetOrg())
							db:Query("DELETE FROM `org_invites` WHERE SteamID=? AND Org=?", pl:SteamID64(), UID)
						end)
					end)
				end)
			else
				db:Query("DELETE FROM `org_invites` WHERE SteamID=? AND Org=?", pl:SteamID64(), UID)
			end
		end
	end)
end)

net("rp.OrgKick", function(len, pl)
	local steamid = net.ReadString() or ""
	if not pl:GetOrg() or not pl:HasOrgPerm('Kick') or not rp.orgs.CanTarget(pl, steamid) then return end

	db:Query('DELETE FROM org_player WHERE SteamID=?;', steamid, function()
		local targ = player.Find(steamid)
		rp.orgs.Log(pl:GetOrgUID(), "исключил из банды ".. steamid, pl)
		rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrgUID()), NOTIFY_ERROR, term.Get('OrgPlayerKicked'), targ, pl:GetOrg())
		if IsValid(targ) then
			rp.Notify(targ, NOTIFY_ERROR, term.Get('OrgPlayerYoureKicked'), pl:GetOrg())
			targ:ClearOrgVars()
		end
	end)
end)

net("rp.OrgSetRank", function(len, pl)
	local steamid = net.ReadString() or ""
	if not pl:GetOrg() or not pl:HasOrgPerm('Rank') or not rp.orgs.CanTarget(pl, steamid) then return end

	local rankName = net.ReadString() or ""

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrgUID(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				db:Query("UPDATE org_player SET Rank=? WHERE SteamID=?;", rankName, steamid)

				local targ = player.Find(steamid)
				if (targ) then
					local od = targ:GetOrgData()
					od.Rank = v.RankName
					od.Perms = {
						Weight 	= v.Weight,
						Owner 	= (v.Weight == 100),
						Invite 	= tobool(v.Invite),
						Kick 	= tobool(v.Kick),
						Rank 	= tobool(v.Rank),
						MoTD 	= tobool(v.MoTD),
						Banner = tobool(v.Banner),
						Withdraw = tobool(v.Withdraw)
					}

					targ:SetOrgData(od)

					rp.Notify(targ, NOTIFY_GENERIC, term.Get('OrgYourRank'), pl, rankName)
					rp.Notify(pl, NOTIFY_GENERIC, term.Get('OrgSetRank'), targ, rankName)
				else
					rp.Notify(pl, NOTIFY_GENERIC, term.Get('OrgSetRank'), steamid, rankName)
				end
				return
			end
		end

		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgUnknownRank'), rankName)
	end)
end)

net("rp.PromoteOrgLeader", function(len, pl)
	if not pl:GetOrg() or not pl:HasOrgPerm('Owner') then return end
	local steamid = net.ReadString()
	if not steamid or not steamid:IsSteamID64() then return end

	db:Query("UPDATE orgs SET Owner=? WHERE Owner=?", steamid, pl:SteamID64())
	db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC", pl:GetOrgUID(), function(ranks)
		db:Query("UPDATE org_player SET Rank=? WHERE SteamID=? AND Org=?", ranks[1].RankName, steamid, pl:GetOrgUID())
		db:Query("UPDATE org_player SET Rank=? WHERE SteamID=? AND Org=?", ranks[2].RankName, pl:SteamID64(), pl:GetOrgUID())

		local od = pl:GetOrgData()
		od.Rank = ranks[2].RankName
		od.Perms = {
			Weight 	= ranks[2].Weight,
			Owner 	= (ranks[2].Weight == 100),
			Invite 	= tobool(ranks[2].Invite),
			Kick 	= tobool(ranks[2].Kick),
			Rank 	= tobool(ranks[2].Rank),
			MoTD 	= tobool(ranks[2].MoTD),
			Banner = tobool(ranks[2].Banner),
			Withdraw = tobool(ranks[2].Withdraw),
		}
		pl:SetOrgData(od)

		local targ = player.Find(steamid)
		if (targ) then
			local od = targ:GetOrgData()
			od.Rank = ranks[1].RankName
			od.Perms = {
				Weight 	= ranks[1].Weight,
				Owner 	= (ranks[1].Weight == 100),
				Invite 	= tobool(ranks[1].Invite),
				Kick 	= tobool(ranks[1].Kick),
				Rank 	= tobool(ranks[1].Rank),
				MoTD 	= tobool(ranks[1].MoTD),
				Banner = tobool(ranks[1].Banner),
				Withdraw = tobool(ranks[1].Withdraw),
			}
			targ:SetOrgData(od)
			rp.orgs.Log(pl:GetOrgUID(), "передал владение бандой игроку ".. steamid, pl)

			rp.Notify(pl, NOTIFY_GENERIC, term.Get('OrgOwnershipTransferred'), pl:GetOrg(), targ:Name())
			rp.Notify(targ, NOTIFY_GENERIC, term.Get('OrgOwnershipTransferredYou'), pl:Name(), pl:GetOrg())
		end
	end)

end)

//-----------------------------------------------------------------------------
// Commands:
//-----------------------------------------------------------------------------

rp.AddCommand('createorg', function(pl, name)
	local name = string.Trim(name or '')

	if (pl:GetOrg() ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgMustLeaveFirst'))
		return
	end

	if (utf8.len(name) < 2) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameShort'))
		return
	end

	if (utf8.len(name) > 20) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameLong'))
		return
	end

	rp.orgs.Exists(name, function(exists)
		if (!IsValid(pl)) then return end

		if (exists) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameTaken'))
			return
		end

		if not pl:CanAfford(rp.cfg.OrgCost) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgCannotAfford'))
			return
		end

		local color = Color(255,255,255)
		local start = SysTime()
		db:Query('INSERT INTO orgs(Owner, Name, Color, MoTD) VALUES(?, ?, ?, ?);', pl:SteamID64(), name, color:ToHex(), 'Welcome to ' .. name .. '!', function()
			db:Query("SELECT * FROM orgs WHERE Owner=?;", pl:SteamID64(), function(orgdata)
				orgdata = orgdata[1]
				db:Query('INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD, Banner, Withdraw) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?),(?, ?, ?, ?, ?, ?, ?, ?, ?);', orgdata.UID, 'Owner', 100, 1, 1, 1, 1, 1, 1, orgdata.UID, 'Member', 1, 0, 0, 0, 0, 0, 0, function()
					db:Query('INSERT INTO org_player(SteamID, Org, Rank) VALUES(?, ?, ?);', pl:SteamID64(), orgdata.UID, "Owner")
					pl:TakeMoney(rp.cfg.OrgCost)
					pl:SetOrg(name, color)
					pl:SetOrgData({
						UID = orgdata.UID,
						HasUpgrade = orgdata.HasUpgrade,
						Rank = "Owner",
						MoTD = {
							Text = orgdata.MoTD,
							Dark = orgdata.Dark
						},
						Perms = {
							Weight = 100,
							Owner = true,
							Invite = true,
							Kick = true,
							Rank = true,
							MoTD = true,
							Banner = true,
							Withdraw = true,
						}
					})
					rp.orgs.Log(pl:GetOrgUID(), "создал банду ".. name, pl)
					rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgCreated'))
				end)
			end)
		end)
	end)
end)
:AddParam(cmd.STRING)

rp.AddCommand('orglog', function(pl)
	if not pl:GetOrg() then return end

	db:Query('SELECT * FROM org_logs WHERE Org=?', pl:GetOrgUID(), function(data)
		net.Start 'rp.OrgLog'
			net.WriteUInt(table.Count(data), 8)
			for k,v in pairs(data) do
				net.WriteUInt(v.Time, 32)
				net.WriteString(v.String)
			end
		net.Send(pl)
	end)
end)
