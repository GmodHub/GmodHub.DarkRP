util.AddNetworkString('PlayerDisguise')

hook("PlayerDataLoaded", "RP:RestorePlayerData", function(pl, data)
	pl:NewData()
end)

function PLAYER:NewData()
	if not IsValid(self) then return end

	self:SetTeam(1)

	self:GetTable().LastVoteCop = CurTime() - 61
end


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

function PLAYER:Disguise(t, time)
	if not self:Alive() then return end
	self:SetNetVar('DisguiseTeam', t)

	if self:GetNetVar('job') then
		self:SetNetVar('job', nil)
	end

	self:SetModel(team.GetModel(t))

	rp.Notify(self, NOTIFY_SUCCESS, term.Get('NowDisguised'), rp.teams[t].name)

	hook.Call('playerDisguised', GAMEMODE, self, self:Team(), t)
end

function PLAYER:UnDisguise()
	self:SetNetVar('DisguiseTeam', nil)
end

function PLAYER:HirePlayer(pl)
	if pl:GetNetVar('job') then
		pl:SetNetVar('job', nil)
	end
	pl:SetNetVar('Employer', self)
	self:SetNetVar('Employee', pl)

	self:TakeMoney(pl:GetHirePrice())
	pl:AddMoney(pl:GetHirePrice())

	hook.Call('PlayerHirePlayer', GAMEMODE, self, pl)
end

hook('OnPlayerChangedTeam', 'Disguise.OnPlayerChangedTeam', function(pl, prevTeam, t)
	if pl:IsDisguised() then
		pl:UnDisguise()
	end

	if (pl:GetNetVar('Employer') ~= nil) then
		rp.Notify(pl:GetNetVar('Employer'), NOTIFY_ERROR, rp.Term('EmployeeChangedJob'))
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('EmployeeChangedJobYou'))

		pl:GetNetVar('Employer'):SetNetVar('Employee', nil)
		pl:SetNetVar('Employer', nil)

	end
end)

hook('PlayerDeath', 'teams.PlayerDeath', function(pl)
	if pl:IsDisguised() then
		pl:UnDisguise()
	end

	if (pl:GetNetVar('Employer') ~= nil) then
		rp.Notify(pl:GetNetVar('Employer'), NOTIFY_ERROR, rp.Term('EmployeeDied'))
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('EmployeeDiedYou'))

		pl:GetNetVar('Employer'):SetNetVar('Employee', nil)
		pl:SetNetVar('Employer', nil)

	elseif (pl:GetNetVar('Employee') ~= nil) then
		rp.Notify(pl:GetNetVar('Employee'), NOTIFY_ERROR, rp.Term('EmployerDied'))
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('EmployerDiedYou'))

		pl:GetNetVar('Employee'):SetNetVar('Employer', nil)
		pl:SetNetVar('Employee', nil)
	end
end)

hook('PlayerDisconnected', 'employees.PlayerDisconnected', function(pl)
	if (pl:GetNetVar('Employer') ~= nil) then
		rp.Notify(pl:GetNetVar('Employer'), NOTIFY_ERROR, rp.Term('EmployeeLeft'))

		pl:GetNetVar('Employer'):SetNetVar('Employee', nil)
	elseif (pl:GetNetVar('Employee') ~= nil) then
		rp.Notify(pl:GetNetVar('Employee'), NOTIFY_ERROR, rp.Term('EmployerLeft'))

		pl:GetNetVar('Employee'):SetNetVar('Employer', nil)
	end
end)

--
-- Commands
--
rp.AddCommand('model', function(pl, args)
	pl:SetVar('Model', string.lower(args[1]))
end)
:AddParam(cmd.NUMBER)

rp.AddCommand("playercolor", function(pl, vec1, vec2, vec3)
	if (pl:CallTeamHook('CanChangePlayerColor') ~= false) then
		pl:SetPlayerColor(Vector(vec1, vec2, vec3))
	end
end)
:AddParam(cmd.NUMBER)
:AddParam(cmd.NUMBER)
:AddParam(cmd.NUMBER)

rp.AddCommand("physcolor", function(pl, vec1, vec2, vec3)
	pl:SetWeaponColor(Vector(vec1, vec2, vec3))
end)
:AddParam(cmd.NUMBER)
:AddParam(cmd.NUMBER)
:AddParam(cmd.NUMBER)

rp.AddCommand('undisguise', function(pl)

	if pl:IsDisguised() then
		pl:UnDisguise()
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get("DisguiseWorn"))
		pl.nextDisguise = CurTime() + rp.cfg.DisguiseCooldown
	end

end)

rp.AddCommand('hire', function(pl, text, args)
	local targ = pl:GetEyeTrace().Entity
	if not IsValid(targ) or not targ:IsPlayer() or (pl:EyePos():DistToSqr(targ:EyePos()) > 13225) then return end

	if not targ:IsHirable() then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('PlayerNotHirable'), targ)
		return
	end

	if pl:IsHirable() then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('EmployeeTriedEmploying'))
		return
	end

	if (pl:GetNetVar('Employee') ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('HasEmployee'))
		return
	end

	if (pl:GetNetVar('Employer') ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('AlreadyEmployed'))
		return
	end

	if (not pl:CanAfford(targ:GetHirePrice())) then
		rp.Notify(pl, NOTIFY_ERROR, rp.Term('CannotAffordEmployee'))
		return
	end

	rp.Notify(pl, NOTIFY_GENERIC, rp.Term('EmployRequestSent'), targ)
	GAMEMODE.ques:Create('Would you like ' .. pl:Name() .. ' to hire you for ' .. rp.FormatMoney(targ:GetHirePrice()) .. '?', "hire" .. pl:UserID(), targ, 30, function(answer)
		if (tobool(answer) == true) and IsValid(pl) then
			rp.Notify(pl, NOTIFY_GREEN, rp.Term('YouHired'), targ, rp.FormatMoney(targ:GetHirePrice()))
			rp.Notify(targ, NOTIFY_GREEN, rp.Term('YouAreHired'), pl, rp.FormatMoney(targ:GetHirePrice()))
			pl:HirePlayer(targ)
		else
			rp.Notify(pl, NOTIFY_ERROR, rp.Term('EmployRequestDen'), targ)
		end
	end)
end)
:AddParam(cmd.PLAYER)

rp.AddCommand('fire', function(pl, text, args)
	local targ = rp.FindPlayer(args[1])
	if not IsValid(targ) or not (targ:GetNetVar('Employer') == pl) then return end

	rp.Notify(pl, NOTIFY_GREEN, rp.Term('EmployeeFired'), targ)
	rp.Notify(targ, NOTIFY_ERROR, rp.Term('EmployeeFiredYou'), pl)

	targ:SetNetVar('Employer', nil)
	pl:SetNetVar('Employee', nil)
end)
:AddParam(cmd.PLAYER)

rp.AddCommand('quitjob', function(pl, text, args)
	if not IsValid(pl:GetNetVar('Employer')) then return end

	rp.Notify(pl, NOTIFY_GREEN, rp.Term('EmployeeQuitYou'), pl:GetNetVar('Employer'))
	rp.Notify(pl:GetNetVar('Employer'), NOTIFY_ERROR, rp.Term('EmployeeQuet'), pl)

	pl:GetNetVar('Employer'):SetNetVar('Employee', nil)
	pl:SetNetVar('Employer', nil)
end)

rp.AddCommand('agenda', function(pl, text, args)
	if rp.agendas[pl:Team()] and (rp.agendas[pl:Team()].manager == pl:Team()) then
		nw.SetGlobal('Agenda;' .. pl:Team(), text)
	else
		rp.Notify(pl, NOTIFY_ERROR, term.Get('IncorrectJob'))
	end
	return
end)

local function ChangeJob(ply, args)
	if args == "" then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('InvalidArg'))
		return
	end

	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(10 - (CurTime() - ply.LastJob)))
		return
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return
	end

	local len = string.len(args)

	if len < 3 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLenShort'), 2)
		return
	end

	if len > 25 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLenLong'), 26)
		return
	end

	local canChangeJob, message, replace = hook.Call("canChangeJob", nil, ply, args)
	if canChangeJob == false then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return ""
	end

	local job = replace or args
	rp.NotifyAll(NOTIFY_GENERIC, term.Get('ChangeJob'), ply, (string.match(job, '^h?[AaEeIiOoUu]') and 'an' or 'a'), job)

	ply:SetNetVar('job', job)
	return
end
rp.AddCommand("job", ChangeJob)
:AddParam(cmd.STRING)


local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(rp.DefaultTeam, true)
		else
			target.demotedWhileDead = true
		end

		rp.NotifyAll(NOTIFY_GENERIC, term.Get('PlayerDemoted'), target)
	else
		rp.NotifyAll(NOTIFY_GENERIC, term.Get('PlayerNotDemoted'), target)
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('DemotionReason'))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('DemoteReasonLong'), 100)
		return ""
	end
	local p = rp.FindPlayer(tableargs[1])
	if p == ply then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('DemoteSelf'))
		return ""
	end

	local canDemote, message = hook.Call("CanDemote", GAMEMODE, ply, p, reason)
	if canDemote == false then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('UnableToDemote'))
		return ""
	end

	if p then
		if ply:GetTable().LastVoteCop and CurTime() - ply:GetTable().LastVoteCop < 80 then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('NeedToWait'),  math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)))
			return ""
		end
		if not rp.teams[p:Team()] or rp.teams[p:Team()].candemote == false then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('UnableToDemote'))
		else
			rp.Chat(CHAT_NONE, p, colors.Yellow, '[DEMOTE] ', ply, 'I want to demote you. Reason: ' .. reason)

			rp.NotifyAll(NOTIFY_GENERIC, term.Get('DemotionStarted'), ply, p)
			p.IsBeingDemoted = true

			hook.Call('playerDemotePlayer', GAMEMODE, ply, p, reason)

			GAMEMODE.vote:create(p:Nick() .. ":\nDemotion nominee:\n"..reason, "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CantFindPlayer'), tostring(args))
		return ""
	end
end
rp.AddCommand("demote", Demote)
:AddParam(cmd.PLAYER)

/*timer.Create('PlayerThink', 5, 0, function()
	local pls = player.GetAll()
	for i = 1, #pls do
		if IsValid(pls[i]) then
			hook.Call('PlayerThink', GAMEMODE, pls[i])
		end
	end
end)*/
