util.AddNetworkString('rp.SyncHits')
util.AddNetworkString('rp.AddHit')
util.AddNetworkString('rp.RemoveHit')

rp.Hitlist = rp.Hitlist or {}

function PLAYER:AddHit(price)
	if self:GetNetVar('HitPrice') then
		self:SetNetVar('HitPrice', self:GetNetVar('HitPrice') + price)
		rp.Hitlist[self:SteamID64()] = self:GetNetVar('HitPrice') + price
	else
		self:SetNetVar('HitPrice', price)
		rp.Hitlist[self:SteamID64()] = price
	end
end

function PLAYER:RemoveHit(hitman)
	if IsValid(hitman) then
		rp.NotifyAll(NOTIFY_GENERIC, term.Get('HitComplete'), self)
		self:Notify(NOTIFY_GENERIC, term.Get('YourHitComplete'))
		hitman:AddMoney(self:GetHitPrice())
		hitman:Notify(NOTIFY_GENERIC, term.Get('+Money'), self:GetHitPrice())
	end
	self:SetNetVar('HitPrice', nil)
	rp.Hitlist[self:SteamID64()] = nil
end


rp.AddCommand('hit', function(pl, targ, price)

	if (targ == pl) then
		pl:Notify(NOTIFY_ERROR, term.Get('CantHitYourself'))
	elseif targ:IsMayor() and nw.GetGlobal("mayorGrace") and (nw.GetGlobal("mayorGrace") > CurTime()) then
		pl:Notify(NOTIFY_ERROR, term.Get('CantPlaceHitGrace'))
	elseif pl:IsHitman() then
		pl:Notify(NOTIFY_ERROR, term.Get('CantPlaceHit'))
	elseif (not pl:CanAfford(price)) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
	elseif (price < rp.cfg.HitMinCost) or (price > rp.cfg.HitMaxCost) then
		pl:Notify(NOTIFY_ERROR, term.Get('HitPriceLimit'), rp.cfg.HitminCost, rp.cfg.HitMaxCost)
	elseif pl.LastHitTime and (pl.LastHitTime > CurTime()) and (not pl:IsRoot()) then
		pl:Notify(NOTIFY_ERROR, term.Get('HitTimer'), math.ceil(pl.LastHitTime - CurTime()))
	elseif targ.HitCoolDown and (targ.HitCoolDown > CurTime()) and (not pl:IsRoot()) then
		pl:Notify(NOTIFY_ERROR, term.Get('HitCooldown'))
	elseif pl.LastHit and (pl.LastHit == targ) and (not pl:IsRoot()) then
		pl:Notify(NOTIFY_ERROR, term.Get('MultiHit'))
	else

		if (math.random(1, 100) <= 25) then
			targ = pl
		end

		pl.LastHit 		= targ
		pl.LastHitTime 	= CurTime() + rp.cfg.HitCoolDown

		if targ:HasHit() then
			pl:Notify(NOTIFY_GREEN, term.Get('BountyIncrease'), targ, rp.FormatMoney(price))
		else
			if (targ == pl) then
				pl:Notify(NOTIFY_GENERIC, term.Get("HitKindaFailed"))
			else
				pl:Notify(NOTIFY_GREEN, term.Get('HitPlaced'), targ, rp.FormatMoney(price))
			end
		end

		hook.Call('playerRequestedHit', GAMEMODE, pl, targ)

		pl:TakeMoney(price)
		targ:AddHit(price)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:AddAlias('hitman')
:SetCooldown(3)

timer.Create('RandomHits', 600, 0, function()
	if (#player.GetAll() >= 10) then
		local lowest
		local karma = 100
		for k, v in ipairs(player.GetAll()) do
			if v:Alive() and (not v:HasHit()) and (v:GetKarma() <= karma) then
				lowest = v
				karama = v:GetKarma()
			end
		end
		if IsValid(lowest) then
			lowest:AddHit(rp.cfg.HitMinCost)
		end
	end
end)

hook('PlayerDeath', function(pl, wep, killer)
	if pl:HasHit() and killer:IsPlayer() and killer:IsHitman() and (killer ~= pl) then
		pl:RemoveHit(killer)
		pl.HitCoolDown = CurTime() + rp.cfg.HitCoolDown
		hook.Call('playerCompletedHit', GAMEMODE, killer, pl)
	end

	if pl:IsHitman() and killer:IsPlayer() and killer:HasHit() then
		pl:TeamBan(pl:Team(), 180)
		pl:ChangeTeam(1, true)
		pl:Notify(NOTIFY_ERROR, term.Get('HitmanFailed'))
	end
end)

hook('PlayerInitialSpawn', function(pl)
	if rp.Hitlist[pl:SteamID64()] then
		pl:AddHit(rp.Hitlist[pl:SteamID64()])
	end
end)
