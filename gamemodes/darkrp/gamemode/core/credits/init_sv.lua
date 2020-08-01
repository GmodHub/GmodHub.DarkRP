util.AddNetworkString 'rp.shop.Menu'
util.AddNetworkString 'rp.PermaWeaponSettings'

-- Data
local db = rp._Credits

function PLAYER:HasUpgrade(uid)
	return (self:GetVar('Upgrades', {})[uid] ~= nil)
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

	db:Query('SELECT Credits FROM player_data WHERE SteamID=' .. pl:SteamID64() .. ';', function(data)
		if data[1] and data[1].Credits != pl:GetCredits() then
			ba.notify_all(pl:Name() .. " пополнил баланс на " .. math.Round(data[1].Credits - pl:GetCredits()) .. " кредитов!")
			pl:SetNetVar('Credits', data[1].Credits or 0)
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

function rp.data.AddUpgrade(pl, id)
	local upg_obj = rp.shop.Get(id)
	local canbuy, reason = upg_obj:CanBuy(pl)

	if (not canbuy) then
		pl:Notify(NOTIFY_ERROR, term.Get('CantPurchaseUpgrade'), reason)
	else
		local cost = upg_obj:GetPrice(pl)
		pl:TakeCredits(cost, 'Purchase: ' .. upg_obj:GetUID(), function()
			db:Query("INSERT INTO `player_upgrades` VALUES('" .. os.time() .. "', '" .. pl:SteamID() .. "', ?);", upg_obj:GetUID(), function(dat)
				ba.notify_all(pl:Name() .. " приобрёл " .. upg_obj:GetName() .. " за свои кредиты!")

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
	db:Query('SELECT `Upgrade` FROM `player_upgrades` WHERE `SteamID`="' .. pl:SteamID() .. '";', function(data)
		if IsValid(pl) then

			local upgrades 	= {}
			local weps 		= {}

			for k, v in ipairs(data) do
				local uid = v.Upgrade
				local wep = rp.shop.Weapons[uid]
				local upg = rp.shop.GetByUID(uid)
				upgrades[uid] = upgrades[uid] and (upgrades[uid] + 1) or 1

				if (wep ~= nil) then
					weps[#weps + 1] = wep
				end

				if (upg:IsNetworked()) then
					pl:SetNetVar('Upgrade_' .. uid, upgrades[uid])
				end
			end

			pl:SetVar('Upgrades', upgrades)
			pl:SetVar('PermaWeapons', weps)
			hook.Call('PlayerUpgradesLoaded', nil, pl)
		end
	end)
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

net("rp.PermaWeaponSettings", function(len,pl)
	if (#pl:GetPermaWeapons() == 0) then return end

	local weapons = {}

	for i = 1, (net.ReadUInt(8) or 0) do
		local weapon = rp.shop.Get(net.ReadUInt(8) or 1):GetWeapon() or NULL

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
		local upg = rp.shop.Get(net.ReadUInt(8) or 1)
		if not upg then return end
		local weapon = upg:GetWeapon() or NULL

		if (isstring(weapon) and string.Left(weapon, 5) == "knife") then
			weapons[weapon] = true
		end
	end

	// Vapes
	if net.ReadBool() then
		local weapon = rp.shop.Get(net.ReadUInt(8) or 1) or NULL

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

net("rp.shop.Menu", function( len, pl )
	rp.shop.OpenMenu(pl)
end)

rp.AddCommand("upgrades", rp.shop.OpenMenu)

rp.AddCommand('buyupgrade', function(pl, args)
	if (not args) or (not rp.shop.Get(tonumber(args))) then return end
	rp.data.AddUpgrade(pl, tonumber(args))
end)
:AddParam(cmd.STRING)

rp.AddCommand('promocode', function(pl, promo)
	promo = string.Trim(utf8.lower(promo))
	db:Query('SELECT * FROM `rp_promocodes` WHERE `code`=?;', promo, function(data)
		data = data[1]
		if not data or data.Amount <= 0 or data.Expire <= os.time() then pl:Notify(NOTIFY_ERROR, term.Get("PromocodeNotFound")) return end
		db:Query('SELECT * FROM `rp_promocodes_history` WHERE `SteamID`=? AND `code`=?;', pl:SteamID64(), promo, function(hist)
			if hist[1] then pl:Notify(NOTIFY_ERROR, term.Get("YouAlreadyUsedPromocode")) return end
			db:Query('UPDATE `rp_promocodes` SET `Amount`=`Amount`- 1 WHERE `code`=?;', promo, function()
				db:Query('INSERT INTO `rp_promocodes_history` (`SteamID`, `Code`, `Time`) VALUES (?, ?, ?)', pl:SteamID64(), promo, os.time(), function()
					pl:AddCredits(data.Reward)
					pl:Notify(NOTIFY_SUCCESS, term.Get("PromocodeActivated"), promo, rp.FormatCredits(data.Reward))
				end)
			end)
		end)
	end)
end)
:AddParam(cmd.STRING)
:SetCooldown(3)

ba.AddCommand('createpromocode', function(pl, promo, amount, reward, expire)
	promo = string.Trim(utf8.lower(promo))
	db:Query('REPLACE INTO `rp_promocodes`(`Code`, `Amount`, `Reward`, `Expire`) VALUES (?, ?, ?, ?)', promo, amount, reward, os.time() + expire, function()
		ba.notify(pl, term.Get("PromocodeCreated"), promo, rp.FormatCredits(reward), string.FormatTime(expire), amount)
	end)
end)
:AddParam(cmd.STRING)
:AddParam(cmd.NUMBER)
:AddParam(cmd.NUMBER)
:AddParam(cmd.TIME)
:SetFlag '*'