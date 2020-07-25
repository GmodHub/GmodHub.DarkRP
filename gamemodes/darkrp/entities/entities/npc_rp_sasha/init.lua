dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.NPCModel = 'models/Humans/Group03/male_02.mdl'

function ENT:StartTouch(ent)
	local owner = ent.WeaponOwner
	if IsValid(ent) and IsValid(owner) and owner:HasLicense() then
		local info = ent.WeaponInfo
		local price = math.Round(info.BuyPrice * (nw.GetGlobal('SashaPrice') or 1))

		ent:Remove()
		owner:AddMoney(price)
		rp.Notify(owner, NOTIFY_GREEN, term.Get('PlayerSoldDrugs'), info.Name, rp.FormatMoney(price))
	end
end

hook.Add('GravGunOnPickedUp', 'rp.GunBuyer.GravGunOnPickedUp', function(pl, ent)
	local tab = rp.WeaponsMap[ent:GetClass()] or rp.WeaponsMap[ent.weaponclass]
	if tab then
		ent.WeaponOwner = pl
		ent.WeaponInfo = tab
	end
end)

hook.Add('GravGunOnDropped', 'rp.GunBuyer.GravGunOnDropped', function(pl, ent)
	local tab = rp.WeaponsMap[ent:GetClass()] or rp.WeaponsMap[ent.weaponclass]
	if tab then
		ent.WeaponOwner = nil
		ent.WeaponInfo = nil
	end
end)

hook.Add("InitPostEntity", "rp.GunBuyers", function()
	for k, v in ipairs(rp.cfg.GunBuyers[game.GetMap()]) do
		local npc = ents.Create('npc_rp_sasha')
		npc:SetPos(v.Pos)
		npc:SetAngles(v.Ang)
		npc:Spawn()
		npc:Activate()
		npc:SetModel(npc.NPCModel)
	end

	timer.Create("SashaPrice", 900, 0, function()
		nw.SetGlobal("SashaPrice", math.Rand(0.40, 2))
	end)
end)
