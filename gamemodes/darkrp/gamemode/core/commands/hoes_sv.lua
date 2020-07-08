local RapistVoices = {
	"vo/npc/female01/moan01.wav",
	"vo/npc/female01/moan02.wav",
	"vo/npc/female01/moan03.wav",
	"vo/npc/female01/moan04.wav",
	"vo/npc/female01/moan05.wav"
}

local TargetVoices = {
	"vo/npc/male01/moan01.wav",
	"vo/npc/male01/moan02.wav",
	"vo/npc/male01/moan03.wav",
	"vo/npc/male01/moan04.wav",
	"vo/npc/male01/moan05.wav"
}

local function PimpsCut()
	for k, v in pairs(player.GetAll()) do
		if v:Team() == rp.PimpTeam then
			v:AddMoney(100)
			rp.Notify(v, NOTIFY_GREEN, rp.Term('HoesProfit'))
		end
	end
end


local function DoFuck(pl, target)
	if rp.teams[target:Team()].Pimp then
		if (!target:CanAfford(250)) then
			rp.Notify(pl, NOTIFY_ERROR, rp.Term('CannotAffordHoe'), Target)
			rp.Notify(Target, NOTIFY_ERROR, rp.Term('YouCannotAffordHoe'), pl)

			return
		end

		pl:AddMoney(150)
		target:AddMoney(-250)
		PimpsCut()
	end

	for k,v in pairs(ents.FindInSphere(pl:GetPos(),200)) do
		if v:IsPlayer() && v:IsCP() && !pl:IsWanted() then
			pl:Wanted(v, "Prostitution")
			break
		end
	end

	rp.Notify(pl, NOTIFY_ERROR, rp.Term('LostKarmaNR'), 2)
	pl:AddKarma(-2)

	rp.Notify(Target, NOTIFY_ERROR, rp.Term('LostKarmaNR'), 2)
	Target:AddKarma(-2)

	local FuckTime = math.random(5,10)
	local Chance = math.random(1, 8)

	pl:Freeze(true)
	timer.Create("FuckSounds", 1.5, 0, function()
		pl:EmitSound(table.Random(RapistVoices), 500, 100)
		pl:ViewPunch(Angle(math.random(-1, 1), math.random(-1, 1), math.random(-10, 10)))
	end)

	Target:Freeze(true)
	timer.Create("TargetSounds", 1.5, 0, function()
		Target:EmitSound(table.Random(TargetVoices), 500, 100)
		Target:ViewPunch(Angle(math.random(-1, 1), math.random(-1, 1), math.random(-10, 10)))
	end)

	timer.Create("FuckUnFreeze", FuckTime, 1, function()
		pl:TakeHunger(10)
		Target:EmitSound("bot/hang_on_im_coming.wav")
		pl:Freeze(false)
		Target:TakeHunger(10)
		Target:EmitSound("ambient/voices/m_scream1.wav")
		Target:Freeze(false)
		if Chance == 3 then
			rp.Notify(Target, NOTIFY_ERROR, rp.Term('YouGotAIDS'))
			GiveSTD(Target)
		end
		if Chance == 4 then
			rp.Notify(pl, NOTIFY_ERROR, rp.Term('YouGotAIDS'))
			GiveSTD(pl)
		end
		timer.Destroy("FuckSounds")
		timer.Destroy("TargetSounds")
	end)
end

local function FuckPlayer(pl)
	local target = pl:GetEyeTrace().Entity

	if !IsValid(pl) then return end
	if !IsValid(target) then return end

	if pl:EyePos():DistToSqr(Target:GetPos()) > 19600 or !isplayer(target) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GetCloser'))
		return ""
	end

	if !pl:Alive() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('YouAreDead'))
		return
	end

	if rp.teams[pl:Team()].Hoe && !pl:IsSuperAdmin() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NotAHoe'))
		return
	end

	if target:IsNPC() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NPCsDontFuck'))
		return
	end

	if target:IsFrozen() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('TargetFrozen'))
		return
	end

	if (Target:IsGov()) && !pl:IsWanted() then
		pl:Wanted(nil, "Prostitution")
	end

	rp.Notify(pl, NOTIFY_GENERIC, term.Get('WaitingForAnswer'))

	local FuckCost = 250
	if rp.teams[target:Team()].Pimp then
		FuckCost = 0
	end

	rp.question.Create("Would you like to have sex with " ..  pl:Name() .. " for $" .. FuckCost .. "?", 30, "fuckyfucky" .. pl:UserID(), function(pl, answer)
		if tobool(answer) == false then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('TargetWontFuck'))
			return
		elseif tobool(answer) && pl:EyePos():DistToSqr(target:GetPos()) > 19600 or !target:IsPlayer() then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('TargetTooFar'))
			rp.Notify(target, NOTIFY_ERROR, term.Get('HoeTooFar'))
			return
		elseif tobool(answer) then
			DoFuck(pl, target)
			if rp.teams[target:Team()].Pimp then
				rp.Notify(pl, NOTIFY_GREEN, rp.Term('+FuckCostPimp'), FuckCost)
			else
				rp.Notify(pl, NOTIFY_GREEN, rp.Term('+Money'), FuckCost)
				rp.Notify(target, NOTIFY_ERROR, rp.Term('-Money'), FuckCost)
				return
			end
			rp.Notify(target, NOTIFY_ERROR, rp.Term('-Money'), FuckCost)
			return
		end
	end, false, target)

end
rp.AddCommand("sex", FuckPlayer)
rp.AddCommand("fuck", FuckPlayer)
