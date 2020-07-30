util.AddNetworkString('PlayerDisguise')

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
rp.AddCommand('agenda', function(pl, text)
	local agenda = rp.agendas[pl:Team()]

	if not agenda or (agenda.manager ~= pl:Team()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('IncorrectJob'))
		return
	end

	if utf8.len(text) >= 260 then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('AgendaTooLong'))
		return
	end

	if agenda and (agenda.manager == pl:Team()) then
		nw.SetGlobal('Agenda;' .. agenda.manager, text)
	end

end)
:AddParam(cmd.STRING)

rp.AddCommand('undisguise', function(pl)
	if pl:IsDisguised() then
		pl:UnDisguise()
		rp.Notify(pl, NOTIFY_SUCCESS, term.Get("DisguiseWorn"))
		pl.nextDisguise = CurTime() + rp.cfg.DisguiseCooldown
	end
end)

rp.AddCommand('hire', function(pl, targ, price)
	if not IsValid(targ) or not isplayer(targ) then return end

	if not targ:IsHirable() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerNotHirable'), targ)
		return
	end

	if pl:IsHirable() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('EmployeeTriedEmploying'))
		return
	end

	if (pl:GetNetVar('Employee') ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('HasEmployee'))
		return
	end

	if (pl:GetNetVar('Employer') ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('AlreadyEmployed'))
		return
	end

	if (not pl:CanAfford(targ:GetHirePrice())) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAffordEmployee'))
		return
	end

	rp.Notify(pl, NOTIFY_GENERIC, term.Get('EmployRequestSent'), targ)
	rp.question.Create('Вы хотите работать на ' .. pl:Name() .. ' за ' .. rp.FormatMoney(targ:GetHirePrice()) .. '?', 15, "hire" .. pl:UserID(), function(targ, answer)
		if (tobool(answer) == true) and IsValid(pl) then
			rp.Notify(pl, NOTIFY_GREEN, term.Get('YouHired'), targ, rp.FormatMoney(targ:GetHirePrice()))
			rp.Notify(targ, NOTIFY_GREEN, term.Get('YouAreHired'), pl, rp.FormatMoney(targ:GetHirePrice()))
			pl:HirePlayer(targ)
		else
			rp.Notify(pl, NOTIFY_ERROR, term.Get('EmployRequestDen'), targ)
		end
	end, false, targ)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)

rp.AddCommand('fire', function(pl, targ)
	if not IsValid(targ) or not (targ:GetNetVar('Employer') == pl) then return end

	rp.Notify(pl, NOTIFY_GREEN, term.Get('EmployeeFired'), targ)
	rp.Notify(targ, NOTIFY_ERROR, rp.Term('EmployeeFiredYou'), pl)

	targ:SetNetVar('Employer', nil)
	pl:SetNetVar('Employee', nil)
end)
:AddParam(cmd.PLAYER_ENTITY)

rp.AddCommand('quitjob', function(pl)
	if not IsValid(pl:GetNetVar('Employer')) then return end

	rp.Notify(pl, NOTIFY_GREEN, rp.Term('EmployeeQuitYou'), pl:GetNetVar('Employer'))
	rp.Notify(pl:GetNetVar('Employer'), NOTIFY_ERROR, rp.Term('EmployeeQuet'), pl)

	pl:GetNetVar('Employer'):SetNetVar('Employee', nil)
	pl:SetNetVar('Employer', nil)
end)

local function FinishDemote(ply, choice)
	ply.IsBeingDemoted = nil
	if(choice >= math.ceil(player.GetCount() * 0.1)) then
		ply:TeamBan()
		if ply:Alive() then
			ply:ChangeTeam(1, true)
		else
			ply.demotedWhileDead = true
		end
		rp.NotifyAll(NOTIFY_GENERIC, term.Get('PlayerDemoted'), ply)
	else
		rp.NotifyAll(NOTIFY_GENERIC, term.Get('PlayerNotDemoted'), ply)
	end
end

--
-- (Player ply) Who's demoting
-- (Player p) Who to demote
-- (String reason) Reason for demotion
--
function PLAYER:StartDemotionVote(ply, reason)
	rp.NotifyAll(NOTIFY_GENERIC, term.Get('DemotionStarted'), ply, self)
	p.IsBeingDemoted = true

	rp.question.Create("Понизить: " .. self:Nick() .. "?\nПричина: " .. reason, 30,'demote.' .. self:SteamID(), function(voter, answer, uid)

		if(not rp.question.Votes[uid] or not istable(rp.question.Votes[uid])) then
			rp.question.Votes[uid] = {
				VoteRes = 0,
				Func = FinishDemote,
				Ply = p
			}
		end

		if(answer) then
			rp.question.Votes[uid].VoteRes = rp.question.Votes[uid].VoteRes + 1
		else
			rp.question.Votes[uid].VoteRes = rp.question.Votes[uid].VoteRes - 1
		end
	end, true, player.GetAll())
end

rp.AddCommand("demote", function(ply, p, reason)
	if utf8.len(reason) > 40 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('DemoteReasonLong'), 100)
		return
	end

	if p == ply then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('DemoteSelf'))
		return
	end

	if rp.teams[ply:Team()].CanInstantDemote and rp.teams[ply:Team()].CanInstantDemote(ply, p) then
		FinishDemote(p, 1)
		return
	end

	if p then
		if ply:GetTable().LastVoteCop and CurTime() - ply:GetTable().LastVoteCop < 80 then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('NeedToWait'),  math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)))
			return
		end
		if (not rp.teams[p:Team()] or rp.teams[p:Team()].candemote == false) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('UnableToDemote'))
		else
			hook.Call('playerDemotePlayer', GAMEMODE, ply, p, reason)
			ply:GetTable().LastVoteCop = CurTime()

			p:StartDemotionVote(ply, reason)
		end
		return
	else
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CantFindPlayer'), tostring(args))
		return
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)

timer.Create('PlayerThink', 5, 0, function()
	local pls = player.GetAll()
	for i = 1, #pls do
		if IsValid(pls[i]) then
			hook.Call('PlayerThink', GAMEMODE, pls[i])
		end
	end
end)
