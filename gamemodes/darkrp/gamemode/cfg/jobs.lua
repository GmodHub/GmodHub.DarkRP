--
-- Misc
--
local citizens = {
	'models/player/Group01/Female_01.mdl',
	'models/player/Group01/Female_02.mdl',
	'models/player/Group01/Female_03.mdl',
	'models/player/Group01/Female_04.mdl',
	'models/player/Group01/Female_06.mdl',
	'models/player/group01/male_01.mdl',
	'models/player/Group01/Male_02.mdl',
	'models/player/Group01/Male_05.mdl',
	'models/player/Group01/Male_06.mdl',
	'models/player/Group01/Male_07.mdl',
	'models/player/Group01/Male_08.mdl',
	'models/player/Group01/Male_09.mdl',
}

TEAM_CITIZEN = rp.addTeam('Гражданин', {
	color = Color(150,170,200),
	model = citizens,
	weapons = {},
	command = 'citizen',
	max = 0,
	hasLicense = false,
	candemote = false
})

TEAM_RAPIST = rp.addTeam('Насильник', {
	color = Color(150,170,200),
	model = citizens,
	weapons = {},
	command = 'rapist',
	max = 6,
	hasLicense = false,
	candemote = false,
	candisguise = true,
	vip = true,
})

player_manager.AddValidModel( "Chloe", "models/player/korka007/chloe.mdl" )
player_manager.AddValidHands( "Chloe", "models/player/korka007/chloearms.mdl", 0, "00000000" )
TEAM_SJW = rp.addTeam('Протестующий', {
	color = Color(150,170,200),
	model = 'models/player/korka007/chloe.mdl',
	GetRelationships = function() return {TEAM_SJW} end,
	weapons = {'weapon_sign'},
	command = 'protester',
	max = 0,
	hasLicense = false,
	candemote = false
})

TEAM_ADMIN = rp.addTeam('Администрация', {
	color =  Color(51,128,255),
	model = 'models/player/skeleton.mdl',
	weapons = {'weapon_keypadchecker', 'med_kit'},
	command = 'staff',
	max = 0,
	admin = true,
	candemote = false,
	NoKombat = true,
	mayorCanSetSary = false,
	customCheck = function(pl) return pl:IsAdmin() end,
	PlayerCanBeWanted = function(pl, cop) return false end,
	CustomCheckFailMsg = 'JobNeedsAdmin',
	DamageCooldown = 0
})

--
-- Государство
--
local police_spawns = {
	rp_bangclaw = {
		Vector(4321, -713, 72),
		Vector(4321, -550, 72),
		Vector(4272, -980, 72),
		Vector(4229, -1066, 72),
		Vector(4022, -534, 200),
		Vector(4027, -727, 200),
		Vector(4028, -874, 200),
		Vector(4364, -734, 72),
	}
}

local police_spawns_proc = {
	[game.GetMap():lower()] = {
		function(pl)
			local police_spawns = police_spawns[game.GetMap():lower()]
			local pos = police_spawns[math.random(1, #police_spawns)]

			if pl.LastDeath and (pl.LastDeath > CurTime()) then
				if (pl.DeathPos:DistToSqr(pos) < 122500) then
					return nil
				end
			end

			return pos
		end
	}
}

local function govPlayerDeath(pl, weapon, killer)
	pl.DeathPos = pl:GetPos()
	pl.LastDeath = CurTime() + 60
end

TEAM_MAYOR = rp.addTeam('Мэр', {
	catagory = 'Государство',
	color = Color(240, 0, 0, 255),
	model = 'models/player/breen.mdl',
	GetRelationships = function() return {TEAM_MAYOR, TEAM_POLICE, TEAM_CHIEF} end,
	weapons = {},
	spawns = {
		rp_bangclaw = {
			Vector(667, 2431, 144),
			Vector(643, 2612, 144),
			Vector(528, 2307, 144),
		}
	},
	command = 'mayor',
	max = 1,
	vote = true,
	candemote = true,
	hasLicense = true,
	mayor = true,
	CannotOwnDoors = true,
	CanInstantDemote = function(pl, targ)
		return targ:Team() == TEAM_CHIEF or targ:Team() == TEAM_POLICE
	end
})

TEAM_CHIEF = rp.addTeam('Шеф полиции', {
	catagory = 'Государство',
	color = Color(60,80,255),
	model = 'models/player/barney.mdl',
	CanRaid = 'При наличии ордера',
	GetRelationships = function() return {TEAM_MAYOR, TEAM_POLICE, TEAM_CHIEF} end,
	weapons = {},
	NoKombat = true,
	spawns = police_spawns_proc,
	command = 'chief',
	max = 1,
	playtime = 3600,
	candemote = true,
	hasLicense = true,
	police = true,
	PoliceChief = true,
	noAutoSpawn = true,
	CannotOwnDoors = true,
	CanInstantDemote = function(pl, targ)
		return targ:Team() == TEAM_POLICE
	end,
	PlayerDeath = govPlayerDeath
})

TEAM_POLICE = rp.addTeam('Полицейский', {
	catagory = 'Государство',
	color = Color(60,80,255),
	model = {
		'models/player/combine_soldier_prisonguard.mdl',
		'models/player/combine_soldier.mdl',
		'models/player/police.mdl',
		'models/player/police_fem.mdl',
	},
	CanRaid = 'При наличии ордера',
	GetRelationships = function() return {TEAM_MAYOR, TEAM_POLICE, TEAM_CHIEF} end,
	weapons = {},
	NoKombat = true,
	spawns = police_spawns_proc,
	command = 'police',
	max = 15,
	playtime = 3600,
	candemote = true,
	hasLicense = true,
	police = true,
	noAutoSpawn = true,
	CannotOwnDoors = true,
	PlayerDeath = govPlayerDeath
})

--
-- Бандиты
--
TEAM_MOBBOSS = rp.addTeam('Глава мафии', {
	catagory = 'Бандиты',
	color = Color(70, 70, 70),
	model = 'models/player/gman_high.mdl',
	CanRaid = true,
	CanMug = true,
	CanHostage = true,
	GetRelationships = function() return {TEAM_MOBBOSS, TEAM_GANGSTER} end,
	weapons = {'swb_mac10'},
	command = 'nmobboss',
	max = 1,
	candemote = true,
	CanInstantDemote = function(pl, targ)
		return targ:Team() == TEAM_GANGSTER
	end
})


TEAM_GANGSTER = rp.addTeam('Мафия', {
	catagory = 'Бандиты',
	color = Color(70, 70, 70),
	model = {
		'models/player/Group03/Female_01.mdl',
		'models/player/Group03/Female_02.mdl',
		'models/player/Group03/Female_03.mdl',
		'models/player/Group03/Female_04.mdl',
		'models/player/Group03/Male_01.mdl',
		'models/player/Group03/Male_02.mdl',
		'models/player/Group03/Male_03.mdl',
		'models/player/Group03/Male_04.mdl',
		'models/player/Group03/Male_05.mdl',
		'models/player/Group03/Male_06.mdl',
		'models/player/Group03/Male_07.mdl',
		'models/player/Group03/Male_08.mdl',
		'models/player/Group03/Male_09.mdl'
	},
	CanRaid = true,
	CanMug = true,
	CanHostage = true,
	GetRelationships = function() return {TEAM_MOBBOSS, TEAM_GANGSTER} end,
	weapons = {'swb_fiveseven'},
	command = 'gangster',
	max = 0,
	candemote = false,
})


--
-- Selling Classes
--
TEAM_GUN = rp.addTeam('Продавец оружия', {
	catagory = 'Торговцы',
	color = Color(255, 140, 0),
	model = 'models/player/monk.mdl',
	weapons = {},
	command = 'gundealer',
	max = 8,
	playtime = 900,
	candemote = true,
	hasLicense = true,
	GunDealer = true,
})

TEAM_BMIDEALER = rp.addTeam('Контрабандист', {
	catagory = 'Торговцы',
	color = Color(0, 71, 71, 255),
	model = 'models/player/leet.mdl',
	weapons = {},
	command = 'blackmarketdealer',
	max = 8,
	bmidealer = true,
	candemote = true
})

TEAM_DRUGDEALER = rp.addTeam('Наркобарон', {
	catagory = 'Торговцы',
	color = Color(153, 51, 255, 255),
	model = {'models/player/group01/Male_03.mdl', 'models/player/Group01/Male_04.mdl'},
	weapons = {},
	command = 'drugdealer',
	max = 8,
	candemote = true,
	drugDealer = true,
	mayorCanSetSaly = false
})

TEAM_BARTENDER = rp.addTeam('Торговец', {
	catagory = 'Торговцы',
	color = Color(153, 102, 51, 255),
	model = 'models/player/eli.mdl',
	weapons = {},
	command = 'bartender',
	max = 8,
	drugDealer = true,
	candemote = true,
})

TEAM_COOK = rp.addTeam('Повар', {
	catagory = 'Торговцы',
	color = Color(238, 99, 99, 255),
	model = 'models/player/mossman.mdl',
	weapons = {},
	command = 'cook',
	max = 6,
	candemote = true,
	cook = true,
})

TEAM_DOCTOR = rp.addTeam('Медик', {
	catagory = 'Торговцы',
	color = Color(47, 79, 79, 255),
	model = {
	   'models/player/Group03m/male_01.mdl',
	   'models/player/Group03m/male_02.mdl',
	   'models/player/Group03m/male_03.mdl',
	   'models/player/Group03m/male_04.mdl',
	   'models/player/Group03m/male_05.mdl',
	   'models/player/Group03m/male_06.mdl',
	   'models/player/Group03m/male_07.mdl',
	   'models/player/Group03m/male_08.mdl',
	   'models/player/Group03m/male_09.mdl',
	   'models/player/Group03m/female_01.mdl',
	   'models/player/Group03m/female_02.mdl',
	   'models/player/Group03m/female_03.mdl',
	   'models/player/Group03m/female_04.mdl',
	   'models/player/Group03m/female_05.mdl',
	   'models/player/Group03m/female_06.mdl'
	},
	weapons = {'med_kit'},
	command = 'medic',
	max = 6,
	candemote = true,
	hasLicense = false,
	medic = true,
})

TEAM_DJ = rp.addTeam('DJ', {
	catagory = 'Развлечения',
	color = Color(20, 150, 20),
	model = 'models/player/alyx.mdl',
	weapons = {},
	command = 'dj',
	max = 4,
	hasLicense = false,
	candemote = true,
})

TEAM_CINEMAOWNER = rp.addTeam('Владелец Кинотеатра', {
	catagory = 'Развлечения',
	color = Color(102, 0, 102, 255),
	model = 'models/player/magnusson.mdl',
	weapons = {},
	spawns = {
		rp_bangclaw = {
			Vector(2432, -1806, 72),
			Vector(2551, -1759, 72),
			Vector(2375, -1742, 72),
		},
	},
	command = 'cinemaowner',
	max = 1,
	hasLicense = false,
	candemote = true
})

TEAM_CASINOOWNER = rp.addTeam('Владелец Казино', {
	catagory = 'Развлечения',
	color = Color(244, 131, 66),
	model = 'models/player/magnusson.mdl',
	weapons = {},
	command = 'casinoowner',
	max = 8,
	hasLicense = false,
	candemote = true
})


--
-- Raiding Classes
--
local raider_spawns = {
	rp_bangclaw = {
		Vector(9645, -3282, 64),
		Vector(9513, -3144, 64),
		Vector(9456, -3411, 64),
		Vector(9733, -3710, 64),
		Vector(9828, -3448, 64),
		Vector(9845, -3157, 64),
		Vector(9968, -2834, 68),
		Vector(9318, -3867, 64),
	}
}

TEAM_FREERUNNER = rp.addTeam("Паркурист", {
	color= Color(71, 204, 71),
	model = "models/player/p2_chell.mdl",
	CanRaid = true,
	weapons = {"climb_swep"},
	command = "freerunner",
	max = 6,
	candemote = false,
	NoKombat = true,
	spawns = raider_spawns,
	vip = true,
	RunSpeed = 330,
	PlayerSpawn = function(pl)
		pl:SetJumpPower(250)
	end
})

TEAM_BOMB = rp.addTeam('Подрывник', {
	catagory = 'Рейдеры',
    color = Color(89, 31, 52),
    model = "models/player/arctic.mdl",
	CanRaid = true,
	CanMug = true,
	CanHostage = true,
    weapons = {"weapon_c4", "lockpick"},
    command = "alahbabah",
    max = 1,
	candemote = false,
	mayorCanSetSalry = false,
	vip = true,
	spawns = raider_spawns,
})

player_manager.AddValidModel('gs_cage', 'models/code_gs/player/cage.mdl')
player_manager.AddValidHands('gs_cage', 'models/weapons/c_arms_citizen.mdl', 1, '00000000')
TEAM_THUG = rp.addTeam('Негр', {
	catagory = 'Рейдеры',
	color= Color(179,53,247),
	model = 'models/code_gs/player/cage.mdl',
	CanRaid = true,
	CanMug = true,
	weapons = {'weapon_combo_fists'},
	command = 'thug',
	max = 8,
	candemote = false,
	spawns = raider_spawns,
	PlayerSpawn = function(pl)
		pl:SetHealth(150)
	end
})

TEAM_THIEF = rp.addTeam('Вор', {
	catagory = 'Рейдеры',
	color = Color(204, 204, 0, 255),
	model = 'models/player/guerilla.mdl',
	CanRaid = true,
	weapons = {'lockpick'},
	command = 'thief',
	lockpicktime = 0.70,
	max = 8,
	candemote = false,
	spawns = raider_spawns,
})

player_manager.AddValidModel('gs_robber', 'models/code_gs/player/robber.mdl')
player_manager.AddValidHands('gs_robber', 'models/weapons/c_arms_cstrike.mdl', 0, '00000000')
TEAM_PROTHIEF = rp.addTeam('Профессиональный Вор', {
	catagory = 'Рейдеры',
	color = Color(155, 30, 30),
	model = 'models/code_gs/player/robber.mdl',
	CanRaid = true,
	CanMug = true,
	weapons = {'lockpick', 'keypad_cracker'},
	command = 'prothief',
	max = 8,
	candemote = false,
	vip = true,
	spawns = raider_spawns,
})

TEAM_ANARCHIST = rp.addTeam('Анархист', {
	catagory = 'Рейдеры',
	color = Color(84, 13, 13),
	model = {
		'models/player/Group03/female_01.mdl',
		'models/player/Group03/female_02.mdl',
		'models/player/Group03/female_03.mdl',
		'models/player/Group03/female_04.mdl',
		'models/player/Group03/female_06.mdl',
		'models/player/group03/male_01.mdl',
		'models/player/Group03/male_02.mdl',
		'models/player/Group03/male_03.mdl',
		'models/player/Group03/male_04.mdl',
		'models/player/Group03/male_05.mdl',
		'models/player/Group03/male_06.mdl',
		'models/player/Group03/male_07.mdl',
		'models/player/Group03/male_08.mdl',
		'models/player/Group03/male_09.mdl'
	},
	CanRaid = true,
	CanMug = true,
	CanHostage = true,
	weapons = {'swb_p228', 'weapon_ziptie', 'pickpocket'},
	command = 'anarchist',
	max = 4,
	candemote = false,
	mayorCanSetSalry = false,
	vip = true,
	spawns = raider_spawns,
})
--
-- Наёмники classes
--
TEAM_HACKER = rp.addTeam('Хакер', {
	catagory = 'Наёмники',
	color = Color(50,50,90),
	model = {
		'models/player/Hostage/Hostage_04.mdl',
		'models/player/kleiner.mdl',
		'models/player/magnusson.mdl'
	},
	CanRaid = 'Если нанимателю разрешено',
	GetRelationships = function() return 'Наниматель' end,
	weapons = {'keypad_cracker'},
	command = 'hacker',
	keypadcracktime = 0.70,
	max = 6,
	hirable = true,
	hirePrice = 1500,
	candemote = false,
	spawns = raider_spawns,
})

TEAM_SECURITY = rp.addTeam('Охранник', {
	catagory = 'Наёмники',
	color= Color(100, 175, 145, 255),
	model = 'models/player/odessa.mdl',
	GetRelationships = function() return 'Наниматель' end,
	weapons = { 'stun_baton', 'weapon_taser', 'swb_p228' },
	command = 'rentacop',
	max = 8,
	hirable = true,
	hirePrice = 500,
	candemote = true,
})

TEAM_MERC = rp.addTeam('Наемник', {
	catagory = 'Наёмники',
	color= Color(115, 145, 0),
	model = 'models/player/Phoenix.mdl',
	CanRaid = 'Если нанимателю разрешено',
	CanMug = 'Если нанимателю разрешено',
	CanHostage = 'Если нанимателю разрешено',
	GetRelationships = function() return 'Наниматель' end,
	weapons = {'swb_ak47'},
	command = 'merc',
	max = 12,
	hirable = true,
	hirePrice = 1500,
	candemote = true,
	vip = true,
	spawns = raider_spawns,
})

--
-- Бомжи
--
local hobo_spawns = {
	rp_bangclaw = {
		Vector(198, -747, -192),
		Vector(794, -761, -192),
		Vector(1377, 291, -192),
		Vector(576, 352, -192),
		Vector(2722, -3473, -232),
		Vector(2942, -2664, -664),
		Vector(3217, 216, -664),
		Vector(3199, 928, -944)
	}
}

local spawnHobo = function(pl)
	pl:SetHunger(25)
end

TEAM_HOBOKING = rp.addTeam('Король Бомжей', {
	catagory = 'Бомжи',
	color = Color(80, 45, 0),
	model = 'models/player/corpse1.mdl',
	GetRelationships = function() return {TEAM_HOBOKING, TEAM_HOBO} end,
	weapons = {'weapon_bugbait'},
	spawns = hobo_spawns,
	command = 'hoboking',
	max = 1,
	hasLicense = false,
	candemote = false,
	hobo = true,
	CannotOwnDoors = true,
	PlayerSpawn = spawnHobo,
	CanInstantDemote = function(pl, targ)
		return targ:Team() == TEAM_HOBO
	end
})

TEAM_HOBO = rp.addTeam('Бомж', {
	catagory = 'Бомжи',
	color = Color(80, 45, 0),
	model = 'models/player/corpse1.mdl',
	GetRelationships = function() return {TEAM_HOBOKING, TEAM_HOBO} end,
	weapons = {'weapon_bugbait'},
	spawns = hobo_spawns,
	command = 'hobo',
	max = 0,
	hasLicense = false,
	candemote = false,
	hobo = true,
	CannotOwnDoors = true,
	PlayerSpawn = spawnHobo
})
/*
local meathHeadSpawns = {
	rp_bangclaw = {
		Vector(2395, 1297, -392),
		Vector(-1889, 492, -880),
		Vector(-2322, -400, -947),
		Vector(-2799, -1881, -496),
	}
}

local zPos = (game.GetMap() == 'rp_danktown_rc5a' or game.GetMap() == 'rp_sundown_rc5a') and -244 or 696
TEAM_METHHEAD = rp.addTeam('Бомж Наркоман', {
	catagory = 'Бомжи',
	color = Color(50, 35, 0),
	model = 'models/player/charple.mdl',
	CanMug = true,
	GetRelationships = function() return {TEAM_METHHEAD} end,
	weapons = {},
	spawns = meathHeadSpawns,
	command = 'methhead',
	max = 4,
	vip = true,
	hasLicense = false,
	candemote = false,
	NoKombat = true,
	CannotOwnDoors = true,
	NoKarma = true,
	PlayerCanBeWanted = function(pl, cop) return false end,
	PlayerThink = function(pl)
		if (pl.BloodStacksCD and CurTime() > pl.BloodStacksCD) then
			pl:SetNetVar('BloodStacks', 0)
			pl.BloodStacksCD = nil
		end

		local maxHP = 25 + (pl:GetNetVar('BloodStacks') or 0) * 25

		if pl:Alive() and (not pl:IsArrested()) and (pl:GetPos().z > zPos) then
			pl:Kill()
		elseif pl:Alive() then
			if (pl:Health() < maxHP) then
				pl:AddHealth(math.min(maxHP - pl:Health(), 5))
			elseif (pl:Health() > maxHP) then
				pl:SetHealth(maxHP)
			end
		end
	end,
	PlayerKilledPlayer = function(pl, victim)
		victim.CurrentDeathReason = 'Methhead'
		-- Need some sort of effect here tbh, white flash or something
		pl:SetNetVar('BloodStacks', math.min((pl:GetNetVar('BloodStacks') or 0) + 1, 19))
		pl.BloodStacksCD = CurTime() + 10
		pl:AddHealth(25)
		pl:MiscEffect("whiteflash")
	end,
	PlayerSpawn = function(pl)
		pl:SetMaterial("models/shadertest/predator")
		pl:SetHealth(25)
		pl:SetHunger(200, true)
		pl:SetNetVar('BloodStacks', 0)
		pl.BloodStacksCD = nil
	end,
	PlayerLoadout = function(pl)
		pl:StripWeapons()
		pl:Give('weapon_crowbar')

		return false
	end,
	PlayerCanPickupWeapon = function(pl, wep)
		return (wep:GetClass() == 'weapon_crowbar')
	end,
	PlayerSpawnProp = function()
		return false
	end,
	PlayerUse = function(pl, ent)
		return ent:IsDoor() or (ent:GetClass() == 'spawned_money')
	end,
	PlayerHasHunger = function(pl)
		return false
	end,
	PlayerDeathTimer = function()
		return 5
	end,
	PlayerShouldTakeDamage = function(pl, attacker) -- Disable team damage
		if (attacker:IsPlayer() and attacker:Team() == TEAM_METHHEAD) then
			return false
		end
	end,
	ShouldHidePlayerInfo = function(pl)
		return (not LocalPlayer():IsSOD())
	end,
	DamageCooldown = 0,
	RunSpeed = 420
})
*/
--
-- Other
--
TEAM_HITMAN = rp.addTeam('Наёмный Убийца', {
	color = Color(150, 80, 80),
	model = 'models/player/arctic.mdl',
	CanRaid = 'Только для выполнения заказа',
	weapons = {'swb_usp', 'swb_scout'},
	command = 'hitman',
	max = 8,
	candemote = true,
	candisguise = true,
	hitman      = true,
	playtime = 3600,
	PlayerKilledPlayer = function(pl, victim)
		if (victim:HasHit() and victim ~= pl) then
			victim:RemoveHit(pl)
			victim.CurrentDeathReason = 'Bounty'
			hook.Call('playerCompletedHit', GAMEMODE, pl, victim)
		end
	end,
	PlayerDeath = function(pl, weapon, killer)
		if killer:IsPlayer() and killer:HasHit() and (pl ~= killer) then
			pl:FailHit(killer)
		end
	end
})

TEAM_WHORE = rp.addTeam('Проститутка', {
	color = Color(220, 75, 255, 255),
	model = 'models/player/alyx.mdl',
	GetRelationships = function() return {TEAM_PIMP, TEAM_WHORE} end,
	weapons = {},
	command = 'Prostitute',
	max = 6,
	candemote = true,
	Hoe = true
})


TEAM_PIMP = rp.addTeam('Сутенёр', {
	color = Color(175, 0, 200, 255),
	model = 'models/player/group01/male_01.mdl',
	GetRelationships = function() return {TEAM_PIMP, TEAM_WHORE} end,
	weapons = {'weapon_pimphand'},
	command = 'pimp',
	max = 1,
	candemote = true,
	vip = true,
	Pimp = true,
	CanInstantDemote = function(pl, targ)
		return targ:Team() == TEAM_WHORE
	end
})

TEAM_BANNED = rp.addTeam('Забаненный', {
	color = Color(255,0,0),
	model = 'models/player/soldier_stripped.mdl',
	weapons = {},
	command = 'banned124',
	max = 0,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl) return pl:IsBanned() end,
	CustomCheckFailMsg = 'JobNeedsBanned',
	CannotOwnDoors = true
})

TEAM_WATCHER = rp.addTeam('Наблюдатель', {
	color = Color(150,170,200),
	model = citizens,
	weapons = {},
	spawns = {
		[game.GetMap():lower()] = {
			ba.adminRoom
		}
	},
	command = 'watcher',
	max = 0,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl)
		if (!rp.teams[TEAM_WATCHER].spawns[game.GetMap():lower()][1]) then
			return false, 'AdminRoomNotSet'
		end
		if (!pl.CalledFromSitwatcherCommand) then
			return false, 'JobNeedsManualSet'
		end
		return true
	end,
	CustomCheckFailMsg = 'JobNeedsManualSet',
})

/*
TEAM_HOTEL = rp.addTeam('Менеджер Отеля', {
	color = Color(205, 205, 205),
	model = 'models/player/magnusson.mdl',
	GetRelationships = function() return 'Tenants' end,
	weapons = {},
	spawns = {
		rp_c18_sup_b2 = {
			Vector(-1633, -1020, 696),
			Vector(-1729, -1018, 696),
			Vector(-1727, -933, 696),
			Vector(-1598, -936, 696),
			Vector(-1502, -938, 696),
		},
		rp_danktown_rc5a = {
			Vector(1123, -1872, -99),
		},
		rp_sundown_rc5a = {
			Vector(1123, -1872, -99),
		},
	},
	command = 'hotelmanager',
	max = 1,
	hasLicense = false,
	candemote = true,
	HotelManager = true,
	CannotOwnDoors = true
})
*/
local function orgCheck(pl, orgName)
	return pl:IsSA() or (pl:GetOrg() == orgName), ('Вы должны быть в банде ' .. orgName .. ' чтобы стать этой профессией.')
end

TEAM_GAY = rp.addTeam('Стив Хуйс', {
	catagory = ' Донат',
	color = Color(72, 135, 7),
	model = 'models/gmh/player/custom/happybirthday/merc1.mdl',
	CanRaid = true,
	CanMug = true,
	weapons = {'swb_m4a1', 'lockpick', 'keypad_cracker'},
	command = 'bdhuis',
	max = 5,
	hasLicense = false,
	candemote = false,
	CanTool = function(pl, ent, tool)
		if (tool == 'playercolorizer') and (ent:EntIndex() == 0) then
			return true
		end
	end,
	customCheck = function(pl)
		return orgCheck(pl, 'Хуйсы')
	end,
})

TEAM_OILMONEY = rp.addTeam('Destruction Elite', {
	catagory = ' Донат',
	color = Color(50, 50, 50),
	model = 'models/gmh/player/custom/destruction/r6s_kapkan.mdl',
	CanRaid = true,
	weapons = {'swb_m4a1', 'lockpick', 'keypad_cracker'},
	command = 'destructionelite',
	max = 5,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl)
		return orgCheck(pl, 'DesTruction ExTreMe')
	end,
})

TEAM_CASIA = rp.addTeam('ʙ o ɴ e s', {
	catagory = ' Донат',
	color = Color(161, 70, 100),
	model = 'models/gmh/player/custom/bones/bones.mdl',
	CanRaid = true,
	CanMug = true,
	weapons = {'lockpick', 'keypad_cracker'},
	command = 'fiji',
	max = 5,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl)
		return orgCheck(pl, 'ғ ɪ ▲ ᴊ ɪ')
	end,
	CanChangePlayerColor = function()
		return false
	end,
	PlayerSpawn = function(pl)
		pl:SetPlayerColor(Vector(255,255,255))
	end
})

TEAM_LOVEBUG = rp.addTeam('ai', {
	catagory = ' Донат',
	color = Color(255, 127, 127),
	model = 'models/auditor/com/honoka/honoka.mdl',
	CanRaid = true,
	weapons = {'lockpick', 'keypad_cracker', 'swb_xm1014', 'swb_m4a1'},
	command = 'ai',
	max = 5,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl)
		return orgCheck(pl, '私の女の子')
	end,
})


TEAM_SPETS = rp.addTeam('Spetsnaz', {
	catagory = ' Донат',
	color = Color(18, 69, 145),
	model = 'models/cso2/player/ct_helga_player.mdl',
	CanRaid = true,
	weapons = {'lockpick', 'keypad_cracker', 'swb_xm1014', 'swb_ak47'},
	command = 'toska',
	max = 5,
	hasLicense = false,
	candemote = false,
	customCheck = function(pl)
		return orgCheck(pl, 'TóSKA')
	end,
})

--
-- Configs
--
-- Agenda
rp.AddAgenda('Бандиты Agenda', TEAM_MOBBOSS, {TEAM_GANGSTER})
rp.AddAgenda('Police Agenda', TEAM_CHIEF, {TEAM_POLICE, TEAM_MAYOR})
rp.AddAgenda('Hobo Agenda', TEAM_HOBOKING, {TEAM_HOBO})
rp.AddAgenda('Hoe Agenda', TEAM_PIMP, {TEAM_WHORE})

-- Group Chat
rp.addGroupChat("Бандиты", TEAM_MOBBOSS, TEAM_GANGSTER)
rp.addGroupChat("Государство", TEAM_CHIEF, TEAM_POLICE, TEAM_MAYOR)
rp.addGroupChat("Бомжи", TEAM_HOBOKING, TEAM_HOBO)
rp.addGroupChat("Brothel", TEAM_PIMP, TEAM_WHORE)

-- Group Bans (banned from one, banned from all)
//rp.addGroupBan(TEAM_MOBBOSS, TEAM_GANGSTER)
//rp.addGroupBan(TEAM_CHIEF, TEAM_POLICE, TEAM_MAYOR)
//rp.addGroupBan(TEAM_HOBOKING, TEAM_HOBO)
//rp.addGroupBan(TEAM_PIMP, TEAM_WHORE)
