-- Misc
/*rp.shop.Add('Random Drop', 'random_drop')
	:SetCat('General')
	:SetDesc('Buying this upgrade has a 50% chance of giving you a random upgrade')
	:SetPrice(1000)
	:SetStackable(false)
	:SetOnBuy(function(self, pl)
		#rp.shop.Stored
		rp.data.AddUpgrade(pl, id)
	end)*/


rp.shop.Add('+2 Pocket Space', 'pocket_space_2')
	:SetCat('General')
	:SetDesc('Increases your total pocket space by 2.\n This upgrade is stackable.')
	:SetImage('004-clothing.png')
	:SetPrice(300)
	:SetNetworked(true)
	:SetGetPrice(function(self, pl)
		local cost = 0
		if pl:HasUpgrade(self:GetUID()) then
			cost = self.Price * (pl:GetUpgradeCount(self:GetUID()) * 0.5)
		end
		return self.Price + cost
	end)

rp.shop.Add('Perma Ammo', 'perma_ammo')
	:SetCat('General')
	:SetDesc('You will forever spawn with 120 of each ammo type')
	:SetImage('bullets.png')
	:SetPrice(500)
	:SetStackable(false)
	:SetOnBuy(function(self, pl)
		pl:GiveAmmos(120, true)
	end)
	:AddHook('PlayerUpgradesLoaded', function(pl)
		pl:GiveAmmos(120, true)
	end)
	:AddHook('PlayerLoadout', function(pl)
		pl:GiveAmmos(120, true)
	end)

rp.shop.Add('Premium Org', 'org_prem')
	:SetCat('General')
	:SetDesc([[
		This will upgrade the Org that you're in
		EVEN IF YOU ARE NOT THE OWNER!

		- Allows access to Org banners
		- Raises max members from 50 to 100
		- Raises max ranks from 5 to 20
		- Allows unlimited bank size
	]])
	:SetImage('org_banner.png')
	:SetPrice(750)
	:SetNetworked(true)
	:SetCanBuy(function(self, pl)
		local org = pl:GetOrgInstance()
		if (!org or org:IsUpgraded()) then
			return false, (org and (org.Name .. " is already upgraded.") or "You're not in an org!")
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		local org = pl:GetOrgInstance()
		if (org) then
			org:Upgrade()
		end
	end)
	:SetGetCustomPurchaseNote(function(self, pl)
		local org = pl:GetOrgInstance()
		if (org) then
			return org.ID .. '-' .. org.Name
		end
		return 'ERR'
	end)

rp.shop.Add('+15 Prop limit', 'prop_limit_15')
	:SetCat('General')
	:SetDesc('Adds 15 extra props to your prop limit.\n This upgrade is stackable.')
	:SetIcon('models/weapons/w_toolgun.mdl')
	:SetPrice(2000)
	:SetGetPrice(function(self, pl)
		return ((pl:GetUpgradeCount('prop_limit_15') + 1) * self.Price)
	end)


if (SERVER) then
	hook('PlayerGetLimit', 'rp.upgrades.Props', function(pl, name)
		local new = rp.GetLimit('props')
		if (name == 'props') then
			if pl:IsVIP() then
				new = new + 20
			end

			local upgradeCount = pl:GetUpgradeCount('prop_limit_15')
			if (upgradeCount ~= 0) then
				new = new + (15 * upgradeCount)
			end

			return new
		end
	end)
end

local sayings = {
	'# is a sexy beast!',
	'# has paid $2.50 to look cool in front of everyone',
	'# is love # is life',
	'° ͜ʖ ͡° # ͡° ͜ʖ ͡°',
	'Everyone tell # how cool they are',
	'Winner winner chicken dinner! # bought an announcement!',
	'# is as cool as a cucumber',
	'# has spent $2.50 so I, the server, must inform you all that they are cool',
}
rp.shop.Add('Announcement', 'announcement')
	:SetCat('General')
	:SetDesc('If you\'re bored and have $2.50 to blow, you may as well buy this and let the whole server know how cool you are.')
	:SetImage('005-megaphone.png')
	:SetPrice(250)
	:SetOnBuy(function(self, pl)
		local msg = string.gsub(sayings[math.random(#sayings)], '#', pl:Name())
		RunConsoleCommand('ba', 'tellall', msg)
	end)

-- Cash Packs
rp.shop.Add('$10,000', '10k_RP_Cash')
	:SetCat('Cash Packs')
	:SetDesc('Adds $10,000 to your account')
	:SetImage('money-1.png')
	:SetPrice(150)
	:SetOnBuy(function(self, pl)
		pl:AddMoney(10000)
	end)

rp.shop.Add('$50,000', '50k_RP_Cash')
	:SetCat('Cash Packs')
	:SetDesc('Adds $50,000 to your account')
	:SetImage('money-2.png')
	:SetPrice(500)
	:SetOnBuy(function(self, pl)
		pl:AddMoney(50000)
	end)

rp.shop.Add('$100,000', '100k_RP_Cash')
	:SetCat('Cash Packs')
	:SetDesc('Adds $100,000 to your account')
	:SetImage('money-3.png')
	:SetPrice(750)
	:SetOnBuy(function(self, pl)
		pl:AddMoney(100000)
	end)

rp.shop.Add('$250,000', '250k_RP_Cash')
	:SetCat('Cash Packs')
	:SetDesc('Adds $250,000 to your account')
	:SetImage('money-4.png')
	:SetPrice(1000)
	:SetOnBuy(function(self, pl)
		pl:AddMoney(250000)
	end)

rp.shop.Add('$750,000', '750k_RP_Cash')
	:SetCat('Cash Packs')
	:SetDesc('Adds $750,000 to your account')
	:SetImage('profits.png')
	:SetPrice(2000)
	:SetOnBuy(function(self, pl)
		pl:AddMoney(750000)
	end)


-- Karma Packs
rp.shop.Add('200 Karma', '200_karma')
	:SetCat('Karma Packs')
	:SetDesc('Adds 200 karma to your account')
	:SetImage('karma-1.png')
	:SetPrice(150)
	:SetOnBuy(function(self, pl)
		pl:AddKarma(200)
	end)

rp.shop.Add('750 Karma', '750_karma')
	:SetCat('Karma Packs')
	:SetDesc('Adds 750 karma to your account')
	:SetImage('karma-2.png')
	:SetPrice(500)
	:SetOnBuy(function(self, pl)
		pl:AddKarma(750)
	end)

rp.shop.Add('1,500 Karma', '1500_karma')
	:SetCat('Karma Packs')
	:SetDesc('Adds 1,500 karma to your account')
	:SetImage('karma-3.png')
	:SetPrice(750)
	:SetOnBuy(function(self, pl)
		pl:AddKarma(1500)
	end)

rp.shop.Add('3,000 Karma', '3000_karma')
	:SetCat('Karma Packs')
	:SetDesc('Adds 3,000 karma to your account')
	:SetImage('karma-4.png')
	:SetPrice(1000)
	:SetOnBuy(function(self, pl)
		pl:AddKarma(3000)
	end)

rp.shop.Add('7,500 Karma', '7500_karma')
	:SetCat('Karma Packs')
	:SetDesc('Adds 7,500 karma to your account')
	:SetImage('karma-5.png')
	:SetPrice(2000)
	:SetOnBuy(function(self, pl)
		pl:AddKarma(7500)
	end)



-- Ranks
local vipdesc = [[
		VIP rank across all of our DarkRP servers
		VIP forum rank
		VIP jobs
		VIP scoreboard icon
		Chatbox emotes
		Reserved slots
		20 extra props
		3 extra genome points for cops
		Adv Dupe tool
		Precision tool

		And anything else that gets added for VIPs in the future!
	]]

rp.shop.Add('30 Day VIP', 'trial_vip')
	:SetCat('Ranks')
	:SetDesc(vipdesc)
	:SetImage('vip-30d.png')
	:SetPrice(1000)
	:SetCanBuy(function(self, pl)
		if (pl:GetRank() == 'vip') or pl:IsAdmin() then
			return false, 'You\'re already VIP or higher!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'setgroup', pl:SteamID(), 'vip', '30d', 'user')
	end)


rp.shop.Add('Permanent VIP', 'vip')
	:SetCat('Ranks')
	:SetDesc(vipdesc)
	:SetImage('vip-perma.png')
	:SetPrice(1500)
	:SetCanBuy(function(self, pl)
		if (pl:GetRank() == 'vip') or pl:IsAdmin() then
			return false, 'You\'re already VIP or higher!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'setgroup', pl:SteamID(), 'vip')
	end)


rp.shop.Add('30 Days Moderator', 'trial_mod')
	:SetCat('Ranks')
	:SetDesc([[
		30 days of moderator across all of our DarkRP servers
		Moderator forum rank
		All VIP perks forever:
			VIP jobs
			Chatbox emotes
			Reserved slots
			20 extra props
			3 extra genome points for cops
			Adv Dupe tool
			Precision tool

			And anything else that gets added for VIPs in the future

		If you're already a moderator, this will extend your time.
		WARNING: If you abuse this rank or go inactive you will be set to VIP without refund!
	]])
	:SetImage('mod-30d.png')
	:SetPrice(2500)
	:SetCanBuy(function(self, pl)
		if pl:IsAdmin() and pl:GetRank() != 'moderator' then
			return false, 'You\'re already higher than moderator!'
		elseif (pl:GetPlayTime() < 36000) then
			return false, 'You need 10 hours play time to purchase moderator!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		local timeInSeconds = 30 * 86400
		local startTime = math.max((pl:GetRank() == 'moderator' and pl:GetBVar('expire_time') or os.time()), os.time())

		ba.data.SetRank(pl, 'moderator', 'vip', startTime + timeInSeconds)
	end)

rp.shop.Add('60 Days Moderator', 'trial_mod_60d')
	:SetCat('Ranks')
	:SetDesc([[
		60 days of moderator across all of our DarkRP servers
		Moderator forum rank
		All VIP perks forever:
			VIP jobs
			Chatbox emotes
			Reserved slots
			20 extra props
			3 extra genome points for cops
			Adv Dupe tool
			Precision tool

			And anything else that gets added for VIPs in the future

		If you're already a moderator, this will extend your time.
		WARNING: If you abuse this rank or go inactive you will be set to VIP without refund!
	]])
	:SetImage('mod-60d.png')
	:SetPrice(3500)
	:SetCanBuy(function(self, pl)
		if pl:IsAdmin() and pl:GetRank() != 'moderator' then
			return false, 'You\'re already higher than moderator!'
		elseif (pl:GetPlayTime() < 36000) then
			return false, 'You need 10 hours play time to purchase moderator!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		local timeInSeconds = 60 * 86400
		local startTime = math.max((pl:GetRank() == 'moderator' and pl:GetBVar('expire_time') or os.time()), os.time())

		ba.data.SetRank(pl, 'moderator', 'vip', startTime + timeInSeconds)
	end)


-- Events
rp.shop.Add('Parkour Event', 'event_parkour')
	:SetCat('Events')
	:SetDesc('Everyone will be able to use the climb swep.\nLasts 30 minutes.')
	:SetImage('parkour.png')
	:SetPrice(300)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('Parkour') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'Parkour', '30mi')
	end)

rp.shop.Add('Vape Event', 'event_vape')
	:SetCat('Events')
	:SetDesc('Everyone will spawn with a vape.\nLasts 30 minutes.')
	:SetIcon('models/swamponions/vape.mdl')
	:SetPrice(300)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('Vape') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'Vape', '30mi')
	end)


rp.shop.Add('VIP Event', 'event_vip')
	:SetCat('Events')
	:SetDesc('Everyone will be able to use VIP perks.\nLasts 30 minutes.')
	:SetImage('ticket.png')
	:SetPrice(350)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('VIP') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'VIP', '30mi')
	end)

rp.shop.Add('Printer Event', 'event_printer')
	:SetCat('Events')
	:SetDesc('Everyone\'s printers will print 50% more.\nLasts 30 minutes.')
	:SetIcon('models/sup/printer/printer.mdl')
	:SetPrice(450)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('Printer') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'printer', '30mi')
	end)

rp.shop.Add('Crafting Event', 'event_crafting')
	:SetCat('Events')
	:SetDesc('Everyone\'s labs will craft 25% faster.\nLasts 30 minutes.')
	:SetIcon('models/props/cs_italy/it_mkt_table3.mdl')
	:SetPrice(450)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('Crafting') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'crafting', '30mi')
	end)

rp.shop.Add('BURGATRON', 'event_burger')
	:SetCat('Events')
	:SetDesc('Players spawn with BURGATRON to turn into burgers, and can eat each other to escape hunger.\nLasts 30 minutes.')
	:SetIcon('models/food/burger.mdl')
	:SetPrice(300)
	:SetCanBuy(function(self, pl)
		if rp.EventIsRunning('BURGATRON') then
			return false, 'This event is already running!'
		end
		return true
	end)
	:SetOnBuy(function(self, pl)
		RunConsoleCommand('ba', 'startevent', 'burgatron', '30mi')
	end)


-- Permanent Weapons
rp.shop.Add('Dab', 'perma_dab')
	:SetCat('Permanent Weapons')
	:SetImage('dab.png')
	:SetPrice(350)
	:SetWeapon('weapon_dab')

rp.shop.Add('Camera', 'perma_camera')
	:SetCat('Permanent Weapons')
	:SetIcon('models/MaxOfS2D/camera.mdl')
	:SetPrice(350)
	:SetWeapon('gmod_camera')

rp.shop.Add('Bug Bait', 'bug_bait')
	:SetCat('Permanent Weapons')
	:SetIcon('models/weapons/w_bugbait.mdl')
	:SetPrice(350)
	:SetWeapon('weapon_bugbait')

rp.shop.Add('Crowbar', 'perma_crowbar')
	:SetCat('Permanent Weapons')
	:SetPrice(900)
	:SetWeapon('weapon_crowbar')
	:SetIcon('models/weapons/w_crowbar.mdl')

rp.shop.Add('Stunstick', 'perma_stunstick')
	:SetCat('Permanent Weapons')
	:SetPrice(900)
	:SetWeapon('weapon_stunstick')
	:SetIcon('models/weapons/w_stunbaton.mdl')

rp.shop.Add('Fists', 'perma_fists')
	:SetCat('Permanent Weapons')
	:SetImage('boxing-gloves.png')
	:SetPrice(900)
	:SetWeapon('weapon_combo_fists')

rp.shop.Add('Climb Swep', 'climb_swep')
	:SetCat('Permanent Weapons')
	:SetImage('parkour.png')
	:SetPrice(1000)
	:SetWeapon('climb_swep')

rp.shop.Add('Pimp Hand', 'perma_pimphand')
	:SetCat('Permanent Weapons')
	:SetImage('pimp.png')
	:SetPrice(1000)
	:SetWeapon('weapon_pimphand')

rp.shop.Add('Fiveseven', 'perma_fiveseven')
	:SetCat('Permanent Weapons')
	:SetPrice(1000)
	:SetWeapon('swb_fiveseven')
	:SetIcon('models/weapons/3_pist_fiveseven.mdl')

rp.shop.Add('P228', 'perma_p228')
	:SetCat('Permanent Weapons')
	:SetPrice(1000)
	:SetWeapon('swb_p228')
	:SetIcon('models/weapons/3_pist_p228.mdl')

rp.shop.Add('USP .45', 'perma_usp')
	:SetCat('Permanent Weapons')
	:SetPrice(1000)
	:SetWeapon('swb_usp')
	:SetIcon('models/weapons/3_pist_usp.mdl')

rp.shop.Add('.357 Magnum', 'perma_357')
	:SetCat('Permanent Weapons')
	:SetPrice(1500)
	:SetWeapon('swb_357')
	:SetIcon('models/weapons/w_357.mdl')

rp.shop.Add('Desert Eagle', 'perma_deagle')
	:SetCat('Permanent Weapons')
	:SetPrice(1500)
	:SetWeapon('swb_deagle')
	:SetIcon('models/weapons/3_pist_deagle.mdl')

rp.shop.Add('Glock-18', 'perma_glock')
	:SetCat('Permanent Weapons')
	:SetPrice(1500)
	:SetWeapon('swb_glock18')
	:SetIcon('models/weapons/3_pist_glock18.mdl')

rp.shop.Add('Taser', 'perma_taser')
	:SetCat('Permanent Weapons')
	:SetIcon('models/weapons/w_pistol.mdl')
	:SetPrice(1500)
	:SetWeapon('weapon_taser')

-- Permanent Weapons - high price
rp.shop.Add('Grenade', 'perma_grenade')
	:SetCat('Permanent Weapons')
	:SetPrice(12500)
	:SetWeapon('weapon_frag')
	:SetDesc('Yes, you really spawn with a perma grenade. If you buy this you have a spending problem, thank you for your money :)')
	:SetIcon('models/weapons/w_grenade.mdl')
	:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)

		RunConsoleCommand('ba', 'tellall', 'Everyone thank ' .. pl:Name() .. ' for wasting $125 on a perma grenade.')
	end)

rp.shop.Add('Slam', 'perma_slam')
	:SetCat('Permanent Weapons')
	:SetPrice(25000)
	:SetWeapon('weapon_slam')
	:SetDesc('Yes, you really spawn with a perma slam. If you buy this you have a spending problem, thank you for your money :)')
	:SetIcon('models/weapons/w_slam.mdl')
	:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)

		RunConsoleCommand('ba', 'tellall', 'Everyone thank ' .. pl:Name() .. ' for wasting $250 on a perma slam.')
	end)

rp.shop.Add('Crossbow', 'perma_crossbow')
	:SetCat('Permanent Weapons')
	:SetPrice(50000)
	:SetWeapon('weapon_crossbow')
	:SetDesc('Yes, you really spawn with a perma crossbow. If you buy this you have a spending problem, thank you for your money :)')
	:SetIcon('models/weapons/w_crossbow.mdl')
	:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)

		RunConsoleCommand('ba', 'tellall', 'Everyone thank ' .. pl:Name() .. ' for wasting $500 on a perma crossbow.')
	end)

rp.shop.Add('RPG', 'perma_rpg')
	:SetCat('Permanent Weapons')
	:SetPrice(100000)
	:SetWeapon('weapon_rpg')
	:SetDesc('Yes, you really spawn with a perma RPG. If you buy this you have a spending problem, thank you for your money :)')
	:SetIcon('models/weapons/w_rocket_launcher.mdl')
	:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)

		RunConsoleCommand('ba', 'tellall', 'Everyone thank ' .. pl:Name() .. ' for wasting $1000 on a perma RPG.')
	end)

rp.shop.Add('C4', 'perma_c4')
	:SetCat('Permanent Weapons')
	:SetPrice(200000)
	:SetWeapon('weapon_c4')
	:SetDesc('Yes, you really spawn with a perma C4. If you buy this you have a spending problem, thank you for your money :)')
	:SetIcon('models/weapons/2_c4_planted.mdl')
	:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)

		RunConsoleCommand('ba', 'tellall', 'Everyone thank ' .. pl:Name() .. ' for wasting $2000 on a perma C4.')
	end)

-- Add ALL the knife skins!
--name, ent, w_model, texture, skinindex
local permaKnives = {
	{
		'perma_knife_bayonet_knife_|_night',
	 	'Bayonet | Night',
	 	'knife_bayonet_night',
	 	'models/weapons/w_csgo_bayonet.mdl',
	 	'models/csgo_knife/knife_bayonet_night.vmt',
		7,
	},
		{
		'perma_knife_shadow_daggers_|_fade',
	 	'Shadow Daggers | Fade',
	 	'knife_daggers_fade',
	 	'models/weapons/w_csgo_push.mdl',
	 	'models/csgo_knife/knife_push_fade.vmt',
		5,
	},
		{
		'perma_knife_butterfly_knife_|_slaughter',
	 	'Butterfly | Slaughter',
	 	'knife_butterfly_slaughter',
	 	'models/weapons/w_csgo_butterfly.mdl',
	 	'models/csgo_knife/knife_butterfly_slaughter.vmt',
		8,
	},
		{
		'perma_knife_huntsman_knife_|_tiger_tooth',
	 	'Huntsman | Tiger Tooth',
	 	'knife_huntsman_tiger',
	 	'models/weapons/w_csgo_tactical.mdl',
	 	'models/csgo_knife/knife_tactical_tiger.vmt',
		9,
	},
		{
		'perma_knife_huntsman_knife_|_boreal_forest',
	 	'Huntsman | Boreal Forest',
	 	'knife_huntsman_boreal',
	 	'models/weapons/w_csgo_tactical.mdl',
	 	'models/csgo_knife/knife_tactical_boreal.vmt',
		1,
	},
		{
		'perma_knife_gut_knife_|_case_hardened',
	 	'Gut | Case Hardened',
	 	'knife_gut_case',
	 	'models/weapons/w_csgo_gut.mdl',
	 	'models/csgo_knife/knife_gut_case.vmt',
		2,
	},
		{
		'perma_knife_bowie_knife',
	 	'Bowie Knife',
	 	'knife_bowie',
	 	'models/weapons/w_csgo_bowie.mdl',
	},
		{
		'perma_knife_falchion_knife_|_crimson_webs',
	 	'Falchion | Crimson Webs',
	 	'knife_falchion_crimsonwebs',
	 	'models/weapons/w_csgo_falchion.mdl',
	 	'models/csgo_knife/knife_falchion_crimsonwebs.vmt',
		3,
	},
		{
		'perma_knife_flip_knife_|_fade',
	 	'Flip | Fade',
	 	'knife_flip_fade',
	 	'models/weapons/w_csgo_flip.mdl',
	 	'models/csgo_knife/knife_flip_fade.vmt',
		6,
	},
		{
		'perma_knife_bayonet_knife_|_slaughter',
	 	'Bayonet | Slaughter',
	 	'knife_bayonet_slaughter',
	 	'models/weapons/w_csgo_bayonet.mdl',
	 	'models/csgo_knife/knife_bayonet_slaughter.vmt',
		8,
	},
		{
		'perma_knife_bowie_knife_|_forest_ddpat',
	 	'Bowie | Forest',
	 	'knife_bowie_ddpat',
	 	'models/weapons/w_csgo_bowie.mdl',
	 	'models/csgo_knife/knife_survival_ddpat.vmt',
		4,
	},
		{
		'perma_knife_butterfly_knife_|_night',
	 	'Butterfly | Night',
	 	'knife_butterfly_night',
	 	'models/weapons/w_csgo_butterfly.mdl',
	 	'models/csgo_knife/knife_butterfly_night.vmt',
		7,
	},
		{
		'perma_knife_default_t_knife_|_golden',
	 	'Default T | Golden',
	 	'knife_default_t_golden',
	 	'models/weapons/w_csgo_default_t.mdl',
	 	'models/csgo_knife/knife_t_golden.vmt',
		1,
	},
		{
		'perma_knife_falchion_knife_|_tiger_tooth',
	 	'Falchion | Tiger Tooth',
	 	'knife_falchion_tiger',
	 	'models/weapons/w_csgo_falchion.mdl',
	 	'models/csgo_knife/knife_falchion_tiger.vmt',
		9,
	},
		{
		'perma_knife_flip_knife_|_crimson_webs',
	 	'Flip | Crimson Webs',
	 	'knife_flip_crimsonwebs',
	 	'models/weapons/w_csgo_flip.mdl',
	 	'models/csgo_knife/knife_flip_crimsonweb.vmt',
		3,
	},
		{
		'perma_knife_gut_knife',
	 	'Gut Knife',
	 	'knife_gut',
	 	'models/weapons/w_csgo_gut.mdl',
	},
		{
		'perma_knife_karambit_knife_|_fade',
	 	'Karambit | Fade',
	 	'knife_karambit_fade',
	 	'models/weapons/w_csgo_karambit.mdl',
	 	'models/csgo_knife/karam_fade.vmt',
		6,
	},
		{
		'perma_knife_m9_bayonet_knife_|_ultraviolet',
	 	'Bayonet | Ultraviolet',
	 	'knife_m9_ultraviolet',
	 	'models/weapons/w_csgo_m9.mdl',
	 	'models/csgo_knife/knife_m9_ultraviolet.vmt',
		10,
	},
		{
		'perma_knife_shadow_daggers_|_damascus_steel',
	 	'Shadow Daggers | Damascus',
	 	'knife_daggers_damascus',
	 	'models/weapons/w_csgo_push.mdl',
	 	'models/csgo_knife/knife_push_damascus.vmt',
		3,
	},

}

local knife = rp.shop.Add('Basic Knife', 'perma_knife')
	:SetCat('Permanent Knives')
	:SetPrice(300)
	:SetWeapon('swb_knife')
	:SetIcon('models/weapons/w_knife_t.mdl')
	:SetStackable(false)
	knife.SWEP = 'swb_knife'

for k, v in ipairs(permaKnives) do
	weapons.Register({
		Weight				= 5,
		AutoSwitchTo		= false,
		AutoSwitchFrom		= false,
		PrintName			= v[2],
		DrawAmmo 			= false,
		DrawCrosshair 		= true,
		ViewModelFOV		= 65,
		ViewModelFlip		= false,
		CSMuzzleFlashes		= true,
		UseHands			= true,
		Slot				= 3,
		SlotPos				= 0,
		Base 				= 'baseknife',
		Category			= 'SUP Knives',
		Spawnable			= true,
		AdminSpawnable		= true,
		ViewModel 			= string.Replace(v[4], '/w_', '/v_'),
		WorldModel 			= v[4],
		DrawWeaponInfoBox  	= false,
		Skin 				= v[5],
		SkinIndex 			= v[6] or 0,
	}, v[3])

	local knife = rp.shop.Add(v[2], v[1])
		:SetCat('Permanent Knives')
		:SetPrice(800)
		:SetIcon(v[4])
		:SetStackable(false)
		:SetWeapon(v[3])
	knife.Skin 		= v[5]
	knife.SkinIndex = v[6]
	knife.SWEP = v[3]
end

rp.shop.Add('Basic Vape', 'perma_vape')
	:SetCat('Permanent Vapes')
	:SetIcon('models/swamponions/vape.mdl')
	:SetPrice(300)
	:SetWeapon('weapon_vape')

-- Vape flava flaves
--- name
--- nicename
--- price
--- color object or function

local color_stawberry = Color(210, 14, 7)
local color_wedding_cake = Color(118, 61, 204)
local colors_milk_cookies = {
	[0] = Color(238,238,238),
	[1] = Color(216,173,106),
	[2] = Color(146,88,0),
	[3] = Color(204,168,83),
	[4] = Color(242,229,150)
}
local vapeFlavors = {
	{
		'perma_vape_strawberry',
		'Strawberry',
		400,
		color_stawberry
	},
	{
		'perma_vape_honey',
		'Honey',
		400,
		Color(169, 131, 7)
	},
	{
		'perma_vape_apple',
		'Green Apple',
		400,
		Color(141, 182, 0)
	},
	{
		'perma_vape_blue',
		'Tru Blue',
		400,
		Color(0, 115, 207)
	},
	{
		'perma_vape_dewberry',
		'Dewberry',
		400,
		Color(139, 85, 155)
	},
	{
		'perma_vape_mango',
		'Mango',
		400,
		Color(255, 130, 67)
	},
	{
		'perma_vape_cornflake',
		'Cornflake Tart',
		400,
		ui.col.Orange
	},
	{
		'perma_vape_cotton_candy',
		'Cotton Candy',
		400,
		ui.col.Pink
	},
	{
		'perma_vape_root_beer',
		'Root Beer Float',
		400,
		ui.col.Brown
	},
	{
		'perma_vape_milk_cookies',
		'Milk & Cookies',
		600,
		function()
			local st = SysTime()
			local col = (math.floor((st - math.floor(st)) * 5.5)) % 4

			return colors_milk_cookies[col]
		end
	},
	{
		'perma_vape_strawberry_white',
		'Strawberry White Chocolate',
		600,
		function()
			local st = SysTime()
			local col = (math.floor((st - math.floor(st)) * 5.5)) % 3

			return (col == 0) and ui.col.OffWhite or color_stawberry
		end
	},
	{
		'perma_vape_purple',
		'Purple Wedding Cake',
		600,
		function()
			local st = SysTime()
			local col = (math.floor((st - math.floor(st)) * 5.5)) % 3

			return (col == 0) and ui.col.OffWhite or color_wedding_cake
		end
	},
	{
		'perma_vape_rainbow',
		'Fruit Whip',
		1100,
		function()
			local st = SysTime()
			local col = (math.floor((st - math.floor(st)) * 5.5)) % 7

			if (col == 0) then
				return rp.col.Red
			elseif (col == 1) then
				return rp.col.Orange
			elseif (col == 2) then
				return rp.col.Yellow
			elseif (col == 3) then
				return rp.col.Green
			elseif (col == 4) then
				return rp.col.Blue
			elseif (col == 5) then
				return rp.col.Indigo
			elseif (col == 6) then
				return rp.col.Violet
			end
		end
	}
}

for k, v in ipairs(vapeFlavors) do
	local vapeFlavor = rp.shop.Add(v[2], v[1])
		:SetCat('Permanent Vapes')
		:SetIcon('models/swamponions/vape.mdl')
		:SetPrice(v[3])
		:SetStackable(false)
		:SetWeapon('weapon_vape')
	vapeFlavor.SWEP = 'weapon_vape'
	vapeFlavor.Color = v[4]
end

hook.Call('rp.AddUpgrades', GAMEMODE)
