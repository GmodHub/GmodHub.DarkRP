util.AddNetworkString("rp.PooPeePiss")

local function MakePoo(player)
	local turd = ents.Create("ent_poop")
	turd:SetPos(player:GetPos() + Vector(0,0,32))
	turd:Spawn()
	player:EmitSound("ambient/levels/canals/swamp_bird2.wav", 50, 80)
	timer.Simple(30, function() if turd:IsValid() then turd:Remove() end end)
end

rp.AddCommand("poop", function(pl)
	if !pl:Alive() then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('YouAreDead'))
		return
	end

	if pl.NextPoo != nil && pl.NextPoo >= CurTime() then
			if math.random(1, 5) == 5 then
				MakePoo(pl)
				pl:Kill()
				pl.CurrentDeathReason = 'Prolapse'
				rp.Notify(pl, NOTIFY_ERROR, term.Get('AnalProlapse'))
				return
			end
			rp.Notify(pl, NOTIFY_ERROR, term.Get('NoMorePoo'))
		return
	end
	pl.NextPoo = CurTime() + 10
	MakePoo(pl)
end)

rp.AddCommand("piss", function(pl)

	if !pl:Alive() then
			rp.Notify(pl, NOTIFY_ERROR, term.Get('YouAreDead'))
		return
	end

	if pl.NextPee != nil && pl.NextPee >= CurTime() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('NoMorePoo'))
		return
	end

	pl.NextPee = CurTime() + 30

	net.Start("rp.PooPeePiss")
		net.WritePlayer(pl)
	net.Broadcast()

end)
