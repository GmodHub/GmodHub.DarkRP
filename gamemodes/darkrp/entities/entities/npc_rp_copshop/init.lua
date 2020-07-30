dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.NPCModel = 'models/Barney.mdl'

rp.AddCommand('copbuy', function(pl, itemid)
	if (not pl:IsGov()) then return end
	if (pl:GetEyeTrace().Entity:GetClass() ~= "npc_rp_copshop") then return end

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

hook.Add("InitPostEntity", "rp.CopShops", function()
	for k, v in ipairs(rp.cfg.CopShops[game.GetMap()]) do
		local npc = ents.Create('npc_rp_copshop')
		npc:SetPos(v.Pos)
		npc:SetAngles(v.Ang)
		npc:Spawn()
		npc:Activate()
		npc:SetModel(npc.NPCModel)
	end
end)
