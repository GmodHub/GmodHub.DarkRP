/*
-- THIS IS AN EXAMPLE OK

rp.hats.Add {
	name = 'NAME', -- ur retarded if u dont know what this 1 is, make sure the name is unique, shit will break if its not
	price = 2500000, -- ur retarded if u dont know what this 1 is
	model = 'models/player/items/scout/scout_hair.mdl', -- leave this 1 alone
	skin = 0, -- leave this 1 alone

	-- these are all optional, dont add them if u dont need them. If you do need them and there's multiple skins for one model you can paste them for all skins of that model
	offpos = Vector(0, 0, 0), -- if the pos is off (X, Y, Z)
	offang = Angle(0, 0, 0), -- if the angle is off (PITCH, YAW, ROLL)
	scale = 1.0, -- model scale, can be more or less than 1
	infooffset = 0, -- how far your player info is offset, this isnt usually needed
}

*/

rp.hats.Categories = {
	['Purchased'] = 1,
	['Head Warmers'] = 2,
	['Trucker Hats'] = 3,
	['Oddities'] = 4,
	['Ball Caps'] = 5,
	['Scarves'] = 6,
	['Slight Flex'] = 7,
	['I See Your Point!'] = 8,
	['Dose Cancer Cancellation'] = 9,
	['Hipster Phase'] = 10,
	['Smitty Werbenjagermanjensen\'s Collection'] = 11,
	['Ugly Solutions'] = 12,
	['Wraps'] = 13,
	['Skull And Bones'] = 14,
	['Masks'] = 15,
	['$ Rich People Attire $'] = 16,
	['Hotline Danktown'] = 17,
	['Hats You Can\'t Afford'] = 18
}

local APPAREL_HATS, APPAREL_MASKS, APPAREL_GLASSES, APPAREL_SCARVES = 1, 2, 3, 4

-- TF2
rp.hats.Add {
	name = 'Mann Co. Cap',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/demo/demo_cap_online.mdl',
	game = 'tf'
}

rp.hats.Add {
	name = 'Stunt Helmet',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/demo/stunt_helmet.mdl',
	offpos = Vector(0, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Summer Hat',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/demo/summer_hat_demo.mdl',
	scale = 1.05,
	offpos = Vector(0, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Painter Beret',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/spy/spy_beret.mdl',
	scale = 1.1,
	offpos = Vector(-1, 0, 0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Bucket',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/soldier/bucket.mdl',
	offpos = Vector(-2, 0, 1),
	offang = Angle(0,0,180),
	game = 'tf'
}

rp.hats.Add {
	name = 'Leather Hat',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/all_class/pcg_hat_medic.mdl',
	scale = 1.05,
	offpos = Vector(0, 0, 1.5),
	game = 'tf'
}

rp.hats.Add {
	name = 'Cowboy Hat',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/sniper/sniper_crocleather_slouch.mdl',
	scale = 1.05,
	offpos = Vector(1,0,-1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Hard Hat',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/demo/hardhat.mdl',
	scale = 1.1,
	game = 'tf'
}

rp.hats.Add {
	name = 'Hard Hat 2',
	category = 'Oddities',
	price = 5000000,
	model = 'models/props_2fort/hardhat001.mdl',
	scale = 0.65,
	offpos = Vector(-1,0,3.8),
	offang = Angle(0,0,180),
	game = 'tf'
}

rp.hats.Add {
	name = 'Traffic Cone',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/pyro/traffic_cone.mdl',
	scale = 1.1,
	offpos = Vector(-2,0,1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Medic Helmet',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/medic/fwk_medic_stahlhelm.mdl',
	scale = 1.1,
	offpos = Vector(-1, 0, 2),
	game = 'tf'
}

rp.hats.Add {
	name = 'Chef',
	category = 'Oddities',
	price = 5000000,
	model = 'models/chefhat.mdl',
	scale = 1.1,
	offpos = Vector(3.5, 0, 5),
	offang = Angle(0,30,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Armed Authority',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/soldier/armored_authority.mdl',
	scale = 0.93,
	offpos = Vector(2.5,0,1),
	offang = Angle(0,90,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Army Hat',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/demo/veteran_hat.mdl',
	offpos = Vector(0, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Paper Hat',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/spy/paper_hat.mdl',
	game = 'tf'
}

rp.hats.Add {
	name = 'Birthday',
	category = 'Head Warmers',
	price = 250000,
	model = 'models/player/items/all_class/bdayhat_engineer.mdl',
	offpos = Vector(0, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Plunger',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/pyro/pyro_plunger.mdl',
	scale = 1.43,
	offpos = Vector(0, 0, 5),
	offang = Angle(20,0,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Ski Beanie',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/soldier/soldier_skihat_s1.mdl',
	offpos = Vector(1, 0, 3.7),
	game = 'tf'
}

rp.hats.Add {
	name = 'Robin',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/sniper/larrikin_robin.mdl',
	offpos = Vector(0, 0, -0.5),
	game = 'tf'
}

rp.hats.Add {
	name = 'Bunny',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/soldier/soldier_ttg_max.mdl',
	offpos = Vector(0, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Fez',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/spy/fez.mdl',
	scale = 1.2,
	offpos = Vector(2, 0, -90),
	game = 'tf'
}

rp.hats.Add {
	name = 'Santa',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/xms_santa_hat_demo.mdl',
	scale = 1.1,
	offpos = Vector(-1, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Samurai',
	category = '$ Rich People Attire $',
	price = 37500000,
	model = 'models/player/items/soldier/soldier_samurai.mdl',
	scale = 0.85,
	offpos = Vector(0, 0, 8),
	infooffset = 15,
	game = 'tf'
}

rp.hats.Add {
	name = 'Shady',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/pyro/fwk_pyro_flamenco.mdl',
	scale = 1.15,
	offpos = Vector(-1.5, 0, -1.4),
	offang = Angle(0,22.5,0),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Pirate',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/world_traveller_spy.mdl',
	scale = 1.1,
	offpos = Vector(-1, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Shades',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price = 4000000,
	model = 'models/workshop/player/items/all_class/jul13_sweet_shades/jul13_sweet_shades_demo.mdl',
	scale = 1.15,
	offpos = Vector(-0.5, -0.5,2),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Disguise',
	category = 'I See Your Point!',
	price = 15000000,
	model = 'models/workshop_partner/player/items/all_class/hm_disguisehat/hm_disguisehat_demo.mdl',
	scale = 1.15,
	offpos = Vector(-0.5, -0.5,1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Bandit',
	category = 'Slight Flex',
	type = APPAREL_MASKS,
	price = 12500000,
	model = 'models/workshop/player/items/sniper/thief_sniper_hood/thief_sniper_hood.mdl',
	offpos = Vector(6.5,0,-75),
	infooffset = 10,
	game = 'tf'
}

rp.hats.Add {
	name = 'Masquerade',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price = 15000000,
	model = 'models/player/items/spy/spy_party_phantom.mdl',
	scale = 1.05,
	offpos = Vector(0.1,-0.5,1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Headdress',
	category = '$ Rich People Attire $',
	price = 37500000,
	model = 'models/player/items/heavy/heavy_big_chief.mdl',
	infooffset = 15,
	game = 'tf'
}

rp.hats.Add {
	name = 'Wizard Hat',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/all_class/trn_wiz_hat_soldier.mdl',
	scale = 1.05,
	offpos = Vector(-1,0,2.5),
	game = 'tf'
}

rp.hats.Add {
	name = 'Sombrero',
	category = '$ Rich People Attire $',
	price = 37500000,
	model = 'models/player/items/demo/demo_fiesta_sombrero.mdl',
	scale = 1.3,
	offpos = Vector(0, 0, -1.4),
	offang = Angle(0,22.5,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Fedora',
	category = 'Hipster Phase',
	price = 20000000,
	model = 'models/player/items/heavy/capones_capper.mdl',
	offpos = Vector(-1, 0, -0.5),
	game = 'tf'
}

rp.hats.Add {
	name = 'Crown',
	category = 'Hats You Can\'t Afford',
	price = 45000000,
	model = 'models/player/items/demo/crown.mdl',
	scale = 1.05,
	offpos = Vector(-0.5, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'A Well Wrapped Hat',
	category = 'Oddities',
	price = 5000000,
	model = 'models/workshop/player/items/all_class/dec15_a_well_wrapped_hat/dec15_a_well_wrapped_hat_scout.mdl',
	scale = 1.05,
	offpos = Vector(2, 0, -74),
	infooffset = 15,
	game = 'tf'
}

rp.hats.Add {
	name = 'Tipped Lid',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/workshop/player/items/all_class/short2014_tip_of_the_hats/short2014_tip_of_the_hats_scout.mdl',
	scale = 1.05,
	offpos = Vector(80.5, 0, -2.5),
	offang = Angle(0,85,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Counterfeit Billycock',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/spy/fwk_spy_disguisedhat.mdl',
	scale = 1.05,
	offpos = Vector(-0.5, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Cosa Nostra Cap',
	category = 'Oddities',
	price = 5000000,
	model = 'models/player/items/spy/spy_gang_cap.mdl',
	scale = 1.05,
	offpos = Vector(-0.5, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Aviator Assassin',
	category = 'Oddities',
	price = 5000000,
	model = 'models/workshop/player/items/spy/short2014_deadhead/short2014_deadhead.mdl',
	scale = 1.05,
	offpos = Vector(1.5, 0, -78.5),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Chicken Kiev',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/workshop/player/items/heavy/hw2013_heavy_robin/hw2013_heavy_robin.mdl',
	scale = 1.05,
	offpos = Vector(2.2, 0, -83),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Engineer\'s Cap',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/engineer/engineer_train_hat.mdl',
	scale = 1.05,
	offpos = Vector(-1.8, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Texas Tin-Gallon',
	category = 'Oddities',
	price = 5000000,
	model = 'models/workshop/player/items/engineer/robo_engineer_texastingallon/robo_engineer_texastingallon.mdl',
	scale = 1.05,
	offpos = Vector(0, 0.4, 0),
	offang = Angle(0,-85,0),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Wilson Weave',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/starve_scout.mdl',
	scale = 1.05,
	offpos = Vector(-0.5, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Top Notch',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/player/items/all_class/notch_head_heavy.mdl',
	scale = 1.05,
	offpos = Vector(-0.8, 0, 0),
	offang = Angle(0,25,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'MONOCULUS!',
	category = 'Hats You Can\'t Afford',
	type = APPAREL_MASKS,
	price = 45000001,
	model = 'models/player/items/all_class/haunted_eyeball_hat_scout.mdl',
	scale = 1.05,
	offpos = Vector(0, 0, 1),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Dadliest Catch',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/workshop/player/items/all_class/nobody_suspects_a_thing/nobody_suspects_a_thing_scout.mdl',
	scale = 1.35,
	offpos = Vector(0, 0, 0),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Medimedes',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/workshop/player/items/medic/hw2013_medicmedes/hw2013_medicmedes.mdl',
	scale = 1.30,
	offpos = Vector(-0.4, 0, -100),
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Towering Pillar of Hats',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/scout/hat_first_nr.mdl',
	scale = 1.05,
	offpos = Vector(-1.8, 0, 1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Carouser\'s Capotain',
	category = 'Oddities',
	price = 5000000,
	model = 'models/workshop/player/items/demo/inquisitor/inquisitor.mdl',
	scale = 1.05,
	offpos = Vector(79, 0, 1),
	offang = Angle(0,-85,0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Gentle Munitionne of Leisure',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/sd_rocket_scout.mdl',
	scale = 1.35,
	offpos = Vector(0, 0, -1),
	game = 'tf'
}

rp.hats.Add {
	name = 'Crone\'s Dome',
	category = 'Hats You Can\'t Afford',
	price = 45000000,
	model = 'models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl',
	scale = 1.35,
	offpos = Vector(0, 0, 8),
	game = 'tf'
}

rp.hats.Add {
	name = 'Penguin',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/all_penguin.mdl',
	offpos = Vector(0, 6.5, 15),
	offang = Angle(-50,0,0),
	infooffset = 15,
	game = 'tf'
}

rp.hats.Add {
	name = 'The Rift',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/player/items/all_class/all_class_oculus_scout.mdl',
	offpos = Vector(0, 0, 0.5),
	game = 'tf'
}

rp.hats.Add {
	name = 'The Law',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/workshop/player/items/all_class/sbox2014_law/sbox2014_law_scout.mdl',
	offpos = Vector(1.5, 0, -75),
	scale = 1.05,
	game = 'tf'
}

rp.hats.Add {
	name = 'The MK 50',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/workshop/player/items/all_class/ai_spacehelmet/ai_spacehelmet_scout.mdl',
	offpos = Vector(2.5, 0, -75),
	scale = 1.05,
	infooffset = 10,
	game = 'tf'
}

rp.hats.Add {
	name = 'Brown Bomber',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/xms_furcap_scout.mdl',
	offpos = Vector(1.5, 0, -75),
	scale = 1.05,
	offang = Angle(5, 0, 0),
	game = 'tf'
}

rp.hats.Add {
	name = 'Détective Noir',
	category = 'Hipster Phase',
	price = 20000000,
	model = 'models/player/items/spy/spy_detective_noir.mdl',
	offpos = Vector(-1.5, 0, -0.5),
	scale = 1.30,
	game = 'tf'
}

rp.hats.Add {
	name = 'Brigade Helm',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/pyro/fireman_helmet.mdl',
	offpos = Vector(-4.5, 0, -75.5),
	scale = 1.05,
	infooffset = 10,
	game = 'tf'
}

rp.hats.Add {
	name = 'The Face of Mercy',
	category = 'Masks',
	type = APPAREL_MASKS,
	price = 32500000,
	model = 'models/workshop/player/items/pyro/hwn2015_face_of_mercy/hwn2015_face_of_mercy.mdl',
	offpos = Vector(-4.5, 0, -75.5),
	scale = 1.05,
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Pop-eyes',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price = 15000000,
	model = 'models/workshop/player/items/pyro/fall2013_popeyes/fall2013_popeyes.mdl',
	offpos = Vector(-4.5, 0, -75.5),
	scale = 1.05,
	infooffset = 7.5,
	game = 'tf'
}

rp.hats.Add {
	name = 'Noogler ™',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/pyro/pyro_hat.mdl',
	offpos = Vector(-4.5, 0, -95.5),
	scale = 1.30,
	game = 'tf'
}

rp.hats.Add {
	name = 'Barbarian Hair',
	category = 'Slight Flex',
	price = 12500000,
	model = 'models/player/items/all_class/xcom_flattop_scout.mdl',
	offpos = Vector(1.5, 0, -88.5),
	scale = 1.20,
	game = 'tf'
}

rp.hats.Add {
	name = 'Bear Necessities',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price = 37500000,
	model = 'models/workshop/player/items/heavy/jul13_bear_necessitys/jul13_bear_necessitys.mdl',
	offpos = Vector(3.5, 0, -36.5),
	scale = 0.90,
	infooffset = 10,
	game = 'tf'
}

rp.hats.Add {
	name = 'Hero\'s Tail',
	category = '$ Rich People Attire $',
	price = 37500000,
	model = 'models/player/items/scout/scout_hair.mdl',
	offpos = Vector(0, 0, 0),
	scale = 1.12,
	game = 'tf'
}


-- GTA
rp.hats.Add {
	name 	 = 'The Fierce Kodiak',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/bear.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 2),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

/*
rp.hats.Add {
	name 	 = 'models/sal/buffalo.mdl #0',
	category = 'Realism',
	price 	 = 10,
	model	 = 'models/sal/buffalo.mdl',
	skin 	 = 0,
	infooffset = 10
}
*/

rp.hats.Add {
	name 	 = 'The Kitty Cat',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/cat.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 2),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Sneaky Fox',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/fox.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 2),
	offang = Angle(2, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Gingerbread Man',
	category = '$ Rich People Attire $',
	type = APPAREL_MASKS,
	price 	 = 37500000,
	model	 = 'models/sal/gingerbread.mdl',
	skin 	 = 0,
	offpos = Vector(0.5, 0, 2),
	offang = Angle(0, 6, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'America, Fuck Yeah',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/hawk_1.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 0),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'America, Shit Yeah',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/hawk_2.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 0),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mr Owl',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/owl.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 0),
	offang = Angle(2, 3, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Steamboat\'s Favorite Hat',
	category = 'Hats You Can\'t Afford',
	type = APPAREL_MASKS,
	price 	 = 45000001,
	model	 = 'models/sal/penguin.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 2),
	offang = Angle(2, 15, 0),
	scale = 1.1,
	infooffset = 15
}

rp.hats.Add {
	name 	 = 'Piggy Piggy Piggy',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/pig.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 1),
	offang = Angle(4, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bloody Piggy',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/pig.mdl',
	skin 	 = 1,
	offpos = Vector(0, 0, 1),
	offang = Angle(4, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Angry Wolf',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/wolf.mdl',
	skin 	 = 0,
	offpos = Vector(0, 0, 1),
	offang = Angle(4, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #1!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #2!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #3!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #4!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #5!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 4,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'He was #6!',
	category = 'Smitty Werbenjagermanjensen\'s Collection',
	price 	 = 22500000,
	model	 = 'models/sal/acc/fix/beerhat.mdl',
	skin 	 = 5,
	offpos = Vector(0, -0.3, 3.5),
	offang = Angle(2, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Blue',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Savage',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Savage 2',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Savage 3',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Savage 4',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 4,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Royalty',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 5,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Dead',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 6,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Dead 2',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 7,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Skullfire',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 8,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Skullfire 2',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 9,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Skullfire 3',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 10,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Shadow',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 11,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Leather',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 12,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Leather 2',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 13,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of Mercy Hockey',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/sal/acc/fix/mask_2.mdl',
	skin 	 = 14,
	offpos = Vector(1.0, 0, 0.5),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Face of DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'The Motherboard of DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Lava DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Royal Lava DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Shadow DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 4,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Sniper DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 5,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Rusted DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 6,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Electric DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 7,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wooden DOOM',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 35000000,
	model	 = 'models/sal/acc/fix/mask_4.mdl',
	skin 	 = 8,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf White',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Gray',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Black',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Navy Blue',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Red',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 4,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Green',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 5,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Scarf Pink',
	category = 'Scarves',
	type 	 = APPAREL_SCARVES,
	price 	 = 10000000,
	model	 = 'models/sal/acc/fix/scarf01.mdl',
	skin 	 = 6,
	offpos = Vector(1.0, 0, -25),
	offang = Angle(5, 15, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Up-n-Atom',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Smiles',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 1,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Tears',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 2,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Dumb',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 3,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Slick',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 4,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Teeth',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 5,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Innocent',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 6,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Burger Shot',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 7,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Target',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 8,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Devil',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 9,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Cop',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 10,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Yelling',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 11,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Angry',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 12,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Zigzag',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 13,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Skull',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 14,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Dog',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 15,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Ghost',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 16,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Alien',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 17,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Help Me',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 18,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Maze',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 19,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Fuck You',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 20,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of High Class',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 21,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Stickers',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 22,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Beauty',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 23,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Love',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 24,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bag of Black',
	category = 'Ugly Solutions',
	type = APPAREL_MASKS,
	price 	 = 25000000,
	model	 = 'models/sal/halloween/bag.mdl',
	skin 	 = 25,
	offpos = Vector(1, 0, 1.5),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Plague Doctor',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/sal/halloween/doctor.mdl',
	skin 	 = 0,
	offpos = Vector(-0.5, -0.3, 1.25),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Plague Doctor 2',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/sal/halloween/doctor.mdl',
	skin 	 = 1,
	offpos = Vector(-0.5, -0.3, 1.25),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Plague Doctor 3',
	category = 'I See Your Point!',
	type = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/sal/halloween/doctor.mdl',
	skin 	 = 2,
	offpos = Vector(-0.5, -0.3, 1.25),
	offang = Angle(0, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Crime Scene',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap1.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Caution',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap1.mdl',
	skin 	 = 1,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Caution 2',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap1.mdl',
	skin 	 = 2,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Red Arrows',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap1.mdl',
	skin 	 = 3,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Gray',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap2.mdl',
	skin 	 = 0,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Black',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap2.mdl',
	skin 	 = 1,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Light Gray',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap2.mdl',
	skin 	 = 2,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Wrap of Rainbow',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/headwrap2.mdl',
	skin 	 = 3,
	offpos = Vector(1, 0, 1),
	offang = Angle(5, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monkey Mask Brown',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/monkey.mdl',
	skin 	 = 0,
	offpos = Vector(0.7, 0, 1.3),
	offang = Angle(3.5, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monkey Mask Black',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/monkey.mdl',
	skin 	 = 1,
	offpos = Vector(0.7, 0, 1.3),
	offang = Angle(3.5, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monkey Mask Gray',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/monkey.mdl',
	skin 	 = 2,
	offpos = Vector(0.7, 0, 1.3),
	offang = Angle(3.5, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monkey Mask White',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/monkey.mdl',
	skin 	 = 3,
	offpos = Vector(0.7, 0, 1.3),
	offang = Angle(3.5, 5, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Black',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap White',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Beige',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Maroon',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Gray',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 4,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Camo',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 5,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Orange and White',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 6,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Black and White',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 7,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap White and Black',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 8,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Pink Camo',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 9,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ninja Wrap Black and Gold',
	category = 'Wraps',
	type = APPAREL_MASKS,
	price 	 = 27500000,
	model	 = 'models/sal/halloween/ninja.mdl',
	skin 	 = 10,
	offpos = Vector(0, -0.5, 2),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Skull Gray',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/sal/halloween/skull.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.3, 2.6),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Skull Brown',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/sal/halloween/skull.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.3, 2.6),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Skull Light Brown',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/sal/halloween/skull.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.3, 2.6),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Skull Black',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/sal/halloween/skull.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.3, 2.6),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monster Mask',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/zombie.mdl',
	skin 	 = 0,
	offpos = Vector(0.5, -0.3, 2.0),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Monster Mask Gray',
	category = 'Hotline Danktown',
	type = APPAREL_MASKS,
	price 	 = 40000000,
	model	 = 'models/sal/halloween/zombie.mdl',
	skin 	 = 1,
	offpos = Vector(0.5, -0.3, 2.0),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Bandana',
	category = 'Slight Flex',
	type = APPAREL_MASKS,
	price 	 = 12500000,
	model	 = 'models/modified/bandana.mdl',
	skin 	 = 0,
	offpos = Vector(0.5, -0.3, -0.5),
	offang = Angle(0, 0, 0),
	scale = 1.1,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 2',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 3',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 4',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 5',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 4,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 6',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses01.mdl',
	skin 	 = 5,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 7',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses02.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 8',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses02.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 9',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses02.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 10',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses02.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Hipster Glasses 11',
	category = 'I See Your Point!',
	type 	 = APPAREL_GLASSES,
	price 	 = 15000000,
	model	 = 'models/modified/glasses02.mdl',
	skin 	 = 4,
	offpos = Vector(0, -0.35, 3.5),
	offang = Angle(2, 0, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Gray',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 0,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Black',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 1,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat White',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 2,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Beige',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 3,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Red',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 4,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Black and Red',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 5,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Brown',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 6,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Proper Hat Blue',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat01_fix.mdl',
	skin 	 = 7,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Saggy Beanie Red Striped',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat03.mdl',
	skin 	 = 0,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Saggy Beanie Purple',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat03.mdl',
	skin 	 = 1,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Saggy Beanie Red',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat03.mdl',
	skin 	 = 2,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Saggy Beanie White',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat03.mdl',
	skin 	 = 3,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Saggy Beanie Gray Striped',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat03.mdl',
	skin 	 = 4,
	offpos = Vector(0.5, -0.25, 4.5),
	offang = Angle(2, 8, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Beanie Black',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat04.mdl',
	skin 	 = 0,
	offpos = Vector(0, -0.5, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Beanie Gray',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat04.mdl',
	skin 	 = 1,
	offpos = Vector(0, -0.5, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Beanie White Striped',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat04.mdl',
	skin 	 = 2,
	offpos = Vector(0, -0.5, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Beanie Rasta',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat04.mdl',
	skin 	 = 3,
	offpos = Vector(0, -0.5, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Beanie Blue',
	category = 'Hipster Phase',
	price 	 = 20000000,
	model	 = 'models/modified/hat04.mdl',
	skin 	 = 4,
	offpos = Vector(0, -0.5, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Pink',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat05.mdl',
	skin 	 = 1,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Cabby Cap',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat06.mdl',
	skin 	 = 0,
	offpos = Vector(1.5, 0, 4.5),
	offang = Angle(5, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Black and Green',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 0,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Black and Green 2',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 1,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Gray and Black',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 2,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap White and Black',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 3,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Green and White',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 4,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Dark Green and White',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 5,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Maroon and White',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 6,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Blue and Green',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 7,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Brown and White',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 8,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Dark Green and White 2',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 9,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Ball Cap Brown and Red',
	category = 'Ball Caps',
	price 	 = 7500000,
	model	 = 'models/modified/hat07.mdl',
	skin 	 = 1000000,
	offpos = Vector(1.5, -0.3, 4.5),
	offang = Angle(2, 18, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Orange',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Blue and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Brown and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Brown and White 2',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Red and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 4,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Green and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 5,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Black and Multi',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 6,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Black and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 7,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Black and White 2',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 8,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Brown and White',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 9,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Purple and Multi',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 10,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Trucker Cap Brown and White 2',
	category = 'Trucker Hats',
	price 	 = 2500000,
	model	 = 'models/modified/hat08.mdl',
	skin 	 = 11,
	offpos = Vector(1.0, -0.3, 4.5),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Headphones Orange',
	category = 'Dose Cancer Cancellation',
	price 	 = 17500000,
	model	 = 'models/modified/headphones.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, 2.2),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Headphones Purple',
	category = 'Dose Cancer Cancellation',
	price 	 = 17500000,
	model	 = 'models/modified/headphones.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, 0, 2.2),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Headphones Green',
	category = 'Dose Cancer Cancellation',
	price 	 = 17500000,
	model	 = 'models/modified/headphones.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, 0, 2.2),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Headphones Yellow',
	category = 'Dose Cancer Cancellation',
	price 	 = 17500000,
	model	 = 'models/modified/headphones.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, 0, 2.2),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mask of Killers',
	category = 'Masks',
	type = APPAREL_MASKS,
	price 	 = 32500000,
	model	 = 'models/modified/mask5.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mask of Shadows',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/modified/mask6.mdl',
	skin 	 = 0,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mask of Light',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/modified/mask6.mdl',
	skin 	 = 1,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mask of Bones',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/modified/mask6.mdl',
	skin 	 = 2,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}

rp.hats.Add {
	name 	 = 'Mask of Nature',
	category = 'Skull And Bones',
	type = APPAREL_MASKS,
	price 	 = 30000000,
	model	 = 'models/modified/mask6.mdl',
	skin 	 = 3,
	offpos = Vector(1.0, 0, 0),
	offang = Angle(2, 12, 0),
	scale = 1.0,
	infooffset = 10
}


if (CLIENT) then
	local function RenderSpawnIcon_Prop( model, pos, middle, size )

		if ( size < 900 ) then
			size = size * ( 1 - ( size / 900 ) )
		else
			size = size * ( 1 - ( size / 4096 ) )
		end

		size = math.Clamp( size, 5, 1000 )

		local ViewAngle = Angle( 25, 220, 0 )
		local ViewPos = pos + ViewAngle:Forward() * size * -15
		local view = {}

		view.fov		= 4 + size * 0.04
		view.origin		= ViewPos + middle
		view.znear		= 1
		view.zfar		= ViewPos:Distance( pos ) + size * 2
		view.angles		= ViewAngle

		return view

	end

	-- tf2
	local function tf2Generic(a, b, c, d)  b.z = 15 return RenderSpawnIcon_Prop(a, b, c, d * 0.125) end -- some of these are kinda off
	local function tf2Generic2(a, b, c, d)  b.z = 0 return RenderSpawnIcon_Prop(a, b, c, d * 0.125) end

	SpawniconGenFunctions['models/workshop/player/items/heavy/hw2013_heavy_robin/hw2013_heavy_robin.mdl']	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/medic/hw2013_medicmedes/hw2013_medicmedes.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/demo/inquisitor/inquisitor.mdl'] 					= tf2Generic2
	SpawniconGenFunctions['models/workshop/player/items/all_class/dec15_a_well_wrapped_hat/dec15_a_well_wrapped_hat_scout.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/all_class/ai_spacehelmet/ai_spacehelmet_scout.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/pyro/hwn2015_face_of_mercy/hwn2015_face_of_mercy.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/player/items/all_class/xcom_flattop_scout.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/player/items/spy/fez.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/workshop/player/items/spy/short2014_deadhead/short2014_deadhead.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/sniper/thief_sniper_hood/thief_sniper_hood.mdl'] 	= tf2Generic
	SpawniconGenFunctions['models/workshop/player/items/pyro/fall2013_popeyes/fall2013_popeyes.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/player/items/pyro/fireman_helmet.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/player/items/all_class/xms_furcap_scout.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/workshop/player/items/all_class/short2014_tip_of_the_hats/short2014_tip_of_the_hats_scout.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/workshop/player/items/all_class/sbox2014_law/sbox2014_law_scout.mdl'] 	= tf2Generic2
	SpawniconGenFunctions['models/player/items/pyro/pyro_hat.mdl'] 	= tf2Generic2

	SpawniconGenFunctions['models/workshop/player/items/heavy/jul13_bear_necessitys/jul13_bear_necessitys.mdl'] = function(a, b, c, d) b.z = 40 b.y = -12 return RenderSpawnIcon_Prop(a, b, c, d * 0.25) end


	-- custom
	SpawniconGenFunctions['models/modified/hat08.mdl']		= function(a, b, c, d) b.z = -35 return RenderSpawnIcon_Prop(a, b, c, d * 0.15) end

	SpawniconGenFunctions['models/sal/acc/fix/scarf01.mdl']	= function(a, b, c, d) b.z = -19 return RenderSpawnIcon_Prop(a, b, c, d * 0.25) end

	SpawniconGenFunctions['models/modified/bandana.mdl']	= function(a, b, c, d) b.z = -31 return RenderSpawnIcon_Prop(a, b, c, d * 0.15) end

	SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl'] 	= function(a, b, c, d) b.z = -34 return RenderSpawnIcon_Prop(a, b, c, d * 0.16) end
	SpawniconGenFunctions['models/sal/acc/fix/mask_2.mdl']	= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/modified/mask5.mdl'] 		= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/modified/mask6.mdl'] 		= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/sal/pig.mdl'] 			= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/sal/acc/fix/beerhat.mdl']	= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/modified/hat03.mdl']		= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/sal/gingerbread.mdl']		= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/sal/hat01_fix.mdl'] 		= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']
	SpawniconGenFunctions['models/sal/penguin.mdl']			= SpawniconGenFunctions['models/sal/acc/fix/mask_4.mdl']

	SpawniconGenFunctions['models/sal/hawk_1.mdl']			= function(a, b, c, d) b.z = -13 return RenderSpawnIcon_Prop(a, b, c, d * 0.36) end
	SpawniconGenFunctions['models/sal/hawk_2.mdl']			= SpawniconGenFunctions['models/sal/hawk_1.mdl']
	SpawniconGenFunctions['models/sal/owl.mdl']				= SpawniconGenFunctions['models/sal/hawk_1.mdl']
	SpawniconGenFunctions['models/sal/wolf.mdl']			= SpawniconGenFunctions['models/sal/hawk_1.mdl']
	SpawniconGenFunctions['models/sal/fox.mdl']				= SpawniconGenFunctions['models/sal/hawk_1.mdl']
	SpawniconGenFunctions['models/sal/cat.mdl']				= SpawniconGenFunctions['models/sal/hawk_1.mdl']
	SpawniconGenFunctions['models/sal/bear.mdl']			= SpawniconGenFunctions['models/sal/hawk_1.mdl']


	SpawniconGenFunctions['models/modified/glasses01.mdl'] 	= function(a, b, c, d) b.x = 1 b.z = -37 return RenderSpawnIcon_Prop(a, b, c, d * 0.11) end
end




/*
local male_citizens = {TEAM_CITIZEN, TEAM_RAPIST, TEAM_DRUGDEALER, TEAM_PIMP, TEAM_WATCHER}

-- Clothes
rp.AddClothing('Blue Hoodie', {
	File	= 'm_hoodieblue',
	Price	= 250000,
	Teams  	= male_citizens,
}

rp.AddClothing('Red Hoodie', {
	File	= 'm_hoodiered',
	Price	= 250000,
	Teams  	= male_citizens,
}

rp.AddClothing('Misfits Hoodie', {
	File	= 'm_misfits',
	Price	= 1000000,
	Teams  	= male_citizens,
}

rp.AddClothing('Leather Jacket', {
	File	= 'm_leather',
	Price	= 2000000,
	Teams  	= male_citizens,
}

rp.AddClothing('Blue Plaid', {
	File	= 'm_pladblue',
	Price	= 500000,
	Teams  	= male_citizens,
}

rp.AddClothing('Red Plaid', {
	File	= 'm_pladred',
	Price	= 500000,
	Teams  	= male_citizens,
}



/*
rp.AddClothing('Bloody', {
	File	= 'm_bloody1',
	Price	= 25000,
	Teams  	= male_citizens
}

rp.AddClothing('Bloody 2', {
	File	= 'm_bloody2',
	Price	= 25000,
	Teams  	= male_citizens
}

rp.AddClothing('Winter Coat', {
	File	= 'm_coat1',
	Price	= 50000,
	Teams  	= male_citizens
}

rp.AddClothing('Casual Coat', {
	File	= 'm_coat2',
	Price	= 50000,
	Teams  	= male_citizens
}

rp.AddClothing('Casual Coat 2', {
	File	= 'm_coat3',
	Price	= 50000,
	Teams  	= male_citizens
}

rp.AddClothing('Business Man', {
	File	= 'm_business',
	Price	= 1000000,
	Teams  	= male_citizens
}

rp.AddClothing('Misfits Hoodie', {
	File	= 'm_gang1',
	Price	= 2500000,
	Teams  	= male_citizens
}

rp.AddClothing('Suit', {
	File	= 'm_suit1',
	Price	= 10000000,
	Teams  	= male_citizens
}
