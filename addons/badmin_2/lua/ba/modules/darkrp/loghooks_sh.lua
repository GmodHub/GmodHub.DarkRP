/*local term = ba.logs.Term

-- Kills
ba.logs.AddTerm('KilledPlayer', '#(#) killed #(#) with # #', {
	'Attacker Name',
	'Attacker SteamID',
	[3] = 'Name',
	[4] = 'SteamID',
})

ba.logs.AddTerm('KilledByNPC', '# killed #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('KilledNPC', '#(#) killed #', {
	'Name',
	'SteamID',
})

ba.logs.Create 'Kills'
	:SetColor(Color(200,0,0))
	:Hook('PlayerDeath', function(self, pl, ent, killer)
		if killer:IsPlayer() and (not pl:IsBanned()) then
			local w = killer:GetActiveWeapon()
			if w and w:IsValid() then
				wep = w:GetClass()
			else
				wep = "none"
			end
			self:PlayerLog({pl, killer}, term('KilledPlayer'), killer, pl, wep, ((killer:IsHitman() and pl:HasHit()) and ' for a hit' or ''))
		end

		if killer:IsNPC() then
			self:PlayerLog({pl}, term('KilledByNPC'), killer:GetClass(), pl)
		end
	end)
	:Hook('OnNPCKilled', function(self, npc, attacker, inflictor)
		if attacker:IsPlayer() then
			self:PlayerLog({pl}, term('KilledNPC'), attacker, npc:GetClass())
		end
	end)


-- Damage
local damageLogs = {}

ba.logs.AddTerm('Damage', '#(#) did # damage to #(#) with # # times starting # seconds ago', {
	'Attacker Name',
	'Attacker SteamID',
	[4] = 'Name',
	[5] = 'SteamID',
})

local dmgLog = ba.logs.Create 'Damage'
	dmgLog:Hook('EntityTakeDamage', function(self, ent, dmginfo)
		local attacker = dmginfo:GetAttacker()

		if ent:IsPlayer() and attacker:IsPlayer() and (not ent:IsBanned()) then
			local wep 		= attacker:GetActiveWeapon()
			local wepClass 	= IsValid(wep) and wep:GetClass() or 'unknown'

			local key = ent:SteamID() .. attacker:SteamID() .. wepClass

			local tab = damageLogs[key] or {
				FirstDamage 	= CurTime(),
				PlayerName 		= ent:Name(),
				PlayerSteamID 	= ent:SteamID(),
				AttackerName 	= attacker:Name(),
				AttackerSteamID = attacker:SteamID(),
				Weapon  		= wepClass,
				Damage 			= 0,
				Times			= 0,
			}

			tab.LastDamage	= CurTime()
			tab.Damage 		= tab.Damage + math.Round(dmginfo:GetDamage(), 0)
			tab.Times 		= tab.Times + 1

			damageLogs[key] = tab
		end
	end)

if SERVER then
	timer.Create('ba.logs.PushDamageLogs', 1, 0, function()
		for k, v in pairs(damageLogs) do
			if ((CurTime() - v.LastDamage) > 2) then
				dmgLog:Log(term('Damage'), v.AttackerName, v.AttackerSteamID, v.Damage, v.PlayerName, v.PlayerSteamID, v.Weapon, v.Times, math.Round(CurTime() - v.FirstDamage, 2))
				damageLogs[k] = nil
			end
		end
	end)
end

-- Props
ba.logs.AddTerm('Prop', '#(#) spawned #', {
	'Name',
	'SteamID',
})

ba.logs.Create 'Props'
	:SetColor(Color(50,175,255))
	:Hook('PlayerSpawnProp', function(self, pl, mdl)
		if (not pl:IsBanned()) and (not pl:IsJailed()) and (not pl.SpawningDupeProp) then
			self:PlayerLog(pl, term('Prop'), pl, mdl)
		end
	end)

-- Dupes
ba.logs.AddTerm('Dupe', '#(#) spawned a dupe with # entities and # constraints', {
	'Name',
	'SteamID',
})

ba.logs.Create 'Dupes'
	:SetColor(Color(153,102,255))
	:Hook('PlayerSpawnDupe', function(self, pl, file, ents, constraints)
		self:PlayerLog(pl, term('Dupe'), pl, #ents, #constraints)
	end)


-- Tools
ba.logs.AddTerm('Tool', '#(#) tooled # owned by #(#) with #', {
	'Name',
	'SteamID',
})

ba.logs.Create 'Tools'
	:Hook('PlayerToolEntity', function(self, pl, ent, tool)
		if IsValid(ent) then
			if IsValid(ent:CPPIGetOwner()) then
				self:PlayerLog(pl, term('Tool'), pl:Name(), pl:SteamID(), ent:GetClass(), ent:CPPIGetOwner():Name(), ent:CPPIGetOwner():SteamID(), tool)
			else
				self:PlayerLog(pl, term('Tool'), pl:Name(), pl:SteamID(), ent:GetClass(), 'Unknown', 'STEAM:0:0', tool)
			end
		end
	end)


-- Physgun
ba.logs.AddTerm('Physgun', '#(#) physgunned # owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.Create('Physgun', false)
	:Hook('PlayerPhysgunEntity', function(self, pl, ent)
		if IsValid(ent:CPPIGetOwner()) then
			self:PlayerLog(pl, term('Physgun'), pl:Name(), pl:SteamID(), ent:GetClass(), ent:CPPIGetOwner():Name(), ent:CPPIGetOwner():SteamID(), tool)
		else
			self:PlayerLog(pl, term('Physgun'), pl:Name(), pl:SteamID(), ent:GetClass(), 'Unknown', 'STEAM:0:0', tool)
		end
	end)


-- Actions
ba.logs.AddTerm('RunRPCommand', '#(#) ran # #', {
	'Name',
	'SteamID',
})

local function stingify(v)
	if isplayer(v) and IsValid(v) then
		return v:Name()
	end
	return tostring(v)
end

local function concatargs(args)
	local str
	for k, v in pairs(args) do
		str =  (str and (str .. ', ') or ', ') .. stingify(v)
	end
	return str or ''
end

local badcmds = {
	['weaponcolor'] = true,
	['model'] = true,
	['playercolor'] = true
}
ba.logs.Create 'RP Commands'
	:Hook('cmd.OnCommandRun', function(self, pl, cmdobj, args)
		if (cmdobj:GetConCommand() == 'rp') and (not badcmds[cmdobj:GetName()]) then
			self:PlayerLog(pl, term('RunRPCommand'), pl:Name(), pl:SteamID(), cmdobj:GetName(), concatargs(args))
		end
	end)


-- Transactions
ba.logs.AddTerm('DropMoney', '#(#) dropped $# (New wallet: $#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PickupMoney', '#(#) picked up $# (New wallet: $#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('DropCheck', '#(#) dropped a check to #(#) for $# (New wallet: $#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('PickupCheck', '#(#) picked up a check from #(#) for $# (New wallet: $#)', {
	'Name',
	'SteamID',
	'Giver Name',
	'Giver SteamID'
})

ba.logs.AddTerm('VoideCheck', '#(#) voided their check to #(#) for $# (New wallet: $#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('BuyItem', '#(#) bought # for $# (New wallet: $#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('BuyItemEntity', '#(#) bought # from # for $# (New wallet: $#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('GambleMoney', '#(#) # $# on # owned by #(#) (New wallets(est): $# and $#)', {
	'Name',
	'SteamID',
	'Owner Name',
	'Owner SteamID'
})

ba.logs.AddTerm('GiveMoney', '#(#) gave $# to #(#) (New wallets: $# and $#)', {
	'Name',
	'SteamID',
	[4] = 'Target Name',
	[5] = 'Target SteamID'
})

ba.logs.Create 'Money History'
	:Hook('PlayerDropRPMoney', function(self, pl, amt, newcash)
		self:PlayerLog(pl, term('DropMoney'), pl:Name(), pl:SteamID(), amt, newcash)
	end)
	:Hook('PlayerPickupRPMoney', function(self, pl, amt, newcash)
		self:PlayerLog(pl, term('PickupMoney'), pl:Name(), pl:SteamID(), amt, newcash)
	end)
	:Hook('PlayerDropRPCheck', function(self, pl, topl, amt, newcash)
		self:PlayerLog(pl, term('DropCheck'), pl:Name(), pl:SteamID(), topl:Name(), topl:SteamID(), amt, newcash)
	end)
	:Hook('PlayerPickupRPCheck', function(self, pl, frompl, amt, newcash)
		self:PlayerLog(pl, term('PickupCheck'), pl:Name(), pl:SteamID(), frompl:Name(), frompl:SteamID(), amt, newcash)
	end)
	:Hook('PlayerVoidedRPCheck', function(self, pl, topl, amt, newcash)
		self:PlayerLog(pl, term('VoideCheck'), pl:Name(), pl:SteamID(), topl:Name(), topl:SteamID(), amt, newcash)
	end)
	:Hook('PlayerBoughtItem', function(self, pl, item, amt, newcash)
		self:PlayerLog(pl, term('BuyItem'), pl:Name(), pl:SteamID(), item, amt, newcash)
	end)
	:Hook('PlayerGaveMoney', function(self, pl, pl2, amt, newcash, newcash2)
		self:PlayerLog({pl, pl2}, term('GiveMoney'), pl:Name(), pl:SteamID(), amt, pl2:Name(), pl2:SteamID(), newcash, newcash2)
	end)
	:Hook('PlayerBuyFromEntity', function(self, pl, item, ent, amt)
		self:PlayerLog(pl, term('BuyItemEntity'), pl:Name(), pl:SteamID(), item, ent:GetClass(), amt, pl:GetMoney())
	end)
	:Hook('PlayerGamble', function(self, pl, owner, ent, amt, playerWin)
		self:PlayerLog({pl, owner}, term('GambleMoney'), pl:Name(), pl:SteamID(), (playerWin and 'won' or 'lost'), amt, ent:GetClass(), owner:Name(), owner:SteamID(), (pl:GetMoney() - (playerWin and -amt or amt)), (owner:GetMoney() - (playerWin and amt or -amt)))
	end)




-- Police
ba.logs.AddTerm('Warranted', '#(#) warranted #(#) for #', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('UnWarranted', '#(#) unwarranted #(#)', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('Wanted', '#(#) wanted #(#) for #', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('UnWanted', '#(#) unwarranted #(#)', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('Arrested', '#(#) arrested #(#)', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('UnArrested', '#(#) unarrested #(#)', {
	'Officer Name',
	'Officer SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlayerArrestedEntity', '#(#) arrested # owned by #(#)', {
	'Officer Name',
	'Officer SteamID'
})

ba.logs.Create 'Police'
	:SetColor(Color(20,0,255))
	:Hook('PlayerWarranted', function(self, pl, actor, reason)
		if IsValid(actor) then
			self:PlayerLog({pl, actor}, term('Warranted'), actor, pl, reason)
		end
	end)
	:Hook('PlayerUnWarranted', function(self, pl, actor)
		if IsValid(actor) then
			self:PlayerLog({pl, actor}, term('UnWarranted'), actor, pl)
		end
	end)
	:Hook('PlayerWanted', function(self, pl, actor, reason)
		self:PlayerLog({pl, actor}, term('Wanted'), IsValid(actor) and actor:Name() or 'Console', IsValid(actor) and actor:SteamID() or 'STEAM:0:0', pl, reason)
	end)
	:Hook('PlayerUnwanted', function(self, pl, actor, reason)
		if IsValid(actor) then
			self:PlayerLog({pl, actor}, term('UnWanted'), actor, pl)
		end
	end)
	:Hook('PlayerArrested', function(self, pl, actor, reason)
		if IsValid(actor) then
			self:PlayerLog({pl, actor}, term('Arrested'), actor, pl)
		end
	end)
	:Hook('PlayerUnArrested', function(self, pl, actor, reason)
		if IsValid(actor) then
			self:PlayerLog({pl, actor}, term('UnArrested'), actor, pl)
		end
	end)
	:Hook('PlayerArrestedEntity', function(self, pl, ent, owner)
		if IsValid(owner) then
			self:PlayerLog({pl, owner}, term('PlayerArrestedEntity'), pl, ent:GetClass(), owner)
		else
			self:PlayerLog({pl}, term('PlayerArrestedEntity'), pl, ent:GetClass(), 'unknown', '')
		end
	end)


-- Mayor
ba.logs.AddTerm('StartLotto', '#(#) has started a lottery', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('StartLockdown', '#(#) has started a lockdown', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('EndLockdown', '#(#) has ended a lockdown', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('ChangeLaws', '#(#) has changed the laws', {
	'Name',
	'SteamID',
})

ba.logs.Create 'Mayor'
	:SetColor(Color(200,0,0))
	:Hook('lotteryStarted', function(self, pl)
		self:PlayerLog(pl, term('StartLotto'), pl)
	end)
	:Hook('LockdownStarted', function(self, pl)
		self:PlayerLog(pl, term('StartLockdown'), pl)
	end)
	:Hook('LockdownEnded', function(self, pl)
		self:PlayerLog(pl, term('EndLockdown'), pl)
	end)
	:Hook('mayorSetLaws', function(self, pl)
		self:PlayerLog(pl, term('ChangeLaws'), pl)
	end)
	:Hook('mayorResetLaws', function(self, pl)
		if IsValid(pl) then
			self:PlayerLog(pl, term('ChangeLaws'), pl)
		end
	end)


-- Hit logs
ba.logs.AddTerm('ServerRequestHit', 'The server requested a hit on #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlayerRequestHit', '#(#) requested a hit on #(#)', {
	'Requester Name',
	'Requester SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('CompleteHit', '#(#) completed a hit on #(#)', {
	'Hitman Name',
	'Hitman SteamID',
	'Name',
	'SteamID',
})

ba.logs.Create 'Hits'
	:SetColor(Color(204,204,0))
	:Hook('playerRequestedHit', function(self, pl, target)
		if IsValid(pl) then
			self:PlayerLog({pl, target}, term('PlayerRequestHit'), pl, target)
		else
			self:Log(term('ServerRequestHit'), target)
		end
	end)
	:Hook('playerCompletedHit', function(self, pl, target)
		self:PlayerLog({pl, target}, term('CompleteHit'), pl, target)
	end)


-- RP
ba.logs.AddTerm('ChangeName', '#(#) changed their RP name to "#"', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('DemotePlayer', '#(#) has started a demotion vote on #(#) for "#"', {
	'Demoter Name',
	'Demoter SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('DemotePlayerInstant', '#(#) as Chief or Mayor has demoted #(#) for "#"', {
	'Demoter Name',
	'Demoter SteamID',
	'Name',
	'SteamID',
})

ba.logs.AddTerm('Disguise', '#(#) has disguised as a # from a #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('UnDisguise', '#(#) has undisguised as a # from a #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('ChangeJob', '#(#) has changed jobs to # from a #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('HirePlayer', '#(#) has hired #(#)', {
	'Name',
	'SteamID',
	'Employee Name',
	'Employee SteamID',
})

ba.logs.AddTerm('Bailed', '#(#) has bailed #(#) for $#', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID',
})

ba.logs.AddTerm('ActicatedLicense', '#(#) has activated a gun license.', {
	'Name',
	'SteamID'
})


ba.logs.Create 'Roleplay'
	:SetColor(Color(100,50,20))
	:Hook('playerChangedRPName', function(self, pl, newname)
		self:PlayerLog(pl, term('ChangeName'), pl, newname)
	end)
	:Hook('playerDemotionVote', function(self, pl, target, reason)
		self:PlayerLog({pl, target}, term('DemotePlayer'), pl, target, reason)
	end)
	:Hook('playerDemotedPlayer', function(self, pl, target, reason)
		self:PlayerLog({pl, target}, term('DemotePlayerInstant'), pl, target, reason)
	end)
	:Hook('playerDisguised', function(self, pl, oldt, newt)
		self:PlayerLog(pl, term('Disguise'), pl, team.GetName(newt), team.GetName(oldt))
	end)
	:Hook('PlayerUnDisguised', function(self, pl, oldt, newt)
		self:PlayerLog(pl, term('UnDisguise'), pl, team.GetName(oldt), team.GetName(newt))
	end)
	:Hook('OnPlayerChangedTeam', function(self, pl, oldt, newt)
		self:PlayerLog(pl, term('ChangeJob'), pl, team.GetName(newt), team.GetName(oldt))
	end)
	:Hook('PlayerHirePlayer', function(self, employer, employee)
		self:PlayerLog({employer, employer}, term('HirePlayer'), employer, employee)
	end)
	:Hook('PlayerBailPlayer', function(self, pl, targ, cost)
		self:PlayerLog({pl, targ}, term('Bailed'), pl, targ, cost)
	end)
	:Hook('PlayerActivatedLicense', function(self, pl)
		self:PlayerLog(pl, term('ActicatedLicense'), pl)
	end)


-- Raid
ba.logs.AddTerm('PlaceC4', '#(#) placed a c4 on #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlaceC4On', '#(#) placed a c4 on # owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('DropC4', '#(#) dropped a c4', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlaceIncin', '#(#) placed a incendiary on #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlaceIncinOn', '#(#) placed a incendiary on # owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('DropIncin', '#(#) dropped a incendiary', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('StartKeypadCrack', '#(#) started cracking a keypad owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('FinishKeypadCrack', '#(#) finished cracking a keypad owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('StartLockpickOwner', '#(#) started lockpicking a door owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlayerBreakDownDoorOwner', '#(#) broke down a door owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlayerBreakDownDoorGroup', '#(#) broke down a door owned by #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('StartLockpickGroup', '#(#) started lockpicking a door owned by #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('FinishLockpickOwner', '#(#) finished lockpicking a door owned by #(#)', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('FinishLockpickGroup', '#(#) finished lockpicking a door owned by #', {
	'Name',
	'SteamID',
})

ba.logs.AddTerm('PlayerKidnapOpen', '#(#) force scanned #(#) on a #', {
	'Name',
	'SteamID',
	'Carried Name',
	'Carried SteamID',
})

ba.logs.AddTerm('PlayerDestroyedEntity', '#(#) destroyed # owned by #(#)', {
	'Owner Name',
	'Owner SteamID',
	[4] = 'Destroyer Name',
	[5] = 'Destroyer SteamID',
})



ba.logs.Create 'Raids'
	:Hook('PlayerPlaceC4', function(self, pl, ent)
		if IsValid(ent) then
			local owner = ent:CPPIGetOwner() or ent.ItemOwner or (ent:IsDoor() and ent:GetPropertyOwner())
			if IsValid(owner) then
				self:PlayerLog(pl, term('PlaceC4On'), pl:Name(), pl:SteamID(), ent:GetClass(), owner:Name(), owner:SteamID())
			else
				self:PlayerLog(pl, term('PlaceC4'), pl:Name(), pl:SteamID(), ent:GetClass())
			end
		else
			self:PlayerLog(pl, term('DropC4'), pl:Name(), pl:SteamID())
		end
	end)
	:Hook('PlayerPlaceIncendiary', function(self, pl, ent)
		if IsValid(ent) then
			local owner = ent:CPPIGetOwner() or ent.ItemOwner or (ent:IsDoor() and ent:GetPropertyOwner())
			if IsValid(owner) then
				self:PlayerLog(pl, term('PlaceIncinOn'), pl:Name(), pl:SteamID(), ent:GetClass(), owner:Name(), owner:SteamID())
			else
				self:PlayerLog(pl, term('PlaceIncin'), pl:Name(), pl:SteamID(), ent:GetClass())
			end
		else
			self:PlayerLog(pl, term('DropIncin'), pl:Name(), pl:SteamID())
		end
	end)
	:Hook('PlayerStartKeypadCrack', function(self, pl, ent)
		self:PlayerLog(pl, term('StartKeypadCrack'), pl:Name(), pl:SteamID(), ent:CPPIGetOwner():Name(), ent:CPPIGetOwner():SteamID())
	end)
	:Hook('PlayerFinishKeypadCrack', function(self, pl, ent)
		self:PlayerLog(pl, term('FinishKeypadCrack'), pl:Name(), pl:SteamID(), ent:CPPIGetOwner():Name(), ent:CPPIGetOwner():SteamID())
	end)

	:Hook('PlayerStartLockpicking', function(self, pl, ent)
		if IsValid(ent:GetPropertyOwner()) then
			self:PlayerLog(pl, term('StartLockpickOwner'), pl:Name(), pl:SteamID(), ent:GetPropertyOwner():Name(), ent:GetPropertyOwner():SteamID())
		else
			self:PlayerLog(pl, term('StartLockpickGroup'), pl:Name(), pl:SteamID(), (ent:IsPropertyTeamOwned() and ent:GetPropertyName() or 'no one'))
		end
	end)
	:Hook('PlayerFinishLockpicking', function(self, pl, ent)
		if IsValid(ent:GetPropertyOwner()) then
			self:PlayerLog(pl, term('FinishLockpickOwner'), pl:Name(), pl:SteamID(), ent:GetPropertyOwner():Name(), ent:GetPropertyOwner():SteamID())
		else
			self:PlayerLog(pl, term('FinishLockpickGroup'), pl:Name(), pl:SteamID(), (ent:IsPropertyTeamOwned() and ent:GetPropertyName() or 'no one'))
		end
	end)
	:Hook('PlayerBreakDownDoor', function(self, pl, ent)
		if IsValid(ent:GetPropertyOwner()) then
			self:PlayerLog(pl, term('PlayerBreakDownDoorOwner'), pl:Name(), pl:SteamID(), ent:GetPropertyOwner():Name(), ent:GetPropertyOwner():SteamID())
		else
			self:PlayerLog(pl, term('PlayerBreakDownDoorGroup'), pl:Name(), pl:SteamID(), (ent:IsPropertyTeamOwned() and ent:GetPropertyName() or 'no one'))
		end
	end)
	:Hook('PlayerKidnapOpenPad', function(self, pl, carried, type)
		self:PlayerLog({pl, carried}, term('PlayerKidnapOpen'), pl, carried, type)
	end)
	:Hook('PlayerDestroyedEntity', function(self, ent, pl, owner)
		self:PlayerLog(pl, term('PlayerDestroyedEntity'), pl:Name(), pl:SteamID(), ent:GetClass(), IsValid(owner) and owner:Name() or 'Console', IsValid(owner) and owner:SteamID() or 'STEAM:0:0')
	end)


ba.logs.AddTerm('VoiceStart', '#(#) started talking', {
	'Name',
	'SteamID'
})

ba.logs.AddTerm('VoiceEnd', '#(#) finished talking', {
	'Name',
	'SteamID'
})

ba.logs.Create 'Voice'
	:Hook('PlayerStartVoice', function(self, pl)
		self:Log(term('VoiceStart'), pl:Name(), pl:SteamID())
	end)
	:Hook('PlayerEndVoice', function(self, pl)
		self:Log(term('VoiceEnd'), pl:Name(), pl:SteamID())
	end)

ba.logs.AddTerm('Ziptied', '#(#) ziptied #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('CutZipties', '#(#) cut #(#)\'s zipties', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('ZiptieStruggled', '#(#) struggled free from zipties', {
	'Name',
	'SteamID'
})

ba.logs.AddTerm('ZiptieCarried', '#(#) picked up ziptied player #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('ZiptieDropped', '#(#) dropped ziptied player #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('ZiptieFreed', '#(#) started to cut #(#)\'s zipties', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('PickPocket', '#(#) pick pocketed #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('TasedSuccess', '#(#) tased #(#) and succeeded', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('TasedFail', '#(#) tased #(#) and failed', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('Slapped', '#(#) pimp slapped #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.AddTerm('Stunned', '#(#) stun batoned #(#)', {
	'Name',
	'SteamID',
	'Target Name',
	'Target SteamID'
})

ba.logs.Create 'Assault'
	:Hook('playerZiptiedPlayer', function(self, pl, target)
		self:PlayerLog({pl, target}, term('Ziptied'), pl, target)
	end)
	:Hook('playerCutPlayersZipties', function(self, pl, target)
		self:PlayerLog({pl, target}, term('CutZipties'), pl, target)
	end)
	:Hook('playerStartCutPlayersZipties', function(self, pl, target)
		self:PlayerLog({pl, target}, term('ZiptieFreed'), pl, target)
	end)
	:Hook('playerBrokeZipties', function(self, pl)
		self:PlayerLog(pl, term('ZiptieStruggled'), pl)
	end)
	:Hook('playerPickedUpPlayer', function(self, pl, target)
		self:PlayerLog({pl, target}, term('ZiptieCarried'), pl, target)
	end)
	:Hook('playerDroppedPlayer', function(self, pl, target)
		self:PlayerLog({pl, target}, term('ZiptieDropped'), pl, target)
	end)
	:Hook('PlayerPickPocket', function(self, pl, target)
		self:PlayerLog({pl, target}, term('PickPocket'), pl, target)
	end)
	:Hook('PlayerTasePlayer', function(self, pl, target)
		if IsValid(pl) and IsValid(target) then
			self:PlayerLog({pl, target}, term('TasedSuccess'), pl, target)
		end
	end)
	:Hook('PlayerTasePlayerFail', function(self, pl, target)
		if IsValid(pl) and IsValid(target) then
			self:PlayerLog({pl, target}, term('TasedFail'), pl, target)
		end
	end)
	:Hook('PlayerSlapPlayer', function(self, pl, target)
		if IsValid(pl) and IsValid(target) then
			self:PlayerLog({pl, target}, term('Slapped'), pl, target)
		end
	end)
	:Hook('PlayerStunPlayer', function(self, pl, target)
		if IsValid(pl) and IsValid(target) then
			self:PlayerLog({pl, target}, term('Stunned'), pl, target)
		end
	end)

ba.logs.AddTerm('SwitchedWep', '#(#) switched to #', {
	'Name',
	'SteamID'
})

ba.logs.Create 'Weapon'
	:Hook('PlayerSwitchWeapon', function(self, pl, oldWep, newWep)
		self:PlayerLog(pl, term('SwitchedWep'), pl, (IsValid(newWep) and newWep:GetClass() or 'nothing'))
	end)
