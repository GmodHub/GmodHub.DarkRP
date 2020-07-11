dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

rp.AddCommand('buykarma', function(pl, itemid)

	local exploiter = true
	for k, v in ipairs(ents.FindInSphere(pl:GetPos(), 200)) do
		if IsValid(v) and (v:GetClass() == 'npc_rp_george') then
			exploiter = false
			break
		end
	end

	if exploiter then return end

	local item = rp.CopItems[itemid]

	if not pl:CanAfford(item.Price) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
	else
		pl:Notify(NOTIFY_GENERIC, term.Get('RPItemBought'), item.Name, rp.FormatMoney(item.Price))
		pl:TakeMoney(item.Price)
		if item.Weapon then
			pl:Give(item.Weapon)
		else
			item.Callback(pl)
		end

	end
end)
:AddParam(cmd.STRING)

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
