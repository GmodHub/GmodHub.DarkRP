function PLAYER:ChangeTeam(t, force)
	local prevTeam = self:Team()

	if self:IsArrested() and not force then
		self:Notify(NOTIFY_ERROR, term.Get('CannotChangeJob'), 'arrested')
		return false
	end

	if self:IsFrozen() and not force then
		self:Notify(NOTIFY_ERROR, term.Get('CannotChangeJob'), 'frozen')
		return false
	end

	if (not self:Alive()) and not force then
		self:Notify(NOTIFY_ERROR, term.Get('CannotChangeJob'), 'dead')
		return false
	end

	if self:IsWanted() and not force then
		self:Notify(NOTIFY_ERROR, term.Get('CannotChangeJob'), 'wanted')
		return false
	end

	if rp.agendas[prevTeam] and (rp.agendas[prevTeam].manager == prevTeam) then
		nw.SetGlobal('Agenda;' .. self:Team(), nil)
	end

	if t ~= rp.DefaultTeam and not self:ChangeAllowed(t) and not force then
		rp.Notify(self, NOTIFY_ERROR, term.Get('BannedFromJob'))
		return false
	end

	if self.LastJob and 1 - (CurTime() - self.LastJob) >= 0 and not force then
		self:Notify(NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(1 - (CurTime() - self.LastJob)))
		return false
	end

	if self.IsBeingDemoted then
		self:TeamBan()
		self.IsBeingDemoted = false
		self:ChangeTeam(1, true)
		GAMEMODE.vote.DestroyVotesWithEnt(self)
		rp.Notify(self, NOTIFY_ERROR, term.Get('EscapeDemotion'))

		return false
	end

	if prevTeam == t then
		rp.Notify(self, NOTIFY_ERROR, term.Get('AlreadyThisJob'))
		return false
	end

	local TEAM = rp.teams[t]
	if not TEAM then return false end

	if TEAM.vip and (not self:IsVIP()) then
		rp.Notify(self, NOTIFY_ERROR, term.Get('NeedVIP'))
		return
	end

	if TEAM.customCheck and not TEAM.customCheck(self) then
		rp.Notify(self, NOTIFY_ERROR, term.Get(TEAM.CustomCheckFailMsg))
		return false
	end

	if not self:GetVar("Priv"..TEAM.command) and not force then
		local max = TEAM.max
		if (max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / player.GetCount() > max))) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLimit'))
			return
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, prevTeam, t)
		if val ~= nil then
			return val
		end
	end

	local hookValue = hook.Call("playerCanChangeTeam", nil, self, t, force)
	if hookValue == false then return false end

	local isMayor = rp.teams[prevTeam] and rp.teams[prevTeam].mayor
	if isMayor then
		if nw.GetGlobal('lockdown') then
			GAMEMODE:UnLockdown(self)
		end
		rp.resetLaws()
	end

	rp.NotifyAll(NOTIFY_GENERIC, term.Get('ChangeJob'), self, (string.match(TEAM.name, '^h?[AaEeIiOoUu]') and 'an' or 'a'), TEAM.name)

	if self:GetNetVar("HasGunlicense") then
		self:SetNetVar("HasGunlicense", nil)
	end

	self:RemoveAllHighs()

	self.PlayerModel = nil

	self.LastJob = CurTime()

	for k, v in ipairs(ents.GetAll()) do
		if (v.ItemOwner == self) and v.RemoveOnJobChange then
			v:Remove()
		end
	end

	if (self:GetNetVar('job') ~= nil) then
		self:SetNetVar('job', nil)
	end

	self:StripWeapons()

	self:SetTeam(t)

	hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
	if self:InVehicle() then self:ExitVehicle() end

	return true
end

function GM:AddTeamCommands(CTeam, max)

	local k = 0
	for num,v in pairs(rp.teams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote then
		rp.AddCommand("vote"..CTeam.command, function(ply)
			if (not ply:CanAfford(rp.cfg.CampaignFee)) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
				return
			end

			-- Force job if he's the only player
			if (player.GetCount() == 1) then
				rp.Notify(ply, NOTIFY_SUCCESS, term.Get('VoteAlone'))
				ply:ChangeTeam(k)
				ply:TakeMoney(rp.cfg.CampaignFee)
				return
			end

			-- Banned from job
			if (!ply:ChangeAllowed(k)) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('BannedFromJob'))
				return
			end

			-- Voted too recently
			if (ply:GetTable().LastVoteTime and CurTime() - ply:GetTable().LastVoteTime < 80) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('VotedTooSoon'), math.ceil(80 - (CurTime() - ply:GetTable().LastVoteTime)))
				return
			end

			-- Can't vote to become what you already are
			if (ply:Team() == k) then
				rp.Notify(ply, NOTIFY_GENERIC, term.Get('AlreadyThisJob'))
				return
			end

			-- Max players reached
			local max = CTeam.max
			if (max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / player.GetCount() > max))) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLimit'))
				return
			end

			if (CTeam.CurVote) then
				if (!CTeam.CurVote.InProgress) then
					table.insert(CTeam.CurVote.Players, ply)
					rp.Notify(ply, NOTIFY_SUCCESS, term.Get('RegisteredForVote'))
				else
					rp.Notify(ply, NOTIFY_ERROR, term.Get('AlreadyVoting'))
					return
				end
			else -- Setup a new vote
				CTeam.CurVote = {
					InProgress = false,
					Players = {ply}
				}

				rp.teamVote.CountDown(CTeam.name, 45, function()
					CTeam.CurVote.InProgress = true

					rp.teamVote.Create(CTeam.name, 45, CTeam.CurVote.Players, function(winner, breakdown)
						if IsValid(winner) then
							winner:ChangeTeam(k)
						end

						CTeam.CurVote = nil
					end)
				end)

				rp.Notify(ply, NOTIFY_SUCCESS, term.Get('RegisteredForVote'))
			end

			ply:TakeMoney(rp.cfg.CampaignFee)

			ply:GetTable().LastVoteTime = CurTime()
			return
		end)
	else
		rp.AddCommand(CTeam.command, function(ply)
			ply:ChangeTeam(k)
		end)
	end
end

function GM:AddEntityCommands(tblEnt)
	local function buythis(ply)
		if ply:IsArrested() then return end

		if (tblEnt.allowed[ply:Team()] ~= true) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('IncorrectJob'))
			return
		end

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotPurchaseItem'))
			return
		end

		local max = tonumber(tblEnt.max or 3)

		if ply:GetCount(tblEnt.ent) >= tonumber(max) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('SboxXLimit'), max, tblEnt.name)
			return
		end

		if not ply:CanAfford(tblEnt.price) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
			return
		end
		ply:AddMoney(-tblEnt.price)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local item = ents.Create(tblEnt.ent)
		item:SetPos(tr.HitPos)
		item.ItemOwner = ply

    if item.Setowning_ent then
      item:Setowning_ent(ply)
    end

		item:Spawn()
		item:PhysWake()

		timer.Simple(0, function()
			if (tblEnt.onSpawn) then tblEnt.onSpawn(item, ply) end
		end)

		ply:_AddCount(tblEnt.ent, item)

		rp.Notify(ply, NOTIFY_SUCCESS, term.Get('RPItemBoughtLimit'), ply:GetCount(tblEnt.ent), max, tblEnt.name, rp.FormatMoney(tblEnt.price))

		hook.Call('PlayerBoughtItem', GAMEMODE, ply, tblEnt.name, tblEnt.price, ply:GetMoney())

		return
	end
	rp.AddCommand(tblEnt.cmd:gsub('/', ''), buythis)
end

local function BuyPistol(ply, args)
	if args == "" then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('InvalidArg'))
		return ""
	end
	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotPurchaseItem'))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local class = nil
	local model = nil

	local shipment
	local price = 0
	for k,v in pairs(rp.shipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) then
			shipment = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false

			if tblEnt.allowed[ply:Team()] then
				canbuy = true
			end

			if v.customCheck and not v.customCheck(ply) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get(v.CustomCheckFailMsg) or term.Get('CannotPurchaseItem'))
				return ""
			end

			if not canbuy then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotPurchaseItem'))
				return ""
			end
		end
	end

	if not class then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('ItemUnavailable'))
		return ""
	end

	if not ply:CanAfford(price) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
		return ""
	end

	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if shipment.onBought then
		shipment.onBought(ply, shipment, weapon)
	end
	hook.Call("playerBoughtPistol", nil, ply, shipment, weapon)

	if IsValid( weapon ) then
		ply:AddMoney(-price)
		rp.Notify(ply, NOTIFY_GREEN, term.Get('RPItemBought'), args, rp.FormatMoney(price))
	else
		rp.Notify(ply, NOTIFY_ERROR, term.Get('UnableToItem'))
	end

	return ""
end
rp.AddCommand("buy", BuyPistol, 0.2)
:AddParam(cmd.STRING)

local function BuyShipment(ply, args)
	if args == "" then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('InvalidArg'))
		return
	end

	if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - 1) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('ShipmentCooldown'))
		return
	end
	ply.LastShipmentSpawn = CurTime()

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotPurchaseItem'))
		return
	end

	local found = false
	local foundKey
	for k,v in pairs(rp.shipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == a then
					canbecome = true
				end
			end

			if v.customCheck and not v.customCheck(ply) then
				rp.Notify(ply, NOTIFY_ERROR, term.Get(v.CustomCheckFailMsg) or term.Get('CannotPurchaseItem'))
				return
			end

			if not canbecome then
				rp.Notify(ply, NOTIFY_ERROR, term.Get('IncorrectJob'))
				return
			end
		end
	end

	if not found then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('ItemUnavailable'))
		return
	end

	local cost = found.price

	if not ply:CanAfford(cost) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	local crate = ents.Create(found.shipmentClass or "spawned_shipment")

	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate:Spawn()
	if found.shipmodel then
		crate:SetModel("models/gmh/shipment/shimpmentcrate.mdl")
	end
	crate:SetContents(foundKey, found.amount)

	if rp.shipments[foundKey].onBought then
		rp.shipments[foundKey].onBought(ply, rp.shipments[foundKey], weapon)
	end
	hook.Call("playerBoughtShipment", nil, ply, rp.shipments[foundKey], weapon)

	if IsValid( crate ) then
		ply:AddMoney(-cost)
		rp.Notify(ply, NOTIFY_GREEN, term.Get('RPItemBought'), args, rp.FormatMoney(cost))

		hook.Call('PlayerBoughtItem', GAMEMODE, ply, rp.shipments[foundKey].name .. ' Shipment', cost, ply:GetMoney())
	else
		rp.Notify(ply, NOTIFY_ERROR, term.Get('UnableToItem'))
	end

	return
end
rp.AddCommand("buyshipment", BuyShipment)
:AddParam(cmd.STRING)


local function BuyAmmo(ply, args)
	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotPurchaseItem'))
		return
	end

	local found
	for k,v in pairs(rp.ammoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found or (found.customCheck and not found.customCheck(ply)) then
		rp.Notify(ply, NOTIFY_ERROR, found and term.Get(found.CustomCheckFailMsg) or term.Get('ItemUnavailable'))
		return
	end

	if not ply:CanAfford(found.price) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	rp.Notify(ply, NOTIFY_GREEN, term.Get('RPItemBought'), found.name, rp.FormatMoney(found.price))
	ply:AddMoney(-found.price)

	ply:GiveAmmo(found.amountGiven, found.ammoType)

end
rp.AddCommand("buyammo", BuyAmmo)
:AddParam(cmd.STRING)
