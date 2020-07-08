term.Add('EntityNoOwner', 'This entity has no owner.')
term.Add('CannotUnown', 'You cannot unown this property.')
term.Add('EntityOwnedBy', '# owns this #.')
term.Add('AdminUnownedYourDoor', '# force unowned your property.')
term.Add('AdminUnownedPlayerDoor', '# force unowned #\'s property.')
term.Add('AdminChangedYourJob', '# has force changed your job to #.')
term.Add('AdminChangedPlayerJob', '# has force changed #\'s job to #.')
term.Add('JobNotFound', 'Job # not found!')
term.Add('AdminUnwantedYou', '# has force unwanted you.')
term.Add('AdminUnwantedPlayer', '# has force unwanted #.')
term.Add('PlayerNotWanted', '# is not wanted!')
term.Add('AdminUnarrestedYou', '# has force unarrested you.')
term.Add('AdminUnarrestedPlayer', '# has force unarrested #.')
term.Add('PlayerNotArrested', '# is not arrested!')
term.Add('AdminArrestedPlayer', '# has force arrested # for #.')
term.Add('PlayerArrested', '# is already arrested!')
term.Add('ArrestTooLong', 'You cannot force arrest someone for longer than #')
term.Add('AdminArrestedYou', '# has force arrested you.')
term.Add('AdminUnwarrantedYou', '# has force unwarranted you.')
term.Add('AdminUnwarrantedPlayer', '# has force unwarranted #.')
term.Add('PlayerNotWarranted', '# is not warranted!')
term.Add('EventInvalid', '# is not a valid event!')
term.Add('AdminStartedEvent', '# has started a # event for #.')
term.Add('AdminFrozePlayersProps', '# has frozen #\'s props.')
term.Add('AdminFrozeAllProps', '# has frozen all props.')
term.Add('PlayerVoteInvalid', 'No vote for # exists!')
term.Add('AdminDeniedVote', '# has denied #\'s vote.')
term.Add('AdminDeniedTeamVote', '# has denied the # vote.')
term.Add('AdminAddedYourMoney', '# has added $# to your wallet.')
term.Add('AdminAddedMoney', 'You have added $# to #\'s wallet.')
term.Add('AdminAddedYourCredits', '# has added # credits to your account.')
term.Add('AdminAddedCredits', 'You have added # credits to #\'s account.')
term.Add('AdminMovedPlayers', 'Moved # players to the other server.')
term.Add('PlayerNotFound', 'Couldn\'t find player #.')
term.Add('AdminSetHealth', '# has set #\'s health to #.')
term.Add('AdminSetYourHealth', '# has set your health to #.')
term.Add('AdminSetArmor', '# has set #\'s armor to #.')
term.Add('AdminSetYourArmor', '# has set your armor to #.')
term.Add('AdminSetSpeed', '# has set #\'s run speed to #.')
term.Add('AdminSetYourSpeed', '# has set your run speed to #.')
term.Add('AdminSetWalkSpeed', '# has set #\'s run walk to #.')
term.Add('AdminSetYourWalkSpeed', '# has set your walk speed to #.')
term.Add('AdminSetJump', '# has set #\'s jump power to #.')
term.Add('AdminSetYourJump', '# has set your jump power to #.')
term.Add('WepDoesNoDmg', '#\'s weapon does no damage or is invalid.')
term.Add('AdminSetWepDmg', '# has set #\'s # to # damage.')
term.Add('AdminSetYourWepDMG', '# has set your # to # damage.')
term.Add('EventDoorNotSet', 'This map has no event door!')
term.Add('EventDoorActivity', '# has # the event door!')
term.Add('AdminStartedEventVote', '# has begun voting for an event.')
term.Add('AdminToggledNametag', '# has # #\'s nametag.')
term.Add('AdminToggledYourNametag', '# has # your nametag.')
term.Add('AdminResetNametags', '# has unhidden all nametags.')
term.Add('NoHiddenNametags', 'No players have hidden nametags.')
term.Add('AdminScaledPlayer', '# has scaled #\'s size to #%.')
term.Add('AdminScaledYou', '# has scaled your size to #%.') -- please kys king, this is cancer.
term.Add('ToggleNPCNoTarget', 'NPC no target is # for #')
term.Add('PlayerIsWatcherBanned', '# is blacklisted from becoming a Sit Watcher.')
term.Add('PlayerIsNotWatcherBanned', '# is not blacklisted from becoming a Sit Watcher.')
term.Add('PlayerIsAlreadyWatcherBanned', '# is already blacklisted from becoming a Sit Watcher.')
term.Add('AdminWatcherBanned', '# has blacklisted # from becoming a Sit Watcher.')
term.Add('AdminWatcherUnbanned', '# has unblacklisted # from becoming a Sit Watcher.')
term.Add('AdminWatcherBannedYou', '# has blacklisted you from becoming a Sit Watcher.')
term.Add('AdminWatcherUnbannedYou', '# has unblacklisted you from becoming a Sit Watcher.')

ba.AddCommand('Go', function(pl)
	local ent = pl:GetEyeTrace().Entity
	local owner = ent:CPPIGetOwner() or ent.ItemOwner
	if IsValid(ent) and IsValid(owner) then
		ba.notify(pl, term.Get('EntityOwnedBy'), pl:IsAdmin() and owner or owner:NameID(), (ent.PrintName and (ent.PrintName ~= '')) and ent.PrintName or ent:GetClass())
	else
		ba.notify_err(pl, term.Get('EntityNoOwner'))
	end
end)
:SetHelp 'Shows the owner of a prop'

ba.AddCommand('Unown', function(pl)
	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:IsPropertyOwned() then
		ba.notify(ent:GetPropertyOwner(), term.Get('AdminUnownedYourDoor'), pl)
		ba.notify_staff(term.Get('AdminUnownedPlayerDoor'), pl, ent:GetPropertyOwner())
		ent:GetPropertyOwner():SellProperty(true, false)
	else
		ba.notify_err(pl, term.Get('CannotUnown'))
	end
end)
:SetFlag 'M'
:SetHelp 'Force unowns a property'

local function searchJobs(name)
	name = name:lower()

	local jobs = table.FilterCopy(rp.teams, function(v)
		return string.find(v.name:lower(), name)
	end)

	local job = jobs[1]
	for k, v in ipairs(jobs) do
		if (v.name:lower() == name) then
			job = v
			break
		end
	end

	return job
end


ba.AddCommand('Setjob', function(pl, target, name)
	local job = searchJobs(name)

	if job then
		ba.notify(target, term.Get('AdminChangedYourJob'), pl, job.name)
		ba.notify_staff(term.Get('AdminChangedPlayerJob'), pl, target, job.name)
		if (not target:Alive()) then
			target:Spawn()
		end
		target.JobBeingForced = true
		target:ChangeTeam(job.team, true)
		target:Spawn()
		target.JobBeingForced = nil
		return
	end

	return ba.NOTIFY_ERROR, term.Get('JobNotFound'), name
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)
:SetFlag 'A'
:SetHelp 'Forces a players job'

ba.AddCommand('SitWatcher', function(pl, target)
	local sid64 = target:SteamID64()

	rp._Cache:Get('WatcherBans:' .. sid64, function(redis, val)
		if (tobool(val)) then
			ba.notify(pl, term.Get('PlayerIsWatcherBanned'), target)
			return
		end

		ba.notify(target, term.Get('AdminChangedYourJob'), pl, 'Sit Watcher')
		ba.notify_staff(term.Get('AdminChangedPlayerJob'), pl, target, 'Sit Watcher')

		if (not target:Alive()) then
			target:Spawn()
		end

		target.JobBeingForced = true
		target.CalledFromSitwatcherCommand = true
		target:ChangeTeam(TEAM_WATCHER, true)
		target:Spawn()
		target.CalledFromSitwatcherCommand = nil
		target.JobBeingForced = nil
	end)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Sets a player to the Sit Watcher role'

ba.AddCommand('WatcherBan', function(pl, sid32)
	local target
	local sid64

	if (isplayer(sid32)) then
		target = sid32
		sid32 = target:SteamID()
		sid64 = target:SteamID64()
	else
		sid64 = ba.InfoTo64(sid32)
	end

	rp._Cache:Get('WatcherBans:' .. sid64, function(redis, val)
		if (tobool(val)) then
			ba.notify(pl, term.Get('PlayerIsAlreadyWatcherBanned'), (target or sid32))
			return
		end

		rp._Cache:Set('WatcherBans:' .. sid64, true)

		if (target) then
			ba.notify(target, term.Get('AdminWatcherBannedYou'), pl)

			if (not target:Alive()) then
				target:Spawn()
			end

			target.JobBeingForced = true
			target.CalledFromSitwatcherCommand = tru
			target:ChangeTeam(TEAM_CITIZEN, true)
			target:Spawn()
			target.JobBeingForced = nil
		end

		ba.notify_staff(term.Get('AdminWatcherBanned'), pl, (target or sid32))
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetFlag 'S'
:SetHelp 'Blacklists a player from becoming a Sit Watcher'

ba.AddCommand('WatcherUnban', function(pl, sid32)
	local target
	local sid64

	if (isplayer(sid32)) then
		target = sid32
		sid32 = target:SteamID()
		sid64 = target:SteamID64()
	else
		sid64 = ba.InfoTo64(sid32)
	end

	rp._Cache:Get('WatcherBans:' .. sid64, function(redis, val)
		if (!tobool(val)) then
			ba.notify(pl, term.Get('PlayerIsNotWatcherBanned'), (target or sid32))
			return
		end

		rp._Cache:Delete('WatcherBans:' .. sid64)

		if (target) then
			ba.notify(target, term.Get('AdminWatcherUnbannedYou'), pl)
		end

		ba.notify_staff(term.Get('AdminWatcherUnbanned'), pl, (target or sid32))
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetFlag 'S'
:SetHelp 'Removes a player from the Sit Watcher blacklist'

ba.AddCommand('Force Unwant', function(pl, target)
	if target:IsWanted() then
		ba.notify(target, term.Get('AdminUnwantedYou'), pl)
		ba.notify_staff(term.Get('AdminUnwantedPlayer'), pl, target)
		target:UnWanted(pl, false)
	else
		return ba.NOTIFY_ERROR, term.Get('PlayerNotWanted'), target
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Force unwants a player'
:AddAlias 'funwant'

ba.AddCommand('Force Arrest', function(pl, target, time)
	if time and (time > rp.cfg.ArrestTime) then
		return ba.NOTIFY_ERROR, term.Get('ArrestTooLong'), string.FormatTime(rp.cfg.ArrestTime)
	end

	if (not target:IsArrested()) then
		target:Arrest(nil, 'Staff Force Arrest', time)
		ba.notify(target, term.Get('AdminArrestedYou'), pl)
		ba.notify_staff(term.Get('AdminArrestedPlayer'), pl, target, string.FormatTime(time))
	else
		return ba.NOTIFY_ERROR, term.Get('PlayerArrested'), target
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.TIME)
:SetFlag 'M'
:SetHelp 'Force arrests a player'
:AddAlias 'farrest'

ba.AddCommand('Force Unarrest', function(pl, target)
	if target:IsArrested() then
		ba.notify(target, term.Get('AdminUnarrestedYou'), pl)
		ba.notify_staff(term.Get('AdminUnarrestedPlayer'), pl, target)
		target:UnArrest(pl, false)
	else
		return ba.NOTIFY_ERROR, term.Get('PlayerNotArrested'), target
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Force unarrests a player'
:AddAlias 'funarrest'

ba.AddCommand('Force UnWarrant', function(pl, target)
	if target:IsWarranted() then
		ba.notify(target, term.Get('AdminUnwarrantedYou'), pl)
		ba.notify_staff(term.Get('AdminUnwarrantedPlayer'), pl, target)
		target:UnWarrant(pl)
	else
		return ba.NOTIFY_ERROR, term.Get('PlayerNotWarranted'), target
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Force unwants a player'
:AddAlias 'funwarrant'

ba.AddCommand('Start Event', function(pl, event, time)
	event = string.lower(event)
	if (rp.Events[event] == nil) then
		return ba.NOTIFY_ERROR, term.Get('EventInvalid'), event
	else
		rp.StartEvent(event, time)
		ba.notify_all(term.Get('AdminStartedEvent'), pl, event, string.FormatTime(time))
	end
end)
:AddParam(cmd.STRING)
:AddParam(cmd.TIME)
:SetFlag 'G'
:SetHelp 'Starts an event'

ba.AddCommand('Event Door', function(pl, openOrClose)
	if (rp.cfg.EventDoorEnt) then
		openOrClose = openOrClose:lower()
		doOpen = openOrClose[1] == 'o'

		if (rp.cfg.EventDoorEnt:GetClass() == 'prop_dynamic') then
			rp.cfg.EventDoorEnt:Fire('SetAnimation', doOpen and 'open' or 'close')
		else
			rp.cfg.EventDoorEnt:Fire(doOpen and 'Open' or 'Close', 0, 0)
		end

		ba.notify_all(term.Get('EventDoorActivity'), pl, doOpen and 'opened' or 'closed')
	else
		return ba.NOTIFY_ERROR, term.Get('EventDoorNotSet')
	end
end)
:AddParam(cmd.STRING)
:SetFlag 'D'
:SetHelp 'Opens or closes the event door'

ba.AddCommand('Event Vote', function(pl, job)
	local t
	if job then
		t = searchJobs(job)

		if (not t) then
			return ba.NOTIFY_ERROR, term.Get('JobNotFound'), job
		end
	end

	local pos = pl:GetEyeTrace().HitPos

	rp.question.Create('Do you want to participate in an event?' .. (t and ' WARNING: Your job will be changed.' or ''), 30, 'event', function(pl, answer)
		if (answer) then
			if t and (pl:Team() ~= t.team) then
				pl:ChangeTeam(t.team, true)
			end

			pl:SetPos(util.FindEmptyPos(pos))
		end
	end, nil, table.Filter(player.GetAll(), function(v) return !v:IsArrested() and !v:IsJailed() and v != pl end))

	ba.notify_all(term.Get('AdminStartedEventVote'), pl)
end)
:AddParam(cmd.STRING, cmd.OPT_OPTIONAL)
:SetFlag 'D'
:SetHelp 'Starts an event vote and teleports people that vote \'yes\' to where you were looking. Also sets their jobs if a job name is supplied.'

ba.AddCommand('Freeze Props', function(pl, target)
	if IsValid(target) then
		ba.notify_staff(term.Get('AdminFrozePlayersProps'), pl, target)
		for k, v in ipairs(ents.GetAll()) do
			if IsValid(v) and v:IsProp() and (v:CPPIGetOwner() == target) then
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
				constraint.RemoveAll(v)
			end
		end
	else
		ba.notify_staff(term.Get('AdminFrozeAllProps'), pl)
		for k, v in ipairs(ents.GetAll()) do
			if IsValid(v) and v:IsProp() then
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
				constraint.RemoveAll(v)
			end
		end
	end
end)
:AddParam(cmd.PLAYER_ENTITY, cmd.OPT_OPTIONAL)
:SetFlag 'A'
:SetHelp 'Freezes all props'

ba.AddCommand('Deny Vote', function(pl, target)
	if (not rp.question.Exists('demote.' .. target:SteamID())) then
		ba.notify_err(pl, term.Get('PlayerVoteInvalid'), target)
	else
		rp.question.Destroy('demote.' .. target:SteamID(), true)
		ba.notify_staff(term.Get('AdminDeniedVote'), pl, target)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetIgnoreImmunity(true)
:SetFlag 'M'
:SetHelp 'Denies a vote for the target'

ba.AddCommand('Deny Team Vote', function(pl, target)
	if (!rp.teamVote.Votes[target]) then
		ba.notify_err(pl, term.Get('PlayerVoteInvalid'), target)
	else
		rp.teamVote.Votes[target] = nil
		for k, v in ipairs(rp.teams) do
			if (v.name == target) then
				v.CurVote = nil
			end
		end
		ba.notify_staff(term.Get('AdminDeniedTeamVote'), pl, target)
	end
end)
:AddParam(cmd.STRING)
:SetIgnoreImmunity(true)
:SetFlag 'M'
:SetHelp 'Denies a team vote'

ba.AddCommand('Shop')
:RunOnClient(function()
	gui.OpenURL(rp.cfg.CreditsURL .. "?sid=" .. LocalPlayer():SteamID())
end)
:SetFlag 'U'
:SetHelp 'Opens our credit shop'
:AddAlias 'donate'


ba.AddCommand('Add Money', function(pl, target, amount)
	target:AddMoney(amount)

	ba.notify(target, term.Get('AdminAddedYourMoney'), pl, amount)
	ba.notify(pl, term.Get('AdminAddedMoney'), amount, target)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag '*'
:SetHelp 'Gives a player money'

ba.AddCommand('Add Credits', function(pl, target, amount, note)
	note = note or ('Given by ' .. pl:NameID())

	if isplayer(target) then
		target:AddCredits(amount, note, function()
			ba.notify(target, term.Get('AdminAddedYourCredits'), pl, amount)
		end)
	else
		rp.data.AddCredits(ba.InfoTo32(target), amount, note)
	end

	ba.notify(pl, term.Get('AdminAddedCredits'), amount, target)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:AddParam(cmd.NUMBER)
:AddParam(cmd.STRING, cmd.OPT_OPTIONAL)
:SetFlag '*'
:SetHelp 'Gives a player credits'


ba.AddCommand('View Pocket', function(pl, target)
	target:SendInv(pl)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Displays the target\'s pocket contents on your screen'

local setHealth = ENTITY._SetHealth or ENTITY.SetHealth
ba.AddCommand('Set Health', function(pl, target, health)
	setHealth(target, health)

	ba.notify_staff(term.Get('AdminSetHealth'), pl, target, health)
	ba.notify(target, term.Get('AdminSetYourHealth'), pl, health)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s health'

ba.AddCommand('Set Armor', function(pl, target, armor)
	target:SetArmor(armor)

	ba.notify_staff(term.Get('AdminSetArmor'), pl, target, armor)
	ba.notify(target, term.Get('AdminSetYourArmor'), pl, armor)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s health'


ba.AddCommand('Set Run Speed', function(pl, target, speed)
	target:SetRunSpeed(speed)

	ba.notify_staff(term.Get('AdminSetSpeed'), pl, target, speed)
	ba.notify(target, term.Get('AdminSetYourSpeed'), pl, speed)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s run speed'

ba.AddCommand('Set Walk Speed', function(pl, target, speed)
	target:SetWalkSpeed(speed)

	ba.notify_staff(term.Get('AdminSetSpeed'), pl, target, speed)
	ba.notify(target, term.Get('AdminSetYourSpeed'), pl, speed)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s walk speed'

ba.AddCommand('Set Jump Height', function(pl, target, height)
	target:SetJumpPower(height)

	ba.notify_staff(term.Get('AdminSetJump'), pl, target, height)
	ba.notify(target, term.Get('AdminSetYourJump'), pl, height)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s jump power'

ba.AddCommand('Set Weapon Damage', function(pl, target, dmg)
	local wep = target:GetActiveWeapon()

	if IsValid(wep) and isnumber(wep.Damage) then
		wep.Damage = dmg
	elseif IsValid(wep) and wep.Primary and isnumber(wep.Primary.Damage) then
		wep.Primary.Damage = dmg
	else
		ba.notify_err(target, term.Get('WepDoesNoDmg'), target)
		return
	end

	ba.notify_staff(term.Get('AdminSetWepDmg'), pl, wep.PrintName or wep:GetClass(), target, dmg)
	ba.notify(target, term.Get('AdminSetYourWepDMG'), pl, wep.PrintName or wep:GetClass(), dmg)

end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s jump power'


ba.AddCommand('Toggle Nametag', function(pl, target)
	local hidden = target:GetNetVar('HideNameTag')

	if (hidden) then hidden = nil
	else hidden = true end

	target:SetNetVar('HideNameTag', hidden)

	ba.notify_staff(term.Get('AdminToggledNametag'), pl, hidden and 'hidden' or 'unhidden', target)
	ba.notify(target, term.Get('AdminToggledYourNametag'), pl, hidden and 'hidden' or 'unhidden')
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'G'
:SetHelp 'Toggles a player\'s nametag on or off'
:AddAlias 'togglent'

ba.AddCommand('Reset Nametags', function(pl)
	local notify = false

	for k, v in ipairs(player.GetAll()) do
		if (v:GetNetVar('HideNameTag')) then
			notify = true

			v:SetNetVar('HideNameTag', nil)
		end
	end

	if (notify) then
		ba.notify_staff(term.Get('AdminResetNametags'), pl)
	else
		return ba.NOTIFY_ERROR, term.Get('NoHiddenNametags')
	end
end)
:SetFlag 'G'
:SetHelp 'Unhides all players\' nametags'

ba.AddCommand('Scale Player', function(pl, target, size)
	target:SetModelScale(size, 1)
	size = Vector(size, size, size)

	local bones = {
		target:LookupBone('ValveBiped.Bip01_Head1'),
		target:LookupBone('ValveBiped.Bip01_Spine'),
		target:LookupBone('ValveBiped.Bip01_R_Thigh'),
		target:LookupBone('ValveBiped.Bip01_R_Calf'),
		target:LookupBone('ValveBiped.Bip01_L_Thigh'),
		target:LookupBone('ValveBiped.Bip01_L_Calf'),
		target:LookupBone('ValveBiped.Bip01_R_Foot'),
		target:LookupBone('ValveBiped.Bip01_L_Foot'),
		target:LookupBone('ValveBiped.Bip01_R_Hand'),
		target:LookupBone('ValveBiped.Bip01_L_Hand'),
		target:LookupBone('ValveBiped.Bip01_R_Forearm'),
		target:LookupBone('ValveBiped.Bip01_L_Forearm')
	}

	for k, v in pairs(bones) do
		target:ManipulateBoneScale(v, size)
	end

	ba.notify_staff(term.Get('AdminScaledPlayer'), pl, target, size.x * 100)
	ba.notify(target, term.Get('AdminScaledYou'), pl, size.x * 100)
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:SetFlag 'G'
:SetHelp 'Sets a player\'s scale (1 is default)'

ba.AddCommand('notarget', function(pl, targ)
	if (not IsValid(targ)) then
		return
	end

	local notarget = not targ:IsFlagSet(FL_NOTARGET)
	targ:SetNoTarget(notarget)

	ba.notify(pl, term.Get('ToggleNPCNoTarget'), notarget and 'enabled' or 'disabled', targ)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetHelp('Toggles no target. This means NPCs cannot interact/attack the target you specify.')
:SetFlag 'G'

chat.Register 'EventMessage'
	:Write(net.WriteString)
	:Read(function()
		local msg = net.ReadString()

		return ui.col.Pink, '[Event Message] ', ui.col.White, msg
	end)

ba.AddCommand('eventmessage', function(pl, text)
	chat.Send('EventMessage', text)
end)
:AddParam(cmd.STRING)
:AddAlias('em')
:SetHelp('Sends an event message to all players in chat')
:SetFlag 'D'

local UpdateEntityStats, SetEntityStats, ResetEntityStats
if SERVER then

	function UpdateEntityStats(pl, ent)
		local overrides = pl.spawnstats and pl.spawnstats[ent:GetClass()] or {}

		if overrides.health then
			ent:SetHealth(overrides.health)
		end

		ent.statdamagescaled = overrides.damage
	end
	hook('PlayerSpawnedNPC', 'rp.npctools.PlayerSpawnedNPC', UpdateEntityStats)

	hook('EntityTakeDamage', 'rp.npctools.EntityTakeDamage', function(pl, dmg)
		local attacker = dmg:GetAttacker()

		if IsValid(attacker) and attacker.statdamagescaled then
			local dmgnum = dmg:GetDamage()
			dmg:SetDamage(dmgnum * (attacker.statdamagescaled or 1))
		end
	end)

	function SetEntityStats(pl, class, key, value, setNow)
		pl.spawnstats = pl.spawnstats or {}
		pl.spawnstats[class] = pl.spawnstats[class] or {}
		pl.spawnstats[class][key] = value

		if setNow then
			for _, ent in ipairs(ents.FindByClass(class)) do
				if (ent:CPPIGetOwner() == pl) then
					UpdateEntityStats(pl, ent)
				end
			end
		end
	end

	function ResetEntityStats(pl, class, key)
		if pl.spawnstats[class] then
			pl.spawnstats[class][key] = nil
		end
	end
end

ba.AddCommand('npcresetall', function(pl)
	pl.spawnstats = {}
end)
:SetHelp('Resets all NPC stats to default')
:SetFlag 'G'

ba.AddCommand('setnpchealth', function(pl, class, health)
	SetEntityStats(pl, class, 'health', math.Clamp(health, 1, 15000))
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Sets the npc health of a specific class. This works for base classes too. From 1 to 15000.')
:SetFlag 'G'

ba.AddCommand('setnpchealthupdate', function(pl, class, health)
	SetEntityStats(pl, class, 'health', math.Clamp(health, 1, 15000), true)
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Sets the npc health of a specific class and all currently spawned npcs of that class. This works for base classes too. From 1 to 15000.')
:SetFlag 'G'

ba.AddCommand('setnpcdamage', function(pl, class, damage)
	SetEntityStats(pl, class, 'damage', math.Clamp(damage, 1, 15000))
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Sets the npc damage scale of a specific class. This works for base classes too. From 1 to 15000.')
:SetFlag 'G'

ba.AddCommand('setnpcdamageupdate', function(pl, class, damage)
	SetEntityStats(pl, class, 'damage', math.Clamp(damage, 1, 15000), true)
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Sets the npc damage scale of a specific class and all currently spawned npcs of that class. This works for base classes too.')
:SetFlag 'G'

ba.AddCommand('resetnpchealth', function(pl, class)
	ResetEntityStats(pl, class, 'health')
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Resets npc health')
:SetFlag 'G'

ba.AddCommand('resetnpcdamage', function(pl, class)
	ResetEntityStats(pl, class, 'damage')
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:SetHelp('Resets npc damage')
:SetFlag 'G'


if (CLIENT) then
	hook('HUDShouldDraw', function(name, pl)
		if (name == 'PlayerDisplay') then
			return !pl:GetNetVar('HideNameTag')
		end
	end)
end
