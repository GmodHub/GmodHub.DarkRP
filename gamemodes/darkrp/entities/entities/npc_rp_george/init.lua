dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

rp.AddCommand('buykarma', function(pl, karma)

	if karma <= 0 then return end
	local exploiter = true
	for k, v in ipairs(ents.FindInSphere(pl:GetPos(), 200)) do
		if IsValid(v) and (v:GetClass() == 'npc_rp_george') then
			exploiter = false
			break
		end
	end

	if exploiter then return end

	local price = math.floor(karma * rp.cfg.MoneyPerKarma)

	if not pl:CanAfford(price) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
	else
		pl:Notify(NOTIFY_GENERIC, term.Get('BoughtKarma'), karma, rp.FormatMoney(price))
		pl:TakeMoney(price)
		pl:AddKarma(karma)
	end
end)
:AddParam(cmd.NUMBER)

hook.Add("InitPostEntity", "rp.KarmaSellers", function()
	for k, v in ipairs(rp.cfg.KarmaSellers[game.GetMap()]) do
		local npc = ents.Create('npc_rp_george')
		npc:SetPos(v.Pos)
		npc:SetAngles(v.Ang)
		npc:Spawn()
		npc:Activate()
		npc:SetModel(npc.NPCModel)
	end
end)
