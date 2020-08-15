dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.NPCModel = 'models/Humans/Group01/male_03.mdl'

function ENT:StartTouch(ent)
	local owner = ent.DrugOwner
	if IsValid(ent) and IsValid(owner) then
		local info = ent.DrugInfo
		local price = math.Round(info.BuyPrice * (nw.GetGlobal('JeromePrice') or 1))

		ent:Remove()
		owner:AddMoney(price)
		rp.Notify(owner, NOTIFY_GREEN, term.Get('PlayerSoldDrugs'), info.Name, rp.FormatMoney(info.BuyPrice))
	end
end

hook.Add('GravGunOnPickedUp', 'rp.drugbuyer.GravGunOnPickedUp', function(pl, ent)
	local tab = rp.DrugsMap[ent:GetClass()]  or rp.DrugsMap[ent.weaponclass]
	if tab then
		ent.DrugOwner = pl
		ent.DrugInfo = tab
	end
end)

hook.Add('GravGunOnDropped', 'rp.drugbuyer.GravGunOnDropped', function(pl, ent)
	local tab = rp.DrugsMap[ent:GetClass()]  or rp.DrugsMap[ent.weaponclass]
	if tab then
		ent.DrugOwner = nil
		ent.DrugInfo = nil
	end
end)

hook.Add("InitPostEntity", "rp.DrugBuyers", function()
	for k, v in ipairs(rp.cfg.DrugBuyers[game.GetMap()]) do
		local npc = ents.Create('npc_rp_jerome')
		npc:SetPos(v.Pos)
		npc:SetAngles(v.Ang)
		npc:Spawn()
		npc:Activate()
		npc:SetModel(npc.NPCModel)
	end

	timer.Create("JeromePrice", 600, 0, function()
		nw.SetGlobal("JeromePrice", math.Rand(0.50, 1.50))
		rp.FlashNotify(table.Filter(player.GetAll(), function(v) return rp.teams[v:Team()].drugDealer end), "Уведомления Шушеры", "Цены Шушеры изменились на " .. math.Round(100 * (nw.GetGlobal('JeromePrice') or 1)) .. "% от цены наркотиков.")
	end)
end)
