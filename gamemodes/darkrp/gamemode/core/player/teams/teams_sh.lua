if CLIENT then
	PLAYER._Team = PLAYER._Team or PLAYER.Team

	function PLAYER:Team()
		local t = self:_Team()
		return (t == 0) and 1 or t
	end
end

function team.GetModel(t)
	if not t then t = 1 end
	return (istable(rp.teams[t].model) and rp.teams[t].model[math.random(1, #rp.teams[t].model)] or rp.teams[t].model)
end

function PLAYER:GetTeamTable()
	return rp.teams[self:Team()] or rp.teams[1]
end

function PLAYER:GetJobTable()
	return rp.teams[self:GetJob()]
end

function PLAYER:CallTeamHook(hook, ...)
	if rp.teams[self:Team()] and rp.teams[self:Team()][hook] then
		return rp.teams[self:Team()][hook](...)
	end
end

function PLAYER:IsDisguised()
	return (self:GetNetVar('DisguiseTeam') ~= nil)
end

function PLAYER:IsHired()
	return (self:GetNetVar('Employer') ~= nil)
end

function PLAYER:IsHirable()
	return self:GetTeamTable().hirable and (not self:IsHired()) and (not self:IsDisguised())
end

function PLAYER:GetHirePrice()
	return (self:GetNetVar('EmployeePrice') or self:GetTeamTable().hirePrice or 0)
end

function PLAYER:GetJob()
	return (self:IsDisguised() and self:GetNetVar('DisguiseTeam') or self:Team())
end

function PLAYER:GetTeamName()
	return team.GetName(self:Team())
end

function PLAYER:GetJobName()
	if self:IsDisguised() then
		return team.GetName(self:GetNetVar('DisguiseTeam'))
	end

	local name = (self:GetNetVar('job') or team.GetName(self:Team()))

	if self:IsHirable() or self:IsHired() then
		if self:IsHired() and IsValid(self:GetNetVar('Employer')) then
			return self:GetNetVar('Employer'):Name() .. '\'s ' .. name
		else
			return name .. ' (' .. rp.FormatMoney(self:GetHirePrice()) .. ')'
		end
	end
	return name
end

function PLAYER:GetTeamColor()
	return team.GetColor(self:Team())
end

function PLAYER:GetJobColor()
	return team.GetColor(self:GetNetVar('DisguiseTeam') or self:Team())
end

function PLAYER:IsAgendaManager()
	return (rp.agendas[self:Team()] and (rp.agendas[self:Team()].manager == self:Team()) or false)
end

function PLAYER:IsHitman()
	return (rp.teams[self:Team()].hitman == true)
end

function PLAYER:IsHobo()
	return (rp.teams[self:Team()].hobo == true)
end


if (CLIENT) then
	CreateConVar("cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255")
	CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255")
	CreateConVar("cl_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any")
	CreateConVar("cl_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any")
end

-- player class
player_manager.RegisterClass('rp_player', {
	DisplayName = 'RP Player Class',

	GetHandsModel = function(self)
		local name = player_manager.TranslateToPlayerModelName(self.Player:GetModel())
		return player_manager.TranslatePlayerHands(name)
	end,

	Spawn = function(self)
		if (self.Player:CallTeamHook('CanChangePlayerColor') ~= false) then
			local col = self.Player:GetInfo('cl_playercolor')
			self.Player:SetPlayerColor(Vector(col))
		end

		local col = self.Player:GetInfo('cl_weaponcolor')
		self.Player:SetWeaponColor(Vector(col))
	end,

	SetModel = function(self)
		local cl_playermodel = self.Player:GetInfo('cl_playermodel')
		self.Player:SetModel(player_manager.TranslatePlayerModel(cl_playermodel))
	end,

	TauntCam = TauntCamera(),

	CalcView = function(self, view)
		if (self.TauntCam:CalcView(view, self.Player, self.Player:IsPlayingTaunt())) then
			return true
		end
	end,

	CreateMove = function(self, cmd)
		if (self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt())) then
			return true
		end
	end,

	ShouldDrawLocal = function(self)
		if (self.TauntCam:ShouldDrawLocalPlayer(self.Player, self.Player:IsPlayingTaunt())) then
			return true
		end
	end,

	JumpPower = 300,
	DuckSpeed = 0.5,
	WalkSpeed = 200,
	RunSpeed = 350
}, 'player_default')