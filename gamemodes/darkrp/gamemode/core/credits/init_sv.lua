util.AddNetworkString 'rp.shop.Menu'

function PLAYER:HasUpgrade(uid)
	return (self:GetVar('Upgrades', {})[uid] ~= nil)
end

function PLAYER:AddCredits(amount, note, cback)
	rp.data.AddCredits(self:SteamID(), amount, note, function()
		self:SetNetVar('Credits', self:GetCredits() + amount)
		if (cback) then cback() end
	end)
end

function PLAYER:TakeCredits(amount, note, cback)
	rp.data.AddCredits(self:SteamID(), -amount, note, function()
		self:SetNetVar('Credits', self:GetCredits() - amount)
		if (cback) then cback() end
	end)
end

function PLAYER:GetUpgradeCount(uid)
	return (self:GetVar('Upgrades', {})[uid] or 0)
end

function PLAYER:GetPermaWeapons()
	return self:GetVar('PermaWeapons', {})
end

function PLAYER:GetSelectedPermaWeapons()
	return self:GetVar('SelectedPermaWeapons', {})
end

function rp.shop.OpenMenu(pl)
	if pl.OpeningCreditMenu then return end
	pl.OpeningCreditMenu = true

	rp.data.LoadCredits(pl, function()
		pl.OpeningCreditMenu = false
		local ret = {}

		for k, v in ipairs(rp.shop.GetTable()) do
			if (!v:CanSee(pl)) then continue end

			ret[v:GetID()] = {}

			local canbuy, reason = v:CanBuy(pl)
			if (!canbuy) then
				ret[v:GetID()].CanBuy = reason
			end

			ret[v:GetID()].Price = v:GetPrice(pl)

			ret[v:GetID()].UID = v:GetUID()
			ret[v:GetID()].Stackable = v:IsStackable()
		end

		net.Start('rp.shop.Menu')
			net.WriteUInt(table.Count(ret), 9)
			for k, v in pairs(ret) do
				net.WriteUInt(k, 9)

				if isstring(v.CanBuy) then
					net.WriteBool(false)
					net.WriteString(v.CanBuy)
					net.WriteBool(!v.Stackable and pl:HasUpgrade(v.UID))

					net.WriteUInt(v.Price, 32)
				else
					net.WriteBool(true)
					net.WriteBool(!v.Stackable and pl:HasUpgrade(v.UID))

					net.WriteUInt(v.Price, 32)
				end
			end
		net.Send(pl)
	end)
end
rp.AddCommand("upgrades", rp.shop.OpenMenu)

net("rp.shop.Menu", function( len, pl )
	rp.shop.OpenMenu(pl)
end)


-- Data
local db = rp._Credits


function rp.data.AddCredits(steamid, amount, note, cback)
	db:Query('INSERT INTO `kshop_credits_transactions` (`Time`, `SteamID`, `Change`, `Note`) VALUES(?, ?, ?, ?);', os.time(), steamid, amount, (note or ''), cback)
end

function rp.data.LoadCredits(pl, cback)
	db:Query('SELECT COALESCE(SUM(`Change`), 0) AS `Credits` FROM `kshop_credits_transactions` WHERE `SteamID`="' .. pl:SteamID() .. '";', function(data)
		if IsValid(pl) then
			pl:SetNetVar('Credits', tonumber(data[1]['Credits']))
			if cback then cback(data) end
		end
	end)
end

function rp.data.AddUpgrade(pl, id)
	local upg_obj = rp.shop.Get(id)
	local canbuy, reason = upg_obj:CanBuy(pl)

	if (not canbuy) then
		pl:Notify(NOTIFY_ERROR, term.Get('CantPurchaseUpgrade'), reason)
	else
		local cost = upg_obj:GetPrice(pl)
		pl:TakeCredits(cost, 'Purchase: ' .. upg_obj:GetUID(), function()
			db:Query("INSERT INTO `kshop_purchases` VALUES('" .. os.time() .. "', '" .. pl:SteamID() .. "', '" .. upg_obj:GetUID() .. "');", function(dat)
				for k, v in ipairs(player.GetAll()) do v:ChatPrint(pl:Name() .. " has bought " .. upg_obj:GetName() .. " with their credits!"); end

				local upgrades = pl:GetVar('Upgrades')
				upgrades[upg_obj:GetUID()] = upgrades[upg_obj:GetUID()] and (upgrades[upg_obj:GetUID()] + 1) or 1
				pl:SetVar('Upgrades', upgrades)

				local wep = rp.shop.Weapons[id]
				if (wep ~= nil) then
					weps[#weps + 1] = wep
				end

				upg_obj:OnBuy(pl)

				rp.shop.OpenMenu(pl)
			end)
		end)
	end
end

hook('PlayerAuthed', 'rp.shop.LoadCredits', function(pl)

	rp.data.LoadCredits(pl, function()
		if IsValid(pl) then
			pl:ChatPrint('You have ' .. pl:GetCredits() .. ' credits to spend.')
		end
	end)

	db:Query('SELECT `Upgrade` FROM `kshop_purchases` WHERE `SteamID`="' .. pl:SteamID() .. '";', function(data)
		if IsValid(pl) then

			local upgrades 	= {}
			local weps 		= {}

			for k, v in ipairs(data) do
				local uid = v.Upgrade
				local wep = rp.shop.Weapons[uid]
				upgrades[uid] = upgrades[uid] and (upgrades[uid] + 1) or 1

				if (wep ~= nil) then
					weps[#weps + 1] = wep
				end
			end

			pl:SetVar('Upgrades', upgrades)
			pl:SetVar('PermaWeapons', weps)
			hook.Call('PlayerUpgradesLoaded', nil, pl)
		end
	end)

end)

util.AddNetworkString("rp.PermaWeaponSettings")

net("rp.PermaWeaponSettings", function(len,pl)

	if (#pl:GetPermaWeapons() == 0) then return end

	local weapons = {}

	for i = 1, net.ReadUInt(8) do
		local weapon = rp.shop.Get(net.ReadUInt(8)):GetWeapon() or NULL

		if (isstring(weapon)) then
			weapons[weapon] = net.ReadBool()
		end
	end

	// Knifes
	for k,v in pairs(weapons) do
		if string.Left(k, 5) == "knife" then
			weapons[k] = false
		end
	end

	if net.ReadBool() then
		local weapon = rp.shop.Get(net.ReadUInt(8)):GetWeapon() or NULL

		if (isstring(weapon) and string.Left(weapon, 5) == "knife") then
			weapons[weapon] = true
		end
	end

	// Vapes
	if net.ReadBool() then
		local weapon = rp.shop.Get(net.ReadUInt(8)) or NULL

		if (isstring(weapon:GetWeapon())) then
			weapons[weapon:GetWeapon()] = weapon.ID
		end
	end

	if !pl:GetVar('SelectedPermaWeapons') then
		pl:SetVar('SelectedPermaWeapons', weapons)
		hook.Call('PlayerLoadout', nil, pl)
	else
		pl:SetVar('SelectedPermaWeapons', weapons)
	end



end)

hook('PlayerLoadout', 'rp.shop.PlayerLoadout', function(pl)
	local selected = pl:GetSelectedPermaWeapons()

	for k, v in ipairs(pl:GetPermaWeapons()) do
		if (selected[v]) then
			pl:Give(v)
			if (v == "weapon_vape") then
				pl:GetWeapon(v).Color = selected[v]
			end
		end
	end
end)

rp.AddCommand('buyupgrade', function(pl, args)
	if (not args) or (not rp.shop.Get(tonumber(args))) then return end
	rp.data.AddUpgrade(pl, tonumber(args))
end)
:AddParam(cmd.STRING)
