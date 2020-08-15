rp.cfg.StartMoney 			= 25000
rp.cfg.WelfareAmount		= 200
rp.cfg.WelfareCutoff		= 50000
rp.cfg.StartKarma			= 50
rp.cfg.RespawnTime 		= 35

rp.cfg.MoneyPerKarma 		= 125
rp.cfg.SecondMoneyPerKarma	= 150

rp.cfg.OrgCost 				= 50000
rp.cfg.OrgBasicBankMax		= 100000
rp.cfg.OrgBankTax			= 0.1
rp.cfg.OrgRenameCost		= 50000
rp.cfg.OrgInviteCost		= 500
rp.cfg.OrgMaxMembers		= 50
rp.cfg.OrgMaxMembersPremium	= 150
rp.cfg.OrgMaxRanks			= 5
rp.cfg.OrgMaxRanksPremium	= 30

rp.cfg.AdvertCost			= 250
rp.cfg.HealthCost 			= 1000

rp.cfg.HungerRate 			= 1800

rp.cfg.DoorTaxMin			= 10
rp.cfg.DoorTaxMax			= 500
rp.cfg.DoorCostMin			= 100
rp.cfg.DoorCostMax 			= 2000

rp.cfg.RagdollDelete		= 60

rp.cfg.DefaultTeambanLength	= 180

-- Speed
rp.cfg.WalkSpeed 			= 180
rp.cfg.RunSpeed 			= 280

-- Printers
rp.cfg.PrintDelay 			= 300
rp.cfg.PrintAmount 			= 1500
rp.cfg.InkCost 				= 250

-- Item Lab
rp.cfg.ItemLabMaxMetal		= 3
rp.cfg.ItemLabMetalPrice 	= 500
rp.cfg.ItemLabTimeFactor 	= 14

-- Hits
rp.cfg.HitExpire			= 600
rp.cfg.HitCoolDown 			= 300
rp.cfg.HitMinCost 			= 2500
rp.cfg.HitMaxCost 			= 100000

-- Hire Price
rp.cfg.MaxHirePrice 		= 1000000

-- Afk
rp.cfg.AfkDemote 			= (60*60)*1
rp.cfg.AfkPropRemove 		= (60*60)*3
rp.cfg.AfkDoorSell 			= (60*60)*3

-- Lotto
rp.cfg.MinLotto 			= 1000
rp.cfg.MaxLotto 			= 1000000

-- Kombat
rp.cfg.KombatMinPrice		= 1000
rp.cfg.KombatMaxPrice		= 50000

-- Zipties
rp.cfg.ZiptieTime						= 4
rp.cfg.ZiptieCutTime					= 4
rp.cfg.ZiptieStruggleTime				= 120
rp.cfg.ZiptieStruggleDifficultyFalloff	= 180

-- Disguise
rp.cfg.DisguiseCooldown = 300

rp.cfg.LockdownTime 	= 300

rp.cfg.CampaignFee		= 2500

rp.cfg.CreditSale 		= '' --' (25% OFF!)'
rp.cfg.CreditsURL 		= 'https://gmodhub.com/donate/'

rp.cfg.DefaultLaws 		= [[
Убийства и грабёж запрещены.
Взлом и проникновение запрещены.
Денежные принтеры, нелегальные предметы и оружие без лицензии является нелегальным.]]

rp.cfg.LockdownSounds = {
--	'sound/ambient/alarms/alarm_citizen_loop1.wav',
--	'sound/ambient/alarms/combine_bank_alarm_loop1.wav',
	'sound/ambient/alarms/combine_bank_alarm_loop4.wav'
}

rp.cfg.DefaultWeapons = {
	'weapon_physcannon',
	'weapon_physgun',
	'gmod_tool',
	'keys',
	'pocket',
	--'weapon_snowball'
}

rp.cfg.TextSrceenFonts = {
	"Tahoma",
	"Helvetica",
	"Trebuchet MS",
	"Comic Sans MS",
	"Segoe UI",
	"Impact",
	"Broadway",
	"Webdings",
	"Snap ITC",
	"Papyrus",
	"Old English Text MT",
	"Mistral",
	"Lucida Handwriting",
	"Jokerman",
	"Freestyle Script",
	"Bradley Hand ITC",
	"Stencil",
	"Shrek",
	"Prototype",
	"Beon-Medium"
}

rp.cfg.TextScreenPrettyFontNames = {
	["Trebuchet MS"] = "Trebuchet",
	["Comic Sans MS"] = "Comic Sans",
	["Beon-Medium"] = "Beon"
}

-- Automated announcements
if (CLIENT) then
	rp.cfg.AnnouncementDelay = 300
	rp.cfg.Announcements = {
		--{ui.col.Purple, 'Did you know we have other servers? Hold C to see/join them!'},
		{ui.col.Gold, 'Пожалуйста поддержите разработку GmodHub\'a при помощи покупки доната. Для этого, кликните по вкладке Донат в F4 меню.'},
		--{ui.col.Gold, 'Покупка кредитов сейчас со скидкой 25% в честь праздников! Кликните по вкладке Донат в F4 меню.'},
		--{ui.col.Gold, 'Покупка кредитов сейчас со скидкой 25% в честь первой недели июля! Кликните по вкладке Донат в F4 меню.'},
		{ui.col.Purple, 'Мы рады каждому новому игроку в нашей группе Вконтакте! https://vk.com/gmdhub'},
		{ui.col.Purple, 'Вступайте в наш дискорд @ https://discord.gg/FdzJqUK'},
		--{ui.col.Gold, 'Communities our size are not cheap to run, support us by purchasing some upgrades. Click Credit Shop in the F4 menu.'},
	}
end

rp.cfg.JailHoleModels =  {
	rp_danktown_rc5a = '*148'
}

rp.cfg.MayorMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(588.511230, 2431.502930, 175.377777),
			Ang = Angle(0, -180, 0)
		}
	}
}

-- Bail Machine
rp.cfg.BailMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(4010, -880, 106),
			Ang = Angle(0, 90, 0),
		},
	}
}

-- Genome Machine
rp.cfg.GenomeMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(4251.200195, -1119.959351, 111.031250),
			Ang = Angle(0, 90, 0)
		}
	}
}

-- Cop shops
rp.cfg.CopShops = {
	rp_bangclaw = {
		{
			Pos = Vector(4381, -766, 72),
			Ang = Angle(0, -180, 0),
		}
	},
}

-- Drug buyers
rp.cfg.DrugBuyers = {
	rp_bangclaw = {
		{
			Pos = Vector(79, 1168, 130),
			Ang = Angle(0, 90, 0),
		},
		{
			Pos = Vector(5075, -4316, 130),
			Ang = Angle(0, 90, 0),
		},
		{
			Pos = Vector(1269, -1009, -472),
			Ang = Angle(0, 0, 0),
		}
	}
}

rp.cfg.GunBuyers = {
	rp_bangclaw = {
		{
			Pos = Vector(5967, -1146, 130),
			Ang = Angle(0, 180, 0),
		},
		{
			Pos = Vector(2710, -4131, -232),
			Ang = Angle(0, 90, 0),
		}
	},
}

rp.cfg.KarmaSellers = {
	rp_bangclaw = {
		{
			Pos = Vector(1039, -734, 90),
			Ang = Angle(0, 150, 0),
		}
	},
}

-- Spawn
rp.cfg.SpawnDisallow = {
	prop_physics		= true,
	media_radio 		= true,
	media_tv 			= true,
	ent_textscreen 		= true,
	ent_picture 		= true,
	gmod_rtcameraprop	= true,
	metal_detector		= true,
	gmod_light 			= true,
	gmod_lamp 			= true,
	ladder_base 		= true
}

rp.cfg.Spawns = {
	rp_bangclaw = {
		InitSpawn = Vector(29, -2731, 143),
		{ -- Main Area
			Vector(-172, -3069, 39),
			Vector(999, -2501, 397)
		}
	}
}

rp.cfg.TeamSpawns = rp.cfg.TeamSpawns or {
	[game.GetMap()]= {}
}

rp.cfg.SpawnPos = rp.cfg.SpawnPos or {
	rp_bangclaw = {
		Vector(166, -2678, 72),
		Vector(165, -2813, 72),
		Vector(98, -2911, 72),
		Vector(4, -2648, 72),
		Vector(-5, -2505, 72),
		Vector(169, -2506, 72),
		Vector(252, -2702, 72),
		Vector(-35, -2800, 72),
		Vector(-96, -2612, 72),
		Vector(-30, -2503, 72),
		Vector(39, -2980, 72),
		Vector(182, -2989, 72),
		Vector(274, -2989, 72),
		Vector(245, -2863, 72),
	}
}

-- Jail
rp.cfg.WantedTime		= 180
rp.cfg.WarrantTime		= 180
rp.cfg.ArrestTime	 	= 300
rp.cfg.BailCostPerMin 	= 1500

rp.cfg.Jails = {
	rp_bangclaw = {
		Vector(3904.823486, -1153.005371, 178.720261),
		Vector(4400.233398, -959.236084, 322.324036)
	},
}

rp.cfg.JailPos = {
	rp_bangclaw = {
		Vector(4336, -1057, 200),
		Vector(4289, -1000, 200),
		Vector(4200, -1027, 200),
		Vector(4133, -1029, 200),
		Vector(4155, -1087, 200),
		Vector(4032, -1065, 200),
		Vector(3987, -1045, 200),
		Vector(3946, -1008, 200),
	}
}

rp.cfg.ArmorLabs = {
	rp_bangclaw = {
		{
			Pos = Vector(-2466, -449, -93),
			Ang = Angle(0, -90, 0),
		},
		{
			Pos = Vector(-2511, -449, -93),
			Ang = Angle(0, -90, 0),
		},
	},
}

rp.cfg.PrinterPlates = {
	rp_bangclaw = {
		{
			Pos = Vector(555.703735, 2654.441650, 176.035004),
			Ang = Angle(0.000, -90.008, 0.039),
		},
		{
			Pos = Vector(524.615234, 2654.449219, 175.975967),
			Ang = Angle(-0.093, -82.347, 0.021),
		},
		{
			Pos = Vector(523.341248, 2653.201416, 201.783020),
			Ang = Angle(0.262, -75.942, 0.078),
		},
		{
			Pos = Vector(551.081848, 2659.068848, 201.774979),
			Ang = Angle(0.020, -90.094, -0.014),
		},
		{
			Pos = Vector(554.010498, 2654.513672, 150.123016),
			Ang = Angle(-0.026, -82.093, -0.340),
		},
		{
			Pos = Vector(522.138062, 2653.791992, 150.203247),
			Ang = Angle(-0.000, -84.041, 0.000),
		}

	}
}
-- Theater
rp.cfg.Theaters = {
	rp_bangclaw = {
		Screen = {
			Pos = Vector(2140, -1910, 288.5),
			Ang = Angle(0, 90, 90),
			Scale = 0.13
		},
		Projector = {
			Pos = Vector(2625, -1831.354858, 207),
			Ang = Angle(0, -90, 0)
		},
	}
}

-- Dumpsters
rp.cfg.Dumpsters = {
	rp_bangclaw = {
		{Vector(5948.468262, -1219.282104, 100.031250), Angle(0, 180, 0)},
		{Vector(9183.679688, -2761.521484, 100.031250), Angle(0, 180, 0)},
		{Vector(2924.940918, -2847.497559, 100.031250), Angle(0, 0, 0)},
		{Vector(-1188.652954, -534.227844, 100.031250), Angle(0, -90, 0)},
		{Vector(16.015440, 1321.023071, 100.031250), Angle(0, 0, 0)},
		{Vector(829.340149, -1120.005493, 100.031250), Angle(0, -90, 0)},
		{Vector(3134.559570, 144.031250, -900.968750), Angle(0, 90, 0)},
	}
}

-- Kombat
/*
rp.cfg.KombatRoom = {
	rp_bangclaw = {
		Vector(-5244, -2140, -1247),
		Vector(-4294, -1187, -640),
	},
}

rp.cfg.KombatPos = {
	rp_c18_sup_b2 = {
		Box = {
			{x = 849, y = -150, x2 = 849, y2 = 598},
			{x = 849, y = 598, x2 = 1598, y2 = 598},
			{x = 1598, y = 598, x2 = 1598, y2 = -150},
			{x = 1598, y = -150, x2 = 849, y2 = -2039},
		},
		SpawnPoint = Vector(1223, 224, 300),
		ZCutOff = 280,
		MaxPlayers = 15
	},
	rp_danktown_rc5a = {
		Box = {
			{x = -5150, y = -2046, x2 = -5150, y2 = -1281},
			{x = -5150, y = -1281, x2 = -4385, y2 = -1281},
			{x = -4385, y = -1281, x2 = -4385, y2 = -2046},
			{x = -4385, y = -2046, x2 = -5150, y2 = -2046},

		},
		SpawnPoint = Vector(-4767.435059, -1663.726318, -1020),
		ZCutOff = -1065,
		MaxPlayers = 15
	},
}
*/
-- Event doors
rp.cfg.EventDoor = {
	rp_bangclaw = 2975
}

-- Screens
rp.cfg.Screens = {
	rp_bangclaw = {
		{
			Pos = Vector(192.073532, -4152.112305, -119.182449),
			Ang = Angle(-0.022, 90.014, 89.862)
		}
	}
}


-- Chairs
rp.cfg.Chairs = {
	rp_bangclaw = {
		-- Suburbs
		/*
		{
			Pos = Vector(3549.006836, -2515.422607, -161.233749),
			Ang = Angle(-0.338, 0.421, -0.516),
		},*/
	},
}

rp.cfg.Props = {
	rp_bangclaw = {
		{
			Model = 'models/props/cs_office/Shelves_metal.mdl',
			Pos = Vector( 538, 2655, 144),
			Ang = Angle(0.000, 90.000, -0.000),
		},
		{
			Model = 'models/props_combine/breendesk.mdl',
			Pos = Vector(589, 2433, 144),
			Ang = Angle(0, 0, 0),
		},
	},
}

local hour = (60 * 60)

rp.cfg.PlayTimeRanks = {
	{'Newbie', 0},
	{'New Kid', (hour * 5)},
	{'Getting There', (hour * 10)},
	{'Learner', (hour * 15)},
	{'Toddler', (hour * 20)},
	{'Adolescent', (hour * 25)},
	{'Growing', (hour * 30)},
	{'Street Smart', (hour * 35)},
	{'Someone', (hour * 40)},
	{'Associate', (hour * 45)},
	{'Certified Player', (hour * 50)},
	{'Pistol Enthusiast', (hour * 55)},
	{'Thugphobic', (hour * 60)},
	{'Soldier', (hour * 65)},
	{'Capo', (hour * 70)},
	{'Underboss', (hour * 75)},
	{'Consigliere', (hour * 80)},
	{'Baller', (hour * 85)},
	{'Shotcaller', (hour * 90)},
	{'Pointman', (hour * 95)},
	{'Boss', (hour * 100)},
	{'Know-It-All', (hour * 150)},
	{'Professional Citizen', (hour * 200)},
	{'Org Hopper', (hour * 250)},
	{'Toxic', (hour * 300)},
	{'C4 Tryhard', (hour * 350)},
	{'Cry Baby', (hour * 400)},
	{'Smarked', (hour * 420)},
	{'Bad Raider', (hour * 450)},
	{'Big Bucks Billionaire', (hour * 500)},
	{'Legally Retarded', (hour * 550)},
	{'Illegally Intelligent', (hour * 600)},
	{'Bhopper', (hour * 650)},
	{'Aimbotter', (hour * 700)},
	{'Staff Pet', (hour * 750)},
	{'Building Sign', (hour * 800)},
	{'Hit Camper', (hour * 850)},
	{'nigGA', (hour * 900)},
	{'Flamer', (hour * 950)},
	{'400 IQ', (hour * 1000)},
	{'yeah? so?', (hour * 1100)},
	{'DARB', (hour * 1200)},
	{'shit on shit', (hour * 1300)},
	{'LOAddict', (hour * 1400)},
	{'Delicious Activity', (hour * 1500)},
	{'Blowtorch', (hour * 1600)},
	{'Appeal Detective', (hour * 1700)},
	{'D1vine', (hour * 1800)},
	{'D3vinity', (hour * 1900)},
	{'PonyRPer', (hour * 2000)},
	{'hi, e-girl here ^_^', (hour * 2500), ':heart:'}, -- If the kawaii face or punctuation doesn't work, leave it out
	{'동성애자', (hour * 3000)}, -- If Asian letters don't work, use "Faggot"
	{'LIL BOAT', (hour * 3500)},
	{'shoutbox warrior', (hour * 4000)},
	{'non-trello reader', (hour * 4500)},
	{'Somebody STOP this man', (hour * 5000), ':star:'},
	{'INTer', (hour * 5500)},
	{'That Ain’t Falco', (hour * 6000)},
	{'Double Cheeked Up', (hour * 6500)},
	{'Mr Manager', (hour * 7000)},
	{'Soverengineer', (hour * 7500)},
	{'MrsPepsi', (hour * 8000)},
	{'In Elon We Musk', (hour * 8500)},
	{'OVER 9000!', (hour * 9000)},
	{'Rotard', (hour * 9500)},
	{'are u ok?', (hour * 10000), ':crown:'},
	{'No Life', (hour * 11000)},
	{'AFK GOD', (hour * 12000)},
	{'Corndogger', (hour * 13000)},
	{'aSoberChicken', (hour * 14000)},

	-- Final Ranks of 15,000 Hours and higher color players name-tag as: 255,221,0 (Gold Color) ~ For example :: https://i.imgur.com/h3E6PV4.jpg
	{'cash sma$h', (hour * 15000), ':gem:'},
	{'Shuggster', (hour * 16000)},
	{'K3ngz.net', (hour * 17000)},
	{'legal in the US', (hour * 18000)},
	{'SUPreme', (hour * 19000)},
	{'A P E X', (hour * 20000), ':eggplant:'},
	{'Gmodder', (hour * 25000), ':dumb:'},
}

rp.cfg.DeathTypes = {}
local function newType(name) local id = table.insert(rp.cfg.DeathTypes, name) rp.cfg.DeathTypes[name] = id return id end
rp.cfg.DeathTypeStrings = {
	[newType('Default')]		= 'Вы умерли',
	[newType('Bounty')]			= 'Вы были убиты за деньги',
	[newType('Falling')]		= 'Вы умерли от падения с большой высоты',
	[newType('Goomba')]			= 'Вы были трусливо растоптаны!',
	[newType('Murder')]			= 'Вы были убиты',
	[newType('Hunger')]			= 'Вы умерли от голода',
	[newType('Overdose')]		= 'Вы умерли от передозировки',
	[newType('Prolapse')]		= 'Вы умерли от анального коллапса',
	[newType('Dick')]			= 'Ваш дружок не выдержал нагрузки. Как неловко-то!',
	[newType('STD')]			= 'Вы умерли от болезни',
	[newType('Heroin')]			= 'Зависимость это болезнь',
	[newType('Suicide')]		= 'Вы выбрали самый лёгкий метод',
	[newType('Burgatron')]		= 'Вас съели.. ммм, вкуснятина!',
	[newType('Bleach')]			= 'Капсулы Tide подошли бы лучше для этого',
	[newType('Methhead')]		= 'Грязный наркоман был пойман',
	[newType('CopSuicide')]		= 'Суицид за полицейского.. Очень храбро..',
}
