/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
 rp.AddCommand('give', function(pl, money)

	local trace = pl:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():DistToSqr(pl:GetPos()) < 22500 then
		local amount = math.floor(tonumber(money))

		if amount < 1 then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('GiveMoneyLimit'))
			return
		end

		if not pl:CanAfford(amount) then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
			return
		end

		rp.data.PayPlayer(pl, trace.Entity, amount)

		rp.Notify(trace.Entity, NOTIFY_GREEN, term.Get('PlayerGaveCash'), pl, rp.FormatMoney(amount))
		rp.Notify(pl, NOTIFY_GREEN, term.Get('YouGaveCash'), trace.Entity, rp.FormatMoney(amount))
	else
		rp.Notify(pl, NOTIFY_ERROR, term.Get('MustLookAtPlayer'))
	end

end)
:AddParam(cmd.NUMBER)
:SetCooldown(3)

rp.AddCommand('dropmoney', function(pl, money)

	local amount = math.floor(tonumber(money))

	if amount <= 1 then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('DropMoneyLimit'))
		return
	end

	if not pl:CanAfford(amount) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	pl:AddMoney(-amount)

	hook.Call('PlayerDropRPMoney', GAMEMODE, pl, amount, pl:GetMoney())

	local trace = {}
	trace.start = pl:EyePos()
	trace.endpos = trace.start + pl:GetAimVector() * 85
	trace.filter = pl

	local tr = util.TraceLine(trace)
	rp.SpawnMoney(tr.HitPos, amount)

end)
:AddParam(cmd.NUMBER)
:AddAlias('moneydrop')
:SetCooldown(3)

rp.AddCommand('cheque', function(pl, pl2, amount)

	if (pl == pl2) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('ChequeArg1'), pl2)
		return
	end

	if not pl:CanAfford(amount) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
	end

  if !pl:CheckLimit("cheque") then
    return
  end

	if IsValid(pl) and IsValid(pl2) then
		pl:AddMoney(-amount)

		local trace = {}
		trace.start = pl:EyePos()
		trace.endpos = trace.start + pl:GetAimVector() * 85
		trace.filter = pl

		local tr = util.TraceLine(trace)
		local Cheque = ents.Create("spawned_cheque")
		Cheque:SetPos(tr.HitPos)
		Cheque:Setowning_ent(pl)
		Cheque:Setrecipient(pl2)

		Cheque:Setamount(math.Min(amount, 2147483647))
		Cheque:Spawn()

    pl:AddCount("cheque", Cheque)

		hook.Call('PlayerDropRPCheck', GAMEMODE, pl, pl2, Cheque:Getamount(), pl:GetMoney())
	end

end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:AddAlias('cheque')
:AddAlias('check')
:SetCooldown(3)

rp.AddCommand('wiremoney', function(pl, pl2, amount)

	if (pl == pl2) then
		return
	end

	if not pl:CanAfford(amount) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
	end

	if IsValid(pl) and IsValid(pl2) then
    amount = math.floor(amount * 0.8)
		pl:TakeMoney(amount)
    pl2:AddMoney(amount)

    rp.Notify(pl2, NOTIFY_GREEN, term.Get('PlayerGotWire'), pl, rp.FormatMoney(amount))
		rp.Notify(pl, NOTIFY_GREEN, term.Get('PlayerSentWire'), pl2, rp.FormatMoney(amount))
	end

end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.NUMBER)
:AddAlias('wire')
:SetCooldown(3)
