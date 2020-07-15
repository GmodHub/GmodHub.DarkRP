/*rp.orgs = rp.orgs or {}
rp.orgs.lookup = rp.orgs.lookup or {}

// org
util.AddNetworkString('rp.OrgsMenu')
util.AddNetworkString('rp.SetOrgMoTD')
util.AddNetworkString('rp.SetOrgColor')
util.AddNetworkString('rp.SetOrgName')
util.AddNetworkString('rp.SetOrgNameResponse')
util.AddNetworkString('rp.QuitOrg')

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

function rp.orgs.CanTarget(pl, targID)
	if (!pl:GetOrg()) then return false end
	if (pl:SteamID64() == targID) then return false end
	if (#tostring(targID) != 17) then return false end

	if (!rp.orgs.lookup[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end

	local targrank = rp.orgs.lookup[pl:GetOrg()].Ranks[rp.orgs.lookup[pl:GetOrg()].Members[targID].Rank] or rp.orgs.lookup[pl:GetOrg()].RanksOrdered[#rp.orgs.lookup[pl:GetOrg()].RanksOrdered]
	if (pl:GetOrgData().Perms.Weight <= targrank.Weight) then return false end

	return true
end

-- Load data
local function SetOrg(pl, d)
	local baseColor = color_white
	pl:SetOrg(d.Name, baseColor:SetHex(d.Color))

	local r = d.OrgData
	pl:SetOrgData({
		Rank 	= d.Rank or r.Perms.RankName,
		MoTD 	= {
			Text = d.MoTD,
			Dark = d.Dark
		},
		Perms 	= {
			Weight 	= r.Perms.Weight,
			Owner 	= (r.Perms.Weight == 100),
			Invite 	= r.Perms.Invite,
			Kick 	= r.Perms.Kick,
			Rank 	= r.Perms.Rank,
			MoTD 	= r.Perms.MoTD,
			Banner = r.Perms.Banner,
			Withdraw = r.Perms.Withdraw
		}
	})
end

function rp.OpenOrgMenu(pl)
	if not pl:GetOrg() then
		net.Start('rp.OrgsMenu')
			net.WriteBool(false)
			if (pl.OrgInvites) then
				net.WriteUInt(#pl.OrgInvites, 4)
				for k,v in pairs(pl.OrgInvites) do
					net.WriteUInt(1, 14)
					net.WriteString(k)
				end
			end
		net.Send(pl)
		return
	end

	rp.orgs.GetMembers(pl:GetOrg(), function(members, ranks)
			local rankref = {}

			net.Start('rp.OrgsMenu')

				net.WriteBool(true)
				net.WriteBool(pl:GetOrgInstance():IsUpgraded())

				net.WriteUInt(#ranks, 5)
				for k, v in ipairs(ranks) do
					net.WriteString(v.RankName)
					net.WriteUInt(v.Weight, 7)
					net.WriteBool(v.Invite)
					net.WriteBool(v.Kick)
					net.WriteBool(v.Rank)
					net.WriteBool(v.MoTD)
					net.WriteBool(v.Banner)
					net.WriteBool(v.Withdraw)

					rankref[v.RankName] = v.RankName
				end

				net.WriteUInt(#members, 8)
				for k, v in ipairs(members) do
					net.WriteString(v.SteamID)
					net.WriteString(v.Name)
					net.WriteString(rankref[v.Rank] or ranks[#ranks].Rank) -- fix for players being a rank that doesnt exist

					net.WriteBool(true)
				end

				net.WriteUInt(pl:GetOrgInstance().Bank, 32)

			net.Send(pl)
	end)
end

hook('PlayerAuthed', 'rp.orgs.PlayerAuthed', function(pl)
	local steamid = pl:SteamID64()
	db:Query('SELECT * FROM org_player LEFT JOIN orgs ON org_player.Org = orgs.Name WHERE org_player.SteamID=' .. steamid .. ';', function(data)
		local d = data[1]
		if d then
			d.OrgData = {}
			db:Query('SELECT * FROM org_rank WHERE Org = "' .. d.Org .. '" AND RankName = "' .. d.Rank .. '";', function(data)
				local _d = data[1]
				if _d then
					d.OrgData.Perms = _d
					SetOrg(pl, d)
				end
			end)
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

	if (string.len(name) < 2) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgNameShort'))
		return
	end

	if (string.len(name) > 20) then
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
		rp.orgs.Create(pl:SteamID64(), name, color, function()
			pl:TakeMoney(rp.cfg.OrgCost)
			pl:SetOrg(name, color)

			local orgdata = rp.orgs.BaseData['Owner']
			orgdata.MoTD = {}
			orgdata.MoTD.Text = 'Welcome to ' .. name .. '!'
			orgdata.MoTD.Dark = false
			pl:SetOrgData(orgdata)

			rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgCreated'))
		end)

	end)
end)
:AddParam(cmd.STRING)

rp.AddCommand('orgmenu', rp.OpenOrgMenu)

//-----------------------------------------------------------------------------
// Networks:
//-----------------------------------------------------------------------------

// Org

net("rp.OrgsMenu", function(len,pl)
	rp.OpenOrgMenu(pl)
end)

net('rp.SetOrgMoTD', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local motd = net.ReadString()
	local darkmode = net.ReadBit()
	rp.orgs.SetMoTD(pl:GetOrg(), motd, darkmode, function()
		rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgMOTDChanged'))
	end)
end)

net('rp.SetOrgColor', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local color = Color(net.ReadRGB())
	rp.orgs.SetColor(pl:GetOrg(), color, function()
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgColorChanged'))
	end)
end)

net('rp.SetOrgName', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local name = net.ReadString()
	local oldName = pl:GetOrg()

	if not pl:CanAfford(rp.cfg.OrgRenameCost) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	pl:TakeMoney(rp.cfg.OrgRenameCost)

	rp.orgs.SetName(pl:GetOrg(), name, function()

		net.Start("rp.SetOrgNameResponse")
			net.WriteBool(true)
			net.WriteTerm(term.Get('OrgRenamed'), oldName, name)
		net.Send(pl)

	end)

end)

net('rp.QuitOrg', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms then return end
	if ( not rp.orgs.lookup[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end

	if pl:GetOrgData().Perms.Owner then
		rp.orgs.Remove(pl:GetOrg())
	else
		rp.orgs.Quit(pl:SteamID64(), function()
			rp.orgs.lookup[pl:GetOrg()].Members[pl:SteamID64()] = nil

			rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrg()), NOTIFY_ERROR, term.Get('OrgPlayerQuit'), pl, pl:GetOrg())
			pl:SetOrg(nil, nil)
			pl:SetOrgData(nil)
		end)
	end
end)

// Bank

net('rp.OrgBankDeposit', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms then return end
	if not pl:GetOrgInstance() then rp.orgs.GetMembers(pl:GetOrg()) end

	local amt = math.floor(tonumber(net.ReadUInt(32)))
	local tax = math.floor(amt * rp.cfg.OrgBankTax)
	amt = math.floor(amt * (1 - rp.cfg.OrgBankTax)) -- taxed amount

	if not pl:CanAfford(amt) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	if (pl:GetOrgInstance().Bank + amt > rp.cfg.OrgBasicBankMax) and not pl:GetOrgInstance():IsUpgraded() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgBankFull'), rp.FormatMoney(amt))
		return
	end

	pl:TakeMoney(amt)

	rp.orgs.SetBank(pl:GetOrg(), pl:GetOrgInstance().Bank + amt, function()
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgBankDeposited'), rp.FormatMoney(amt), rp.FormatMoney(tax))
	end)


end)

net('rp.OrgBankWithdraw', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Withdraw then return end
	if not pl:GetOrgInstance() then rp.orgs.GetMembers(pl:GetOrg()) end

	local amt = math.floor(tonumber(net.ReadUInt(32)))

	if (amt <= 0) or ((pl:GetOrgInstance().Bank - amt) < 0) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgBankInsufficient'))
	end

	rp.orgs.SetBank(pl:GetOrg(), pl:GetOrgInstance().Bank - amt, function()
		pl:AddMoney(amt)
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('OrgBankWithdrawn'), rp.FormatMoney(amt))
	end)

end)

net('rp.AddEditOrgRank', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Rank then return end

	local create = net.ReadBool()
	local rankName = net.ReadString()
	local weight = net.ReadUInt(7)

	local invite = net.ReadBit()
	local kick = net.ReadBit()
	local canRank = net.ReadBit()

	local motd = net.ReadBit()
	local banner = net.ReadBit()
	local withdraw = net.ReadBit()

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrg(), function(ranks)
		if create then
			// Insert time!
			if (#ranks >= (pl:GetOrgInstance():IsUpgraded() and 20 or 5)) then
				rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgMaxRanks'))
				return
			end

			db:Query("INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD, Banner, Withdraw) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);", pl:GetOrg(), rankName, weight, invite, kick, canRank, motd, banner, withdraw, function()
				rp.orgs.lookup[pl:GetOrg()].Ranks[rankName] = ranks[table.insert(ranks, {
					Org = pl:GetOrg(),
					RankName = rankName,
					Weight = weight,
					Invite = tobool(invite),
					Kick = tobool(kick),
					Rank = tobool(canRank),
					MoTD = tobool(motd),
					Banner = tobool(banner),
					Withdraw = tobool(withdraw)
				})]

				rp.orgs.RecalculateWeights(pl:GetOrg(), ranks)

				rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankCreated'), rankName)
			end)
		else
			for k, v in ipairs(ranks) do
				if (v.RankName == rankName) then

					if (weight != v.Weight) then
						if (v.Weight == 100 or v.Weight == 1) then
							rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgReorderLimit'))
							return
						end

						v.Weight = weight
						rp.orgs.RecalculateWeights(pl:GetOrg(), ranks)
						return
					end

					db:Query('UPDATE org_rank SET Invite=?, Kick=?, Rank=?, MoTD=?, Banner=?, Withdraw=? WHERE Org=? AND RankName=?;', invite, kick, canRank, motd, banner, withdraw, pl:GetOrg(), rankName, function()
						rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankUpdated'), rankName)

						for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
							if (v:GetOrgData().Rank == rankName) then

								v:SetOrgData({
									Rank 	= rankName,
									MoTD 	= v:GetOrgData().MoTD,
									Perms 	= {
										Weight 	= weight,
										Owner 	= (weight == 100),
										Invite 	= tobool(invite),
										Kick 	= tobool(kick),
										Rank 	= tobool(canRank),
										MoTD 	= tobool(motd),
										Banner = tobool(banner),
										Withdraw = tobool(withdraw),
									}
								})

							end
						end

						local cache = rp.orgs.lookup[pl:GetOrg()].Ranks[rankName]
						cache.Invite = tobool(invite)
						cache.Kick = tobool(kick)
						cache.Rank = tobool(canRank)
						cache.MoTD = tobool(motd)
						cache.Banner = tobool(banner)
						cache.Withdraw = tobool(withdraw)
					end)

					return
				end
			end
		end
	end)

end)

net('rp.RenameOrgRank', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Rank then return end

	local rankName = net.ReadString()
	local newName = net.ReadString()

	if not newRankName or not rankName or newRankName == '' then return end

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				db:Query("UPDATE org_rank SET RankName=? WHERE Org=? AND RankName=?", newName, pl:GetOrg(), rankName, function()
					db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?;", newName, pl:GetOrg(), rankName)

					rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankRename'), rankName, newName)

					for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
						if (v:GetOrgData().Rank == rankName) then
							local orgData = v:GetOrgData()
							orgData.Rank = newName
							v:SetOrgData(orgData)
						end
					end

					for k, v in pairs(rp.orgs.cached[pl:GetOrg()].Members) do
						if (v.Rank == rankName) then
							v.Rank = newName
						end
					end

					rp.orgs.lookup[pl:GetOrg()].Ranks[newName] = rp.orgs.cached[pl:GetOrg()].Ranks[rankName]
					rp.orgs.lookup[pl:GetOrg()].Ranks[newName].RankName = newName
					rp.orgs.lookup[pl:GetOrg()].Ranks[rankName] = nil
				end)
			end
		end
	end)
end)

net('rp.RemoveOrgRank', function(len, pl)
	local perms = pl:GetOrg() and pl:GetOrgData() and pl:GetOrgData().Perms
	local rankName = net.ReadString()

	if (!rankName or !perms or !perms.Owner) then return end

	if (!rp.orgs.lookup[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end

	db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC", pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				if (k == 1 or k == #ranks) then
					rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgDeleteLimit'))
					return
				end

				local nextRank = ranks[k+1]
				db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?", nextRank.RankName, pl:GetOrg(), rankName)
				db:Query("DELETE FROM org_rank WHERE Org=? AND RankName=?", pl:GetOrg(), rankName)
				for _, pl in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
					local od = pl:GetOrgData()

					if (od.Rank == rankName) then
						od = {
							Rank 	= nextRank.RankName,
							MoTD 	= od.MoTD,
							Perms 	= {
								Weight 	= nextRank.Weight,
								Owner 	= (nextRank.Weight == 100),
								Invite 	= nextRank.Invite,
								Kick 	= nextRank.Kick,
								Rank 	= nextRank.Rank,
								MoTD 	= nextRank.MoTD,
								Banner = nextRank.Banner,
								Withdraw = nextRank.Withdraw
							}
						}

						pl:SetOrgData(od)
					end
				end

				for _, mem in pairs(rp.orgs.lookup[pl:GetOrg()].Members) do
					if (mem.Rank == rankName) then
						mem.Rank = nextRank.Name
					end
				end

				rp.orgs.lookup[pl:GetOrg()].Ranks[rankName] = nil

				rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgRankDelete'), rankName)

				return
			end
		end

		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgUnknownRank'), rankName)
	end)
end)

// Members

net.Receive("rp.OrgInvite", function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Invite then return end

	local targ = net.ReadPlayer()
	if not targ then return end

	if (targ:GetOrg()) then return end

	if not pl:GetOrgInstance() then rp.orgs.GetMembers(pl:GetOrg()) end
	local org = pl:GetOrg()

	rp.orgs.GetMemberCount(org, function(count)
		if (!IsValid(pl)) then return end

		local lim = (pl:GetOrgInstance():IsUpgraded() and rp.cfg.OrgMaxMembersPremium or rp.cfg.OrgMaxMembers)
		if (count >= lim) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgMemberLimit'), lim)
			return
		end

		if (!pl:CanAfford(rp.cfg.OrgInviteCost)) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
			return
		end

		if not IsValid(targ) then return end

		if (targ.OrgInvites and targ.OrgInvites[org]) then return end
		targ.OrgInvites = targ.OrgInvites or {}

		table.insert(targ.OrgInvites, org)

		pl:TakeMoney(rp.cfg.OrgInviteCost)
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get("OrgPlayerInvited"), targ, rp.cfg.OrgInviteCost)

	end)

end)

net.Receive("rp.OrgInviteResponse", function(len, pl)

	local uid = net.ReadUInt(14)
	local answer = net.ReadBool()

	if not pl.OrgInvites[uid] then return end
	if not isbool(answer) then return end
	if not rp.orgs.lookup[pl.OrgInvites[uid]] then return end

	local org = rp.orgs.lookup[pl.OrgInvites[uid]]

	db:Query("SELECT * FROM org_rank WHERE Org=? AND Weight=1;", org.Name, function(data)
		rp.orgs.Join(pl:SteamID64(), org.Name, data[1].RankName, function()
			pl:SetOrg(org.Name, color_white)
			local orgdata = {
				Rank = data[1].RankName,
				MoTD = {
					Text = org.Ranks["Owner"].MoTD
					Dark = org.Ranks["Owner"].Dark or false,
				},
				Perms = {
					Weight = data[1].Weight,
					Owner = (data[1].Weight == 100),
					Invite = data[1].Invite,
					Kick = data[1].Kick,
					Rank = data[1].Rank,
					MoTD = data[1].MoTD,
					Banner = data[1].Banner,
					Withdraw = data[1].Withdraw,
				}
			}

			pl:SetOrgData(orgdata)

			rp.orgs.lookup[uid].Members[pl:SteamID64()] = {
				SteamID=pl:SteamID64(),
				Org=org.Name,
				Rank=data[1].RankName
			}

			rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrg()), NOTIFY_SUCCESS, term.Get('OrgMemberJoined'), pl, pl:GetOrg())
			pl.OrgInvites[uid] = nil
		end)
	end)
end)

net.Receive("rp.OrgKick", function(len, pl)
	local steamid = net.ReadString()
	if not steamid or not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Kick or not rp.orgs.CanTarget(pl, steamid) then return end

	rp.orgs.lookup[pl:GetOrg()].Members[steamid] = nil
	rp.orgs.Kick(steamid, function()
		local targ = player.Find(steamid)
		rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrg()), NOTIFY_ERROR, term.Get('OrgPlayerKicked'), targ, pl:GetOrg())
		if IsValid(targ) then
			rp.Notify(targ, NOTIFY_ERROR, term.Get('OrgPlayerYoureKicked'), pl:GetOrg())
			targ:SetOrg(nil, nil)
			targ:SetOrgData(nil)
		end
	end)
end)

net.Receive("rp.OrgSetRank", function(len, pl)
	local steamid = net.ReadString()

	if not steamid or not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Rank or not rp.orgs.CanTarget(pl, steamid) then return end

	local rankName = net.ReadString()
	local cache = rp.orgs.lookup[pl:GetOrg()].Ranks

	if (!cache[rankName] or pl:GetOrgData().Perms.Weight <= cache[rankName].Weight) then return end

	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				db:Query("UPDATE org_player SET Rank=? WHERE SteamID=?;", rankName, steamid)

				local targ = rp.FindPlayer(args[1])
				if (targ) then
					local od = targ:GetOrgData()

					targ:SetOrgData({
						Rank 	= v.RankName,
						MoTD 	= od.MoTD,
						Dark 	= od.Dark,
						Perms 	= {
							Weight 	= v.Weight,
							Owner 	= (v.Weight == 100),
							Invite 	= v.Invite,
							Kick 	= v.Kick,
							Rank 	= v.Rank,
							MoTD 	= v.MoTD,
							Banner = v.Banner,
							Withdraw = v.Withdraw
						}
					})

					rp.Notify(targ, NOTIFY_GENERIC, term.Get('OrgYourRank'), pl, rankName)
					rp.Notify(pl, NOTIFY_GENERIC, term.Get('OrgSetRank'), targ, rankName)
				else
					rp.Notify(pl, NOTIFY_GENERIC, term.Get('OrgSetRank'), args[1], rankName)
				end

				rp.orgs.lookup[pl:GetOrg()].Members[args[1]].Rank = rankName

				return
			end
		end

		rp.Notify(pl, NOTIFY_ERROR, term.Get('OrgUnknownRank'), rankName)
	end)
end)
/*
net.Receive("rp.PromoteOrgLeader", function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local steamid = net.ReadString()

	if not steamid or not steamid:IsSteamID64() then return end
	db:Query("UPDATE orgs SET Owner=? WHERE Owner=?", steamid, pl:SteamID64())
	db:Query("UPDATE org_player SET SteamID=? WHERE SteamID=? AND Org=?", steamid, pl:SteamID64(), pl:GetOrg())
	db:Query("SELECT * FROM org_rank WHERE Org=? AND Weight=1;", pl:GetOrg(), function(data)

	end)


end)
