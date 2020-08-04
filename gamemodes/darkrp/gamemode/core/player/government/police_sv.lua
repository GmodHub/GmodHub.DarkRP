rp.ArrestedPlayers = rp.ArrestedPlayers or {}

function PLAYER:IsWarranted()
	return (self.HasWarrant == true)
end

function PLAYER:Warrant(actor, reason)
	self.HasWarrant = true
	timer.Simple(rp.cfg.WarrantTime, function()
		if IsValid(self) then
			self:UnWarrant()
			rp.Notify(actor, NOTIFY_GENERIC, term.Get("WarrantExpired"))
		end
	end)
	rp.FlashNotifyAll('Ордер на обыск', term.Get('Warranted'), self, reason, (IsValid(actor) and actor or 'Auto Warrant'))
	hook.Call('PlayerWarranted', GAMEMODE, self, actor, reason)
end

function PLAYER:UnWarrant(actor)
	rp.Notify(self, NOTIFY_GREEN, term.Get('WarrantExpired'))
	self.HasWarrant = nil
	hook.Call('PlayerUnWarranted', GAMEMODE, self, actor)
end


function PLAYER:Wanted(actor, reason, time)
	self.CanEscape = nil
	self:SetNetVar('IsWanted', true)
	self:SetNetVar('WantedInfo', {Reason = reason, Time = (time or rp.cfg.WantedTime) + CurTime()})
	timer.Create('Wanted' .. self:SteamID64(), rp.cfg.WantedTime, 1, function()
		if IsValid(self) then
			self:UnWanted()
		end
	end)
	rp.FlashNotifyAll('Розыск', term.Get('Wanted'), self, reason, (IsValid(actor) and actor or 'Авто Розыск'))
	hook.Call('PlayerWanted', GAMEMODE, self, actor, reason)
end

function PLAYER:UnWanted(actor)
	if self.WantedActor then self.WantedActor = nil end
	self:SetNetVar('IsWanted', nil)
	self:SetNetVar('WantedInfo', nil)
	timer.Destroy('Wanted' .. self:SteamID64())
	hook.Call('PlayerUnWanted', GAMEMODE, self, actor)
end

local jails = rp.cfg.JailPos[game.GetMap()]
function PLAYER:Arrest(actor, reason)
	local time = self:CallSkillHook(SKILL_JAIL)
	timer.Create('Arrested' .. self:SteamID64(), time, 1, function()
		if IsValid(self) then
			self:UnArrest()
		end
	end)

	self:SetNetVar("IsArrested", true)
	self:SetNetVar('ArrestedInfo', {Reason = (reason or self:GetWantedInfo().Reason), ReleaseTime = CurTime() + time})
	if self:IsWanted() then self:UnWanted() end

	self:StripWeapons()
	self:SetHunger(100)
	self:SetHealth(100)
	self:SetArmor(0)

	self:Give("weapon_combo_fists")
	self:SelectWeapon("weapon_combo_fists")
	
	rp.ArrestedPlayers[self:SteamID64()] = true

	rp.FlashNotifyAll('Арест', term.Get('Arrested'), self)
	hook.Call('PlayerArrested', GAMEMODE, self, actor)

	self:SetPos(util.FindEmptyPos(jails[math.random(#jails)]))
	self.CanEscape = true


end

function PLAYER:UnArrest(actor)
	self:SetNetVar('IsArrested', nil)
	self:SetNetVar('ArrestedInfo', nil)
	timer.Destroy('Arrested' .. self:SteamID64())
	rp.ArrestedPlayers[self:SteamID64()] = nil
	timer.Simple(0.3, function() // fucks up otherwise
		local _, pos = GAMEMODE:PlayerSelectSpawn(self)
		self:SetPos(pos)
		self:SetHealth(100)
		self:StripWeapons()
		hook.Call('PlayerLoadout', GAMEMODE, self)
		rp.FlashNotifyAll('Окончание Ареста', term.Get('UnArrested'), self)
		hook.Call('PlayerUnArrested', GAMEMODE, self, actor)
	end)
end


-- Commands
rp.AddCommand('911', function(pl, text)
	if (not text or text == "") then
		if not pl:GetNetVar('911CallReason') then
			pl:Notify(NOTIFY_ERROR, term.Get('Need911Reason'))
		else
			pl:SetNetVar('911CallReason', nil)
			pl:DestroyTimer('911Call')
			pl:Notify(NOTIFY_GENERIC, term.Get('Canceled911'))
		end
		return
	end

	if utf8.len(text) > 60 then
		return
	end

  	chat.Send('911', pl, text)
	pl:SetNetVar('911CallReason', text)
	pl:Timer('911Call', 60, 1, function() pl:SetNetVar('911CallReason', nil) end)
end)
:AddParam(cmd.STRING, cmd.OPT_OPTIONAL)
:SetCooldown(1.5)
:SetChatCommand()

rp.AddCommand('want', function(pl, target, reason)
	if not pl:IsGov() or (pl == target) then return end

	if target:IsGov() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerIsPoliceWant'), target)
		return
	end

	if target:IsWanted() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerAlreadyWanted'), target)
		return
	end

	if target:IsArrested() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerCannotBeWanted'), target)
		return
	end

	if (utf8.len(reason) > 40) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('WantReasonTooLong'))
		return
	end

	target.WantedActor = pl
	target:Wanted(pl, reason)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetCooldown(1.5)

rp.AddCommand('unwant', function(pl, target)
	if not pl:IsGov() or (pl == target) then return end

	if not target:IsWanted() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerNotWanted'), target)
		return
	end

	if target.WantedActor ~= pl and not pl:IsChief() and not pl:IsMayor() then return end

	rp.Notify(pl, NOTIFY_SUCCESS, term.Get('YouUnwanted'), target)
	target:UnWanted(pl)
	rp.FlashNotifyAll('Розыск', term.Get('UnWanted'), self, reason, (IsValid(actor) and actor or 'Авто Розыск'))
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetCooldown(1.5)

rp.AddCommand('warrant', function(pl, target, reason)
	if not pl:IsGov() or (pl == target) then return end

	if target:IsGov() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerIsPoliceWarrant'), target)
		return
	end

	if target:IsWarranted() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerAlreadyWarranted'), target)
		return
	end

	if (utf8.len(reason) > 40) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('WantReasonTooLong'))
		return
	end

	for k, v in pairs(rp.teams) do
		if v.mayor then
			mayors = team.GetPlayers(k)
		end
	end

	if (#mayors > 1) and not pl:IsMayor() then
		rp.question.Create(pl:Name() .. ' запросил ордер на обыск ' .. target:Name() .. ' за ' ..  reason, 40, target:EntIndex() .. 'warrant', function(mayor, answer)
			if IsValid(target) and tobool(answer) then
				rp.Notify(pl, NOTIFY_GREEN, term.Get('WarrantRequestAcc'))
				target:Warrant(pl, reason)
			else
				rp.Notify(pl, NOTIFY_ERROR, term.Get('WarrantRequestDen'))
			end
		end, mayors[1])
	else
		target:Warrant(pl, reason)
		rp.Notify(pl, NOTIFY_GREEN, term.Get('WarrantRequestAcc'))
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetCooldown(1.5)

rp.AddCommand('unwarrant', function(pl, target)
	if not pl:IsGov() or (pl == target) then return end

	if not targ:IsWarranted() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerNotWarranted'), target)
	else
		target:UnWarrant(pl)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetCooldown(1.5)


local bounds = rp.cfg.Jails[game.GetMap()]
if bounds then
hook('PlayerThink', function(pl)
		if IsValid(pl) and pl:IsArrested() and pl.CanEscape and (not pl:InBox(bounds[1], bounds[2])) then
			rp.ArrestedPlayers[pl:SteamID64()] = nil
			pl:SetNetVar('IsArrested', nil)
			pl:SetNetVar('ArrestedInfo', nil)
			timer.Destroy('Arrested' .. pl:SteamID64())

			pl:Wanted(nil, 'Побег из Тюрьмы')

			pl:StripWeapons()
			hook.Call('PlayerLoadout', GAMEMODE, pl)
		end
	end)
end

hook('PlayerEntityCreated', function(pl)
	if pl:IsArrested() then
		pl:Arrest(nil, 'Disconnecting to avoid arrest')
	end
end)

hook('PlayerDeath', function(pl, killer, dmginfo)
	if (!killer:IsPlayer()) then return end

	if pl:IsWanted() and killer:IsCP() and (pl ~= killer) and (killer ~= game.GetWorld()) then
		pl:UnWanted()
	end
end)
