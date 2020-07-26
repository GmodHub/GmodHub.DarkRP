AddCSLuaFile("cl_init.lua")
AddCSLuaFile("pocket_controls.lua")
AddCSLuaFile("pocket_vgui.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("Pocket.Load")
util.AddNetworkString("Pocket.RemoveItem")
util.AddNetworkString("Pocket.AddItem")
util.AddNetworkString("Pocket.AdminDelete")
util.AddNetworkString("rp.inv.Drop")

local wl = rp.inv.Wl

local model_translations = {
	['models/weapons/w_snip_awp.mdl']			= 'models/weapons/3_snip_awp.mdl',
	['models/weapons/w_rif_ak47.mdl']			= 'models/weapons/3_rif_ak47.mdl',
	['models/weapons/w_pist_deagle.mdl']		= 'models/weapons/3_pist_deagle.mdl',
	['models/weapons/w_rif_famas.mdl']			= 'models/weapons/3_rif_famas.mdl',
	['models/weapons/w_pist_fiveseven.mdl']	 	= 'models/weapons/3_pist_fiveseven.mdl',
	['models/weapons/w_smg_p90.mdl']			= 'models/weapons/3_smg_p90.mdl',
	['models/weapons/w_pist_glock18.mdl']		= 'models/weapons/3_pist_glock18.mdl',
	['models/weapons/w_snip_g3sg1.mdl']			= 'models/weapons/3_snip_g3sg1.mdl',
	['models/weapons/w_smg_mp5.mdl']			= 'models/weapons/3_smg_mp5.mdl',
	['models/weapons/w_smg_ump45.mdl']			= 'models/weapons/3_smg_ump45.mdl',
	['models/weapons/w_rif_galil.mdl']			= 'models/weapons/3_rif_galil.mdl',
	['models/weapons/w_smg_mac10.mdl']			= 'models/weapons/3_smg_mac10.mdl',
	['models/weapons/w_mach_m249para.mdl']	  	= 'models/weapons/3_mach_m249para.mdl',
	['models/weapons/w_shot_m3super90.mdl']	 	= 'models/weapons/3_shot_m3super90.mdl',
	['models/weapons/w_pist_p228.mdl']			= 'models/weapons/3_pist_p228.mdl',
	['models/weapons/w_snip_sg550.mdl']			= 'models/weapons/3_snip_sg550.mdl',
	['models/weapons/w_rif_sg552.mdl']			= 'models/weapons/3_rif_sg552.mdl',
	['models/weapons/w_rif_aug.mdl']			= 'models/weapons/3_rif_aug.mdl',
	['models/weapons/w_snip_scout.mdl']			= 'models/weapons/3_snip_scout.mdl',
	['models/weapons/w_smg_tmp.mdl']			= 'models/weapons/3_smg_tmp.mdl',
	['models/weapons/w_shot_xm1014.mdl']	    = 'models/weapons/3_shot_xm1014.mdl',
	['models/weapons/w_rif_m4a1.mdl']			= 'models/weapons/3_rif_m4a1.mdl',
	['models/weapons/w_pist_usp.mdl']			= 'models/weapons/3_pist_usp.mdl',
	['models/weapons/w_c4_planted.mdl']			= 'models/weapons/2_c4_planted.mdl',
	['models/weapons/3_357.mdl']				= 'models/weapons/w_357.mdl',
}

local pocketBits = 8

function PLAYER:GetInv()
	return rp.inv.Data[self:SteamID64()] or {}
end

function PLAYER:SaveInv()
	rp.data.SetPocket(self:SteamID64(), pon.encode(self:GetInv()))
end

function PLAYER:SendInv(pl)
	if not pl then pl = self end
	net.Start("Pocket.Load")
		net.WriteUInt(table.Count(self:GetInv()), pocketBits)
		for k,v in pairs(self:GetInv()) do
			net.WriteUInt(k, pocketBits)

			net.WriteUInt(1, pocketBits+1)
			net.WriteUInt(2, pocketBits+1)

			net.WriteBit(0)

			net.WriteUInt(table.Count(v), pocketBits+1)
			for a,b in pairs(v) do
				net.WriteString(b)
			end
		end
	net.Send(pl)
end

if !ID then ID = 1 end

local function GetEntityInfo(ent)
	local c = ent:GetClass()

	local tab = {}
	tab.Class = c
	tab.Model = ent:GetModel()

	local title = "Неизвестно"
	local subtitle = ""

	if (c == "spawned_shipment") then
		tab.contents = ent.dt.contents
		tab.count = ent.dt.count
		if ent.dt.count > 0 then
			title = rp.shipments[tab.contents].name
			subtitle = "Количество: " .. tab.count
		else
			title = "Пусто"
		end
	elseif (c == "spawned_food") then
		tab.FoodEnergy = ent.FoodEnergy
		title = "Еда"
		subtitle = "Сытность: " .. tab.FoodEnergy
	elseif (c == "spawned_weapon") then
		tab.weaponclass = ent.weaponclass
		if ent.number then tab.number = ent.number end
		if ent.clip1 then tab.clip1 = ent.clip1 subtitle = ent.clip1 .. " Патрон" end
		if ent.clip2 then tab.clip2 = ent.clip2 end
		if ent.ammoadd then tab.ammoadd = ent.ammoadd end

		if rp.WeaponsMap[ent.weaponclass] then
			title = rp.WeaponsMap[ent.weaponclass].Name
		end
	else
		title = wl[c]
	end

	return tab, title, subtitle
end

local function Finalize(ent, tab, owner)
	local c = ent:GetClass()

	tab.Model = model_translations[tab.Model] or tab.Model

	if (c == "spawned_shipment") then
		ent:SetContents(tab.contents, tab.count)
	elseif (c == "spawned_food") then
		ent:SetModel(tab.Model)
		ent.FoodEnergy = tab.FoodEnergy
	elseif (c == "spawned_weapon") then
		ent:SetModel(tab.Model)
		ent.weaponclass = tab.weaponclass

		if tab.clip1 then ent.clip1 = tab.clip1 end
		if tab.clip2 then ent.clip2 = tab.clip2 end
		if tab.ammoadd then ent.ammoadd = tab.ammoadd end
		if tab.number then ent.number = tab.number end
	end

	ent:Spawn()
end

net.Receive("rp.inv.Drop", function(len, pl)
	if (not rp.data.IsLoaded(p)) then return end
	local pock = pl:GetInv()

	a = net.ReadUInt(32)

	if (pock[a]) then
		local item = pock[a]

		local ent_class = item.Class

		local ent = ents.Create(ent_class)
		local trace = {}
			trace.start = pl:EyePos()
			trace.endpos = trace.start + pl:GetAimVector() * 85
			trace.filter = pl
		local tr = util.TraceLine(trace)
		ent:SetPos(tr.HitPos + Vector(0, 0, 10))

		Finalize(ent, item, pl)
	end

	pl:GetInv()[a] = nil
	pl:SaveInv()
	net.Start("Pocket.RemoveItem")
		net.WriteUInt(a, pocketBits)
	net.Send(pl)
end)

function SWEP:Reload()
	if self.Owner:HasWeapon("keys") then
		self.Owner:SelectWeapon("keys")
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	if (not rp.data.IsLoaded(self.Owner)) then return end

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity
	if not IsValid(ent) or not IsValid(ent:GetPhysicsObject()) or (self.Owner:EyePos():Distance(tr.HitPos) > 65) then return end

	if (!wl[ent:GetClass()]) then
		self.Owner:Notify(NOTIFY_ERROR, term.Get('CannotPocket'), ent.PrintName)
		return
	end

	local Limit = 8 + (2 * (self.Owner:GetUpgradeCount("pocket_space_2") and self.Owner:GetUpgradeCount("pocket_space_2") or 0))

	local p = self.Owner:GetInv()
	if (table.Count(p) >= Limit) then
		self.Owner:ChatPrint("Ваш карман полн!")
		return
	end

	local tab, title, subtitle = GetEntityInfo(ent)

	net.Start("Pocket.AddItem")
		net.WriteUInt(ID, pocketBits)
		net.WriteString(title)
		net.WriteString(subtitle)
		net.WriteString(tab.Model)
	net.Send(self.Owner)

	ent:Remove()

	p[ID] = tab

	self.Owner:SaveInv()

	ID = ID + 1
end

net.Receive("Pocket.AdminDelete", function(len, pl)
	if (!pl:IsSuperAdmin()) then return end

	local targ = net.ReadEntity()
	local id = net.ReadUInt(32)
	local inv = targ:GetInv()

	if (!inv[id]) then return end

	local item = inv[id]
	local itemName = (item.contents and rp.shipments[item.contents].name .. ' (число: ' .. item.count .. ')') or rp.inv.Wl[item.Class]

	targ:GetInv()[id] = nil
	targ:SaveInv()
	net.Start("Pocket.RemoveItem")
		net.WriteUInt(id, pocketBits)
	net.Send(targ)

	ba.notify(targ, '# было убрано # из кармана.', pl, itemName)
	ba.notify(pl, 'Убрано # из #\'s кармана.', itemName, targ)
end)
