rp.cfg.StartMoney 			= 25000
rp.cfg.WelfareAmount		= 200
rp.cfg.WelfareCutoff		= 50000
rp.cfg.StartKarma			= 50

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
rp.cfg.PrintAmount 			= 1000
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
rp.cfg.CreditsURL 		= 'https://superiorservers.co/darkrp/credits/'

rp.cfg.DefaultLaws 		= [[
Murder and assault is illegal.
Breaking and entering is illegal.
No money printing devices, black market items & unlicensed weapons.]]

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
		{ui.col.Purple, 'Did you know we have other servers? Hold C to see/join them!'},
		{ui.col.Gold, 'Please consider supporting SUP\'s continued development by purchasing some upgrades. Click Credit Shop in the F4 menu.'},
		--{ui.col.Gold, 'Credits are currently 25% off for the holidays! Click Credit Shop in the F4 menu.'},
		--{ui.col.Gold, 'Credits are currently 25% off for the first week of July! Click Credit Shop in the F4 menu.'},
		{ui.col.Purple, 'Everyone is welcome on our TeamSpeak server! Connect to {TeamSpeakIP}!'},
		--{ui.col.Purple, 'Join our Discord @ https://discord.gg/FdzJqUK'},
		{ui.col.Gold, 'Communities our size are not cheap to run, support us by purchasing some upgrades. Click Credit Shop in the F4 menu.'},
	}
end

rp.cfg.JailHoleModels =  {
	rp_danktown_rc5a = '*148'
}

rp.cfg.MayorMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(-1024, 5975, 144),
			Ang = Angle(0, -180, 0),
		},
	}
}

-- Bail Machine
rp.cfg.BailMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(-1572.730713, -109.968750, -95.968750),
			Ang = Angle(0, 90, 0),
		},
	}
}

-- Genome Machine
rp.cfg.GenomeMachines = {
	rp_bangclaw = {
		{
			Pos = Vector(-2734.943115, -644.524536, -116.911385),
			Ang = Angle(0, 90, 0)
		}
	}
}

-- Cop shops
rp.cfg.CopShops = {
	rp_bangclaw = {
		Pos = Vector(-1974, 328, -95),
		Ang = Angle(0, 0, 0),
	}
}

-- Drug buyers
rp.cfg.DrugBuyers = {
	rp_bangclaw = {
		{
			Pos = Vector(3503, 6643, -196),
			Ang = Angle(0, 180, 0),
		},
		{
			Pos = Vector(3143.696045, 1865.705322, -195.968750),
			Ang = Angle(0, 175, 0),
		},
		{
			Pos = Vector(4081.072266, -4007.565186, -178.118484),
			Ang = Angle(0, 0, 0),
		},
		{
			Pos = Vector(3272.068604, -5031.198730, -178.202591),
			Ang = Angle(0, 314, 0),
		}
	}
}

rp.cfg.GunBuyers = {
	rp_bangclaw = {
		{
			Pos = Vector(-556, 195, -130),
			Ang = Angle(0, 90, 0),
		},
		{
			Pos = Vector(5860, 1006, -208),
			Ang = Angle(0, 138, 0),
		}
	},
}

rp.cfg.KarmaSellers = {
	rp_bangclaw = {
		{
			Pos = Vector(2005, 910, -130),
			Ang = Angle(0, -1, 0),
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
		Vector(-2505, 374, -162),
		Vector(-1999, 1110, 253)
	},
}

rp.cfg.JailPos = {
	rp_bangclaw = {
		Vector(-2370, 474, -160),
		Vector(-2206, 498, -160),
		Vector(-2078, 995, -160),
		Vector(-2265, 985, -160),
		Vector(-2415, 995, -160)
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
			Pos = Vector(-3246.630127, -53.906345, -5.523953),
			Ang = Angle(0.000, 0.008, 0.039),
		},
		{
			Pos = Vector(-3248.117432, 7.490169, -5.541856),
			Ang = Angle(0.079, -0.398, 0.033),
		},
		{
			Pos = Vector(-3246.828857, 74.266525, -5.553434),
			Ang = Angle(-0.178, 0.475, -0.005),
		},
		{
			Pos = Vector(-3247.869385, 73.188446, 20.296272),
			Ang = Angle(0.002, 0.726, -0.041),
		},
		{
			Pos = Vector(-3247.030762, 8.699111, 20.870522),
			Ang = Angle(0.000, 0.026, -0.000),
		},
		{
			Pos = Vector(-3249.998047, -53.946529, 20.302021),
			Ang = Angle(-0.057, -0.001, -0.124),
		},
		{
			Pos = Vector(-3247.946777, -54.716038, 46.112320),
			Ang = Angle(0.122, 0.410, 0.000),
		},
		{
			Pos = Vector(-3247.144531, 9.474389, 46.154472),
			Ang = Angle(-0.494, 1.522, 0.289),
		},
		{
			Pos = Vector(-3248.197998, 73.867134, 46.037186),
			Ang = Angle(0.007, -0.731, -0.027),
		},

	}
}

-- Theater
rp.cfg.Theaters = {
	rp_bangclaw = {
		Screen = {
			Pos = Vector(-1777.357422, 2120.142334, -132.731308),
			Ang = Angle(0, -90, 0),
			Scale = 0.5
		},
		Projector = {
			Pos = Vector(-1832.160889, 1624.782959, 35.414860),
			Ang = Angle(0, 90, 0),
		},
	}
}

-- Dumpsters
rp.cfg.Dumpsters = {
	rp_bangclaw = {
		{Vector(-391.153748, 179.041397, -170), Angle(0, 90, 0)},
		{Vector(2138.756348, 3734.005859, -170), Angle(0, 90, 0)},
		{Vector(-1710.179688, -391.849091, -170), Angle(0, 90, 0)},
		{Vector(-1745.191162, -2764.980957, -170), Angle(0, 90, 0)},
		{Vector(-1360.241455, -7057.076172, -170), Angle(0, -90, 0)},
		{Vector(2275.526367, -2356.740479, -170), Angle(0, -90, 0)},
		{Vector(1243.700439, 6467.708008, -170), Angle(0, 90, 0)},
		{Vector(3490.085938, 7523.479492, -170), Angle(0, 180, 0)},
		{Vector(-4487.857910, 2833.513428, -180), Angle(0, 0, 0)},
	}
}

-- Kombat
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

-- Event doors
rp.cfg.EventDoor = {
	rp_danktown_rc5a = 2269,
	rp_sundown_rc5a = 2710,
	rp_c18_sup_b2 = 2975
}

-- Screens
rp.cfg.Screens = {
	rp_danktown_rc5a = {
		{
			Pos = Vector(192.073532, -4152.112305, -119.182449),
			Ang = Angle(-0.022, 90.014, 89.862)
		},
		{
			Pos = Vector(1591.417725, -4824.032227, -121.144485),
			Ang = Angle(-0.005, -89.985, 90.055)
		},
		{
			Pos = Vector(3527.745605, -2360.010986, -117.471344),
			Ang = Angle(-0.004, 89.944, 89.983)
		},
		{
			Pos = Vector(-1512.036133, -496.560547, 58.249847),
			Ang = Angle(-0.000, -0.000, 90.000)
		},
		{
			Pos = Vector(-2748.726563, -240.068100, 62.362835),
			Ang = Angle(0, 90, 90)
		}
	},
	rp_c18_sup_b2 = {
		{
			Pos = Vector(1169.289307, -1374.122925, 1702.968262),
			Ang = Angle(0.016, -179.929, 90.114),
		}
	},
	rp_mojave_sup_b1 = {
		{
			Pos = Vector(-7603.600098, 9046.600586, 422.354980),
			Ang = Angle(0.000, 90.000, 90.000),
		}
	}
}


-- Chairs
rp.cfg.Chairs = {
	rp_danktown_rc5a = {
		-- Theater
		{
			Pos = Vector(-1731.564453, -3645.615967, -100.723839),
			Ang = Angle(0.238, -179.504, -0.432),
		},
		{
			Pos = Vector(-1703.051270, -3645.684570, -100.701653),
			Ang = Angle(0.011, -179.493, -0.418),
		},
		{
			Pos = Vector(-1729.249878, -3737.817627, -132.821823),
			Ang = Angle(0.020, -178.527, 0.060),
		},
		{
			Pos = Vector(-1702.296387, -3737.509033, -132.773483),
			Ang = Angle(0.422, -179.463, -0.569),
		},
		{
			Pos = Vector(-1731.589233, -3817.744385, -156.728653),
			Ang = Angle(-0.004, -179.552, -0.019),
		},
		{
			Pos = Vector(-1701.063599, -3817.550781, -156.652725),
			Ang = Angle(0.060, -179.758, -0.778),
		},
		{
			Pos = Vector(-1729.485474, -3897.789063, -180.772949),
			Ang = Angle(0.126, -179.535, 0.190),
		},
		{
			Pos = Vector(-1702.839355, -3897.715332, -180.689087),
			Ang = Angle(0.004, -179.524, -0.316),
		},
		{
			Pos = Vector(-1729.610718, -3977.543457, -204.596222),
			Ang = Angle(0.042, -179.589, -0.956),
		},
		{
			Pos = Vector(-1701.670898, -3977.282227, -203.010895),
			Ang = Angle(2.987, -178.177, -2.211),
		},
		{
			Pos = Vector(-1610.193237, -3645.838623, -100.742279),
			Ang = Angle(-0.077, -179.343, 0.337),
		},
		{
			Pos = Vector(-1581.725220, -3645.707520, -100.765984),
			Ang = Angle(0.072, -179.504, -0.309),
		},
		{
			Pos = Vector(-1609.779297, -3737.700195, -132.790039),
			Ang = Angle(0.056, -179.659, -0.056),
		},
		{
			Pos = Vector(-1580.147461, -3737.750488, -132.757706),
			Ang = Angle(-0.060, -179.604, 0.153),
		},
		{
			Pos = Vector(-1608.622559, -3817.730957, -156.750214),
			Ang = Angle(-0.026, -179.665, -0.002),
		},
		{
			Pos = Vector(-1580.586182, -3817.901123, -156.772278),
			Ang = Angle(-0.004, -179.564, 0.494),
		},
		{
			Pos = Vector(-1612.928223, -3897.768311, -180.710678),
			Ang = Angle(-0.045, -179.564, 0.049),
		},
		{
			Pos = Vector(-1581.055786, -3897.884033, -180.719070),
			Ang = Angle(0.343, -179.360, 0.486),
		},
		{
			Pos = Vector(-1608.657227, -3976.583984, -203.842468),
			Ang = Angle(-0.026, -179.558, -6.543),
		},
		{
			Pos = Vector(-1583.221069, -3976.298096, -203.309647),
			Ang = Angle(0.048, -179.536, -8.115),
		},
		{
			Pos = Vector(-1488.901855, -3645.800293, -100.718460),
			Ang = Angle(-0.049, -179.664, -0.000),
		},
		{
			Pos = Vector(-1460.292847, -3644.964844, -100.057228),
			Ang = Angle(-0.053, -179.542, -4.864),
		},
		{
			Pos = Vector(-1487.031860, -3737.685059, -132.731125),
			Ang = Angle(-0.081, -179.517, 0.250),
		},
		{
			Pos = Vector(-1460.241699, -3737.618408, -132.577042),
			Ang = Angle(-0.643, -179.567, -0.283),
		},
		{
			Pos = Vector(-1490.804932, -3817.771973, -156.744659),
			Ang = Angle(0.005, -179.733, 0.273),
		},
		{
			Pos = Vector(-1463.141357, -3817.792725, -156.711197),
			Ang = Angle(-0.000, -179.303, 0.000),
		},
		{
			Pos = Vector(-1490.471924, -3897.776611, -180.713181),
			Ang = Angle(-0.013, -179.472, -0.000),
		},
		{
			Pos = Vector(-1461.719849, -3897.834229, -180.713028),
			Ang = Angle(-0.000, -179.517, 0.015),
		},
		{
			Pos = Vector(-1488.297241, -3977.824219, -204.774323),
			Ang = Angle(-0.042, -179.524, -0.109),
		},
		{
			Pos = Vector(-1462.823486, -3977.192139, -204.224701),
			Ang = Angle(0.035, -179.510, -3.711),
		},
		{
			Pos = Vector(-1372.112305, -3977.800293, -204.732910),
			Ang = Angle(-0.072, -179.524, 0.087),
		},
		{
			Pos = Vector(-1342.349487, -3977.846680, -204.730820),
			Ang = Angle(0.035, -179.980, 0.048),
		},
		{
			Pos = Vector(-1370.317993, -3897.690430, -180.759384),
			Ang = Angle(0.016, -179.699, -0.140),
		},
		{
			Pos = Vector(-1337.774780, -3897.781250, -180.712112),
			Ang = Angle(0.003, -179.509, -0.000),
		},
		{
			Pos = Vector(-1341.285522, -3816.656250, -155.811096),
			Ang = Angle(-0.359, -179.511, -6.610),
		},
		{
			Pos = Vector(-1369.693970, -3817.853760, -156.791916),
			Ang = Angle(-0.413, -179.572, 0.070),
		},
		{
			Pos = Vector(-1371.079956, -3737.418701, -132.394012),
			Ang = Angle(0.073, -179.500, -2.452),
		},
		{
			Pos = Vector(-1342.832397, -3737.768555, -132.711411),
			Ang = Angle(0.005, -179.567, -0.006),
		},
		{
			Pos = Vector(-1339.403809, -3644.067139, -99.289665),
			Ang = Angle(-0.096, -179.557, -9.539),
		},
		{
			Pos = Vector(-1370.393188, -3646.721680, -100.737137),
			Ang = Angle(-0.097, -174.208, 0.118),
		},

		-- Hobo Cave
		{
			Pos = Vector(-1549.337158, -1130.263672, -471.946136),
			Ang = Angle(-0.036, 90.863, 3.647),
		},

		-- Church
		{
			Pos = Vector(3649.137695, -4371.481934, -49.082443),
			Ang = Angle(-0.000, -180.000, 0.000),
		},

		{
			Pos = Vector(3729.037109, -4370.927246, -49.851120),
			Ang = Angle(-0.133, -179.652, -0.956),
		},

		{
			Pos = Vector(3393.709961, -4369.885742, -49.681652),
			Ang = Angle(0.123, -179.515, -4.003),
		},

		{
			Pos = Vector(3472.867920, -4372.720215, -49.387493),
			Ang = Angle(0.009, -179.734, 2.795),
		},

		{
			Pos = Vector(3647.681641, -4468.352539, -50.565071),
			Ang = Angle(0.084, 179.990, 2.682),
		},

		{
			Pos = Vector(3728.352295, -4468.161621, -50.492611),
			Ang = Angle(0.010, -179.020, 1.909),
		},

		{
			Pos = Vector(3392.137207, -4564.449707, -49.068180),
			Ang = Angle(0.014, -179.997, 0.733),
		},

		{
			Pos = Vector(3470.946533, -4563.831543, -50.297462),
			Ang = Angle(0.010, 179.972, 1.007),
		},

		{
			Pos = Vector(3646.605957, -4564.632324, -50.695850),
			Ang = Angle(-0.124, -178.331, 3.666),
		},

		{
			Pos = Vector(3727.091553, -4563.842285, -50.444618),
			Ang = Angle(0.173, -179.782, 1.802),
		},

		{
			Pos = Vector(3730.233398, -4660.279785, -50.488777),
			Ang = Angle(-0.017, -179.620, 2.983),
		},

		{
			Pos = Vector(3647.270996, -4658.860352, -51.455208),
			Ang = Angle(-0.000, 180.000, 0.000),
		},

		{
			Pos = Vector(3470.981201, -4659.593262, -50.293987),
			Ang = Angle(0.000, -180.000, 0.001),
		},

		{
			Pos = Vector(3393.085449, -4659.330078, -50.138157),
			Ang = Angle(0.123, -179.680, -0.157),
		},


		-- Suburbs
		/*{
			Pos = Vector(154.634430, -4299.436035, -161.210129),
			Ang = Angle(0.411, 2.598, -0.349),
		},
		{
			Pos = Vector(228.768723, -4301.159180, -161.050980),
			Ang = Angle(0.085, 0.490, -0.647),
		},
		{
			Pos = Vector(1610.299194, -4668.538086, -161.025620),
			Ang = Angle(-0.007, -179.757, -1.441),
		},
		{
			Pos = Vector(1569.563232, -4668.491699, -161.100311),
			Ang = Angle(0.013, -179.707, -1.040),
		},
		{
			Pos = Vector(3507.941406, -2515.254883, -161.303360),
			Ang = Angle(0.050, 0.499, 0.136),
		},
		{
			Pos = Vector(3549.006836, -2515.422607, -161.233749),
			Ang = Angle(-0.338, 0.421, -0.516),
		},*/
	},
}
rp.cfg.Chairs['rp_sundown_rc5a'] = rp.cfg.Chairs['rp_danktown_rc5a']

rp.cfg.Props = {
	rp_c18_sup_b2 = {
		{
			Model = 'models/props/cs_assault/camera.mdl',
			Pos = Vector(2562.733887, 483.196869, 1186.797363),
			Ang = Angle(0.000, -90.000, -0.000),
		},
		{
			Model = 'models/props/cs_office/shelves_metal.mdl',
			Pos = Vector(2821.496826, 347.707947, 1056.496338),
			Ang = Angle(0.034, -0.090, -0.009),
		},
	},
	rp_mojave_sup_b1 = {
		{
			Model = 'models/props/cs_assault/camera.mdl',
			Pos = Vector(-7162.375000, 8160.641113, 207.770020),
			Ang = Angle(0.000, -0.000, 0.000),
		},
		{
			Model = 'models/props/cs_office/shelves_metal.mdl',
			Pos = Vector(-7006.591797, 8174.436035, 96.423820),
			Ang = Angle(0.026, -89.986, -0.058),
		},
	}

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
	{'Dumb', (hour * 25000), ':dumb:'},
}

rp.cfg.DeathTypes = {}
local function newType(name) local id = table.insert(rp.cfg.DeathTypes, name) rp.cfg.DeathTypes[name] = id return id end
rp.cfg.DeathTypeStrings = {
	[newType('Default')]		= 'You are dead',
	[newType('Bounty')]			= 'You were killed for a bounty',
	[newType('Falling')]		= 'You fell to your death',
	[newType('Goomba')]			= 'You were freakin\' stomped!',
	[newType('Murder')]			= 'You were murdered',
	[newType('Hunger')]			= 'You starved to death',
	[newType('Overdose')]		= 'You overdosed',
	[newType('Prolapse')]		= 'You died from anal prolapse',
	[newType('Dick')]			= 'Your dick fell off. Clumsy!',
	[newType('STD')]			= 'You died from an STD',
	[newType('Heroin')]			= 'Addiction is a disease',
	[newType('Suicide')]		= 'You took the easy way out',
	[newType('Burgatron')]		= 'You got eaten.. mmm, tasty!',
	[newType('Bleach')]			= 'Tide pods are better',
	[newType('Methhead')]		= 'Dirty meth heads got ya',
	[newType('Zombie')]			= 'A victim to the undead..',
	[newType('CopSuicide')]		= 'Suicide by cop.. Very Brave..',
	[newType('AntlionGuard')]	= 'Crushed by the Antlion Guard. Ouch.'
}
