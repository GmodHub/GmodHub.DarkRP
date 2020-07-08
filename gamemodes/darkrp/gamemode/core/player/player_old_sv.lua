-- TODO, SORT, CLEANUP AND MOVE EVERYTHING IN HERE TO IT'S PROPPER PLACE

function PLAYER:AddHealth(amt)
	self:SetHealth(self:Health() + amt)
end

function PLAYER:GiveAmmos(amount, show)
	for k, v in ipairs(rp.ammoTypes) do
		self:GiveAmmo(amount, v.ammoType, show)
	end
end


/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local previousname = "N/A"
local newname= "N/A"


/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
rp.AddCommand("randomname", function(ply)
	if ply.NextNameChange and ply.NextNameChange > CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('PleaseWaitX'), math.ceil(ply.NextNameChange - CurTime()))
		return ""
	end

	local name = rp.names.Random()
	hook.Call("playerChangedRPName", GAMEMODE, ply, name)
	ply:SetRPName(name)
	ply.NextNameChange = CurTime() + 20
end)

local function RPName(ply, args)
	if ply.NextNameChange and ply.NextNameChange > CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('PleaseWaitX'), math.ceil(ply.NextNameChange - CurTime()))
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 20 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameLong'), 21)
		return ""
	elseif len < 3 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameShort'), 2)
		return ""
	end

	local canChangeName = hook.Call("CanChangeRPName", GAMEMODE, ply, low)
	if canChangeName == false then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotRPName'))
		return ""
	end

	local allowed = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
	'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ',
	'(', ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '*', '-', '_', '=', '+', '|', '\\'}

	for k in string.gmatch(args, ".") do
		if not table.HasValue(allowed, string.lower(k)) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameUnallowed'), k)
			return ""
		end
	end
	hook.Call("playerChangedRPName", GAMEMODE, ply, args)
	ply:SetRPName(args)
	ply.NextNameChange = CurTime() + 20

	return ""
end

rp.AddCommand("rpname", RPName)
:AddParam(cmd.STRING)
:AddAlias 'name'
:AddAlias 'nick'

function PLAYER:SetRPName(name, firstRun)
	name = string.Trim(name)
	name = string.sub(name, 1, 20)

	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	rp.data.GetNameCount(name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		-- If we found that this name exists for another player
		if taken then
			if firstRun then
				-- If we just connected and another player happens to be using our steam name as their RP name
				-- Put a 1 after our steam name
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

hook("PlayerDataLoaded", "RP:RestorePlayerData", function(pl, data)
	pl:NewData()
end)

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
function PLAYER:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

function PLAYER:TeamUnBan(Team)
	if not IsValid(self) then return end
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function PLAYER:TeamBan(t, time)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team()
	self.bannedfrom[t] = 1

	if time == 0 then return end
	timer.Simple(time or 180, function()
		if not IsValid(self) then return end
		self:TeamUnBan(t)
	end)
end

function PLAYER:NewData()
	if not IsValid(self) then return end

	self:SetTeam(1)

	self:GetTable().LastVoteCop = CurTime() - 61
end

/*---------------------------------------------------------
 Teams/jobs
 ---------------------------------------------------------*/
local map = game.GetMap()
local lastpos
local TeamSpawns 	= rp.cfg.TeamSpawns[map]
local JailSpawns 	= rp.cfg.JailPos[map]
local NormalSpawns 	= rp.cfg.SpawnPos[map]

function getspawn(pl, t)
	local pos
	if pl:IsArrested() then
		pos = JailSpawns[math.random(1, #JailSpawns)]
	elseif (TeamSpawns[t] ~= nil) then -- тима
		pos = TeamSpawns[t]
	else
		pos = NormalSpawns[math.random(1, #NormalSpawns)]
		if (pos == lastpos) then
			pos = NormalSpawns[math.random(1, #NormalSpawns)]
		end
		lastpos = pos
		return util.FindEmptyPos(pos)
	end
	return util.FindEmptyPos(pos)
end

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

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
function PLAYER:DropDRPWeapon(weapon)
	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
	self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()
	ent.ammoadd = ammo

	self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

	ent:Spawn()

	weapon:Remove()
end


/*timer.Create('PlayerThink', 5, 0, function()
	local pls = player.GetAll()
	for i = 1, #pls do
		if IsValid(pls[i]) then
			hook.Call('PlayerThink', GAMEMODE, pls[i])
		end
	end
end)*/

hook('PlayerDeath', 'Karma.PlayerDeath', function(victim, inflictor, attacker)
	if attacker:IsPlayer() and (attacker ~= victim) and (not victim:IsBanned()) then
		attacker:AddKarma(-2)
		rp.Notify(attacker, NOTIFY_ERROR, term.Get('LostKarma'), '2', 'убийство')
	end
end)
