-- laws
util.AddNetworkString('rp.SendLaws')

function rp.resetLaws()
	nw.SetGlobal('TheLaws', nil)
	rp.NotifyAll(NOTIFY_GENERIC, term.Get('LawsChanged'))
	rp.FlashNotifyAll('Государство', term.Get('LawsChanged'))

	hook.Call('mayorResetLaws', GAMEMODE, pl)
end

rp.AddCommand('resetlaws', function(pl)
	if not pl:IsMayor() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeMayorResetLaws'))
		return
	end

	if (pl:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine'))
		return
	end

	rp.resetLaws()
end)
:SetCooldown(5)

local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local lottoStarter
local function EndLottery()
	LotteryON = false
	if table.Count(LotteryPeople) == 0 then
		rp.NotifyAll(NOTIFY_GENERIC, term.Get('NoLotteryAll'))
		return
	end

	if (#LotteryPeople > 1) then
		local chosen 	= LotteryPeople[math.random(1, #LotteryPeople)]
		local amount 	= (#LotteryPeople * LotteryAmount)
		local tax 		= amount * 0.05

		chosen:AddMoney(amount - tax)
		if IsValid(lottoStarter) then
			lottoStarter:AddMoney(tax)
			rp.Notify(lottoStarter, NOTIFY_GREEN, term.Get('LotteryTax'), rp.FormatMoney( tax))
		end
		rp.NotifyAll(NOTIFY_GREEN, term.Get('LotteryWinner'), chosen, rp.FormatMoney(amount - tax))
	else
		local ret = LotteryPeople[1]
		if IsValid(ret) then
			ret:AddMoney(LotteryAmount)
			rp.Notify(ret, NOTIFY_ERROR, term.Get('NoLottery'))
		end
		if IsValid(lottoStarter) then
			rp.Notify(lottoStarter, NOTIFY_ERROR, term.Get('NoLotteryTax'))
		end
	end
end

rp.AddCommand("lottery", function(ply, amount)
	if not ply:IsMayor() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('IncorrectJob'))
		return
	end

	if (ply:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine'))
		return
	end

	if player.GetCount() <= 2 or LotteryON then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotLottery'))
		return
	end

	if not amount then
		rp.Notify(ply, NOTIFY_GENERIC, term.Get('LottoCost'), rp.cfg.MinLotto, rp.cfg.MaxLotto)
		return
	end

	lottoStarter = ply
	LotteryAmount = math.Clamp(math.floor(amount), rp.cfg.MinLotto, rp.cfg.MaxLotto)

	hook.Call('lotteryStarted', GAMEMODE, ply)

	rp.NotifyAll(NOTIFY_GENERIC, term.Get('LotteryStarted'))

	LotteryON = true
	LotteryPeople = {}

	rp.question.Create("Лотерея! Для учасния нужно " .. rp.FormatMoney(LotteryAmount) .. " вы готовы?", 30, "lottery", function(pl, answer)
		if tobool(answer) and not table.HasValue(LotteryPeople, pl) then
			if not pl:CanAfford(LotteryAmount) then
				rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
				return
			end
			table.insert(LotteryPeople, pl)
			pl:AddMoney(-LotteryAmount)
			rp.Notify(pl, NOTIFY_GREEN, term.Get('InLottery'), rp.FormatMoney(LotteryAmount))
		elseif not tobool(answer) then
			rp.Notify(pl, NOTIFY_GENERIC, term.Get('NotInLottery'))
		end
	end, false, player.GetAll())

	timer.Create("Lottery", 30, 1, EndLottery)
end)
:AddAlias('lotto')
:AddParam(cmd.NUMBER)
:SetCooldown(300)

function GM:LockdownStarted(pl)
	table.foreach(player.GetAll(), function(k, v)
		v:ConCommand("play ".. table.Random(rp.cfg.LockdownSounds) .."\n")
	end)
end

rp.AddCommand("lockdown", function(ply)
	if not ply:IsMayor() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('IncorrectJob'))
		return
	end

	if (ply:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine'))
		return
	end

	if nw.GetGlobal("lockdown") then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotLockdown'))
		return
	end

	nw.SetGlobal('lockdown', CurTime() + rp.cfg.LockdownTime)
	nw.SetGlobal('mayorGrace', nil)
	rp.NotifyAll(NOTIFY_ERROR, term.Get('LockdownStarted'))
	hook.Call('LockdownStarted', GAMEMODE, ply)

	timer.Create('StopLock', rp.cfg.LockdownTime, 1, function()
		GAMEMODE:UnLockdown(team.GetPlayers(TEAM_MAYOR)[1])
	end)
end)
:SetCooldown(300)

function GM:UnLockdown(ply)
	rp.NotifyAll(NOTIFY_GREEN, term.Get('LockdownEnded'))
	nw.SetGlobal('lockdown', nil)
	if (ply) then
		hook.Call('LockdownEnded', GAMEMODE, ply)
	end
end
rp.AddCommand("unlockdown", function(ply)
	if not ply:IsMayor() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('IncorrectJob'))
		return
	end

	if (ply:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine'))
		return
	end

	if not nw.GetGlobal("lockdown") then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotUnlockdown'))
		return
	end

	GAMEMODE:UnLockdown(ply)
end)
:SetCooldown(300)

net('rp.SendLaws', function(len, pl)
	if not pl:IsMayor() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeMayorSetLaws'))
		return
	end

	if (pl:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine'))
		return
	end

	local str = net.ReadString()
	if utf8.len(str) >= 260 then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('LawsTooLong'))
		return
	end

	hook.Call('mayorSetLaws', GAMEMODE, pl)
	nw.SetGlobal('TheLaws', str)
end)

hook("OnPlayerChangedTeam", "mayorgrace.OnPlayerChangedTeam", function(pl, before, after)
	if (rp.teams[after].mayor == true) then
		nw.SetGlobal('mayorGrace', CurTime() + 300)
	elseif (rp.teams[before].mayor == true) then
		nw.SetGlobal('mayorGrace', nil)
	end
end)

-- Demote classes upon death
hook("PlayerDeath", "DemoteOnDeath",function(v, k)
	if (v:IsMayor() and (nw.GetGlobal('mayorGrace') >= CurTime())) then
		GAMEMODE:UnLockdown()
		nw.SetGlobal('mayorGrace', nil)
		rp.resetLaws()
		v:ChangeTeam(1, true)
		v:TeamBan(TEAM_MAYOR, 180)
		rp.FlashNotifyAll("Государство", term.Get('MayorHasDied'))
	end
end)
