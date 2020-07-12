rp.AddCommand("rob", function(pl)
	local RobAmount = math.random(50, 1000)
	local Target = pl:GetEyeTrace().Entity

	if !pl:Alive() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('YouAreDead'))
		return
	end

	if !IsValid(Target) or (pl:EyePos():DistToSqr(Target:GetPos()) > 28900) or !Target:IsPlayer() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GetCloser'))
		return
	end

	if pl:Team() != TEAM_ANARCHIST then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CantDoThis'))
		return
	end

	if pl.RobCooldown != nil && CurTime() < pl.RobCooldown then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(pl.RobCooldown-CurTime()))
		return
	end

	pl.RobCooldown = (CurTime() + 180)

	pl:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)

	if Target:IsGov() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('BaitingRule'))
		pl:Wanted(nil, "Robbing")
		return
	end

	if Target:Team() == TEAM_HOBO or Target:Team() == TEAM_HOBOKING then
		if math.random(1, 4) != 2 then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('YouGotHerpes'))
			pl:GiveSTD("Герпис")
			return
		end
		rp.Notify(pl, NOTIFY_GENERIC, term.Get('FoundNothing'))
		return
	end

	if !Target:CanAfford(1000) then
		rp.Notify(pl, NOTIFY_GENERIC, term.Get('FoundNothing'))
		rp.Notify(Target, NOTIFY_ERROR, term.Get('RobberyAttempt'))
		return
	end

	if math.random(1, 2) != 2 then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('RobberyFailed'))
		rp.Notify(Target, NOTIFY_ERROR, term.Get('RobberyAttempt'))
		return
	end

	if pl:CloseToCPs() && !pl:IsWanted() then
		pl:Wanted(nil, "Robbing")
	end

	Target:AddMoney(-RobAmount)
	pl:AddMoney(RobAmount)
	rp.Notify(pl, NOTIFY_GREEN, term.Get('YouRobbed'), RobAmount)
	rp.Notify(Target, NOTIFY_ERROR, term.Get('YouAreRobbed'))

end)
