util.AddNetworkString('PlayerDisguise')

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

rp.AddCommand('undisguise', function(pl, text, args)

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
