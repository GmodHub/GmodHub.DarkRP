-- Printers

rp.AddEntity("Power Cable", {
			ent = "ch_bitminer_power_cable",
			model = "models/craphead_scripts/bitminers/utility/plug.mdl",
			price = 150,
			max = 5,
			catagory = "Money printing devices",
			cmd = "/buypowercable",
			Setowning_ent = true,
	})

	rp.AddEntity("Generator", {
			ent = "ch_bitminer_power_generator",
			model = "models/craphead_scripts/bitminers/power/generator.mdl",
			price = 1500,
			max = 4,
			catagory = "Money printing devices",
			cmd = "/buypowergenerator",
			Setowning_ent = true,
	})

rp.AddEntity("Solar Panel", {
			ent = "ch_bitminer_power_solar",
			model = "models/craphead_scripts/bitminers/power/solar_panel.mdl",
			price = 3000,
			max = 2,
			catagory = "Money printing devices",
			cmd = "/buysolarpanel",
			Setowning_ent = true,
	})

rp.AddEntity("Power Combiner", {
			ent = "ch_bitminer_power_combiner",
			model = "models/craphead_scripts/bitminers/power/power_combiner.mdl",
			price = 1000,
			max = 2,
			catagory = "Money printing devices",
			cmd = "/buypowercombiner",
			Setowning_ent = true,
	})

rp.AddEntity("Radioisotope Thermoelectric Generator", {
			ent = "ch_bitminer_power_rtg",
			model = "models/craphead_scripts/bitminers/power/rtg.mdl",
			price = 4500,
			max = 2,
			catagory = "Money printing devices",
			cmd = "/buynucleargenerator",
			Setowning_ent = true,
	})

	rp.AddEntity("Bitmining Shelf", {
			ent = "ch_bitminer_shelf",
			model = "models/craphead_scripts/bitminers/rack/rack.mdl",
			price = 5000,
			max = 10,
			catagory = "Money printing devices",
			cmd = "/buyminingshelf",
			Setowning_ent = true,
	})

rp.AddEntity("Cooling Upgrade 1", {
			ent = "ch_bitminer_upgrade_cooling1",
			model = "models/craphead_scripts/bitminers/utility/cooling_upgrade_1.mdl",
			price = 3000,
			max = 10,
			catagory = "Money printing devices",
			cmd = "/buycooling1",
			Setowning_ent = true,
	})

	rp.AddEntity("Cooling Upgrade 2", {
			ent = "ch_bitminer_upgrade_cooling2",
			model = "models/craphead_scripts/bitminers/utility/cooling_upgrade_2.mdl",
			price = 4000,
			max = 10,
			catagory = "Money printing devices",
			cmd = "/buycooling2",
			Setowning_ent = true,
	})

rp.AddEntity("Cooling Upgrade 3", {
			ent = "ch_bitminer_upgrade_cooling3",
			model = "models/craphead_scripts/bitminers/utility/cooling_upgrade_3.mdl",
			price = 5000,
			max = 10,
			catagory = "Money printing devices",
			cmd = "/buycooling3",
			Setowning_ent = true,
	})

	rp.AddEntity("Single Miner", {
			ent = "ch_bitminer_upgrade_miner",
			model = "models/craphead_scripts/bitminers/utility/miner_solo.mdl",
			price = 350,
			max = 8,
			catagory = "Money printing devices",
			cmd = "/buysingleminer",
			Setowning_ent = true,
	})

	rp.AddEntity("RGB Kit Upgrade", {
			ent = "ch_bitminer_upgrade_rgb",
			model = "models/craphead_scripts/bitminers/utility/rgb_kit.mdl",
			price = 1000,
			max = 8,
			catagory = "Money printing devices",
			cmd = "/buyrgbkit",
			Setowning_ent = true,
	})

rp.AddEntity("Power Supply Upgrade", {
			ent = "ch_bitminer_upgrade_ups",
			model = "models/craphead_scripts/bitminers/utility/ups_solo.mdl",
			price = 500,
			max = 8,
			catagory = "Money printing devices",
			cmd = "/buyupsupgrade",
			Setowning_ent = true,
	})

rp.AddEntity("Fuel", {
			ent = "ch_bitminer_power_generator_fuel",
			model = "models/craphead_scripts/bitminers/utility/jerrycan.mdl",
			price = 500,
			max = 8,
			catagory = "Money printing devices",
			cmd = "/buygeneratorfuel",
			Setowning_ent = true,
	})
// end
rp.AddEntity('Денежный Принтер',{
	catagory = 'Money printing devices',
	ent = 'money_printer',
	model = 'models/sup/printer/printer.mdl',
	price = 3000,
	max = 2,
	cmd = '/buyprinter',
	pocket = false
})

rp.AddEntity('Чернильный Картридж',{
	catagory = 'Money printing devices',
	ent = 'money_printer_ink',
	model = 'models/props_lab/reciever01d.mdl',
	price = 1500,
	max = 4,
	cmd = '/buyinker'
})

rp.AddEntity('РемКомплект Принтера',{
	catagory = 'Money printing devices',
	ent = 'money_printer_fix',
	model = 'models/props_c17/tools_wrench01a.mdl',
	price = 500,
	max = 4,
	cmd = '/buyprintfix'
})

rp.AddEntity('Корзина для денег', {
	catagory = 'Money printing devices',
	ent = 'money_basket',
	model = 'models/props_junk/PlasticCrate01a.mdl',
	price = 500,
	max = 4,
	cmd = '/buybasket',
	pocket = false
})

rp.AddEntity('Картина', {
	ent = 'ent_picture',
	model = 'models/props/cs_office/offinspg.mdl',
	price = 2000,
	max = 2,
	cmd = '/buypic',
	pocket = false
})

rp.AddEntity('Металлоискатель', {
	catagory = 'Security',
	ent = 'metal_detector',
	model = 'models/props_wasteland/interior_fence002e.mdl',
	price = 7500,
	max = 1,
	cmd = '/buymetal',
	pocket = false
})

rp.AddEntity('Пустая Коробка', {
	ent = 'spawned_shipment',
	model = 'models/sup/shipment/shimpmentcrate.mdl',
	price = 500,
	max = 5,
	cmd = '/buyemptyship'
})

-- Hobo
rp.AddEntity('Коробка Пожертований', {
	ent = 'donation_box',
	model = 'models/props/CS_militia/footlocker01_open.mdl',
	price = 1500,
	max = 1,
	cmd = '/buybox',
	allowed = {TEAM_HOBO, TEAM_HOBOKING, TEAM_DJ},
	pocket = false
})


-- DJ
rp.AddEntity('Радио', {
	ent = 'media_radio',
	model = 'models/props_lab/citizenradio.mdl',
	price = 1500,
	max = 1,
	cmd = '/buyradio',
	allowed = TEAM_CASIA and {TEAM_DJ, TEAM_CASIA} or TEAM_DJ,
	pocket = false
})

-- Notes
rp.AddEntity('Записка', {
	ent = 'ent_note',
	model = 'models/props_c17/paper01.mdl',
	price = 500,
	max = 2,
	cmd = '/note',
	pocket = false,
	onSpawn = function(ent, pl)
		if (IsValid(pl.LastNote)) then
			pl.LastNote:Remove()
		end

		pl.LastNote = ent

		rp.Notify(pl, NOTIFY_SUCCESS, term.Get('USENote'))
	end
})

-- Mayor
rp.AddShipment('Лицензия на оружие','models/props_lab/clipboard.mdl', 'ent_licence', 3000, 10, true, 500, false, {TEAM_MAYOR})

-- Gun Dealer
rp.AddWeapon('AWP', 'models/weapons/3_snip_awp.mdl', 'swb_awp', 15000, {TEAM_GUN})
rp.AddWeapon('AK47', 'models/weapons/3_rif_ak47.mdl', 'swb_ak47', 13000, {TEAM_GUN})
rp.AddWeapon('Desert Eagle', 'models/weapons/3_pist_deagle.mdl', 'swb_deagle', 9000, {TEAM_GUN})
rp.AddWeapon('Famas', 'models/weapons/3_rif_famas.mdl', 'swb_famas', 11250, {TEAM_GUN})
rp.AddWeapon('Fiveseven', 'models/weapons/3_pist_fiveseven.mdl', 'swb_fiveseven', 8500, {TEAM_GUN})
rp.AddWeapon('P90', 'models/weapons/3_smg_p90.mdl', 'swb_p90', 11000, {TEAM_GUN})
rp.AddWeapon('Glock', 'models/weapons/3_pist_glock18.mdl', 'swb_glock18', 9500, {TEAM_GUN})
rp.AddWeapon('G3', 'models/weapons/3_snip_g3sg1.mdl', 'swb_g3sg1', 13500, {TEAM_GUN})
rp.AddWeapon('MP5', 'models/weapons/3_smg_mp5.mdl', 'swb_mp5', 11500, {TEAM_GUN})
rp.AddWeapon('UMP45', 'models/weapons/3_smg_ump45.mdl', 'swb_ump', 11000, {TEAM_GUN})
rp.AddWeapon('Galil', 'models/weapons/3_rif_galil.mdl', 'swb_galil', 12000, {TEAM_GUN})
rp.AddWeapon('Mac10', 'models/weapons/3_smg_mac10.mdl', 'swb_mac10', 10500, {TEAM_GUN})
rp.AddWeapon('M249', 'models/weapons/3_mach_m249para.mdl', 'swb_m249', 20000, {TEAM_GUN})
rp.AddWeapon('M3 Super 90', 'models/weapons/3_shot_m3super90.mdl', 'swb_m3super90', 12000, {TEAM_GUN})
rp.AddWeapon('P228', 'models/weapons/3_pist_p228.mdl', 'swb_p228', 7500, {TEAM_GUN})
rp.AddWeapon('SG550', 'models/weapons/3_snip_sg550.mdl', 'swb_sg550', 12500, {TEAM_GUN})
rp.AddWeapon('SG552', 'models/weapons/3_rif_sg552.mdl', 'swb_sg552', 11500, {TEAM_GUN})
rp.AddWeapon('AUG', 'models/weapons/3_rif_aug.mdl', 'swb_aug', 13000, {TEAM_GUN})
rp.AddWeapon('Scout', 'models/weapons/3_snip_scout.mdl', 'swb_scout', 10000, {TEAM_GUN})
rp.AddWeapon('TMP', 'models/weapons/3_smg_tmp.mdl', 'swb_tmp', 11500, {TEAM_GUN})
rp.AddWeapon('XM1014', 'models/weapons/3_shot_xm1014.mdl', 'swb_xm1014', 13000, {TEAM_GUN})
rp.AddWeapon('M4A1', 'models/weapons/3_rif_m4a1.mdl', 'swb_m4a1', 13500, {TEAM_GUN})
rp.AddWeapon('USP', 'models/weapons/3_pist_usp.mdl', 'swb_usp', 8000, {TEAM_GUN})
rp.AddWeapon('357', 'models/weapons/w_357.mdl', 'swb_357', 9000, {TEAM_GUN})
rp.AddEntity('Лаборатория боеприпасов', 'lab_ammo', 'models/items/ammocrate_ar2.mdl', 4500, 4, '/buyammolab', TEAM_GUN, false)
rp.AddEntity('Оружейная Лаборатория', 'item_lab_gun', 'models/props/cs_italy/it_mkt_table3.mdl', 2500, 1, '/buyguncrafter', TEAM_GUN, false)

-- Black Market Dealer
rp.AddBMI('C4','models/weapons/2_c4_planted.mdl', 'weapon_c4', 200000, 10, false, 35000, false, {TEAM_BMIDEALER})
rp.AddBMI('Взломщики Кейпадов','models/weapons/w_c4.mdl', 'keypad_cracker', 16000, 10, false, 1050, false, {TEAM_BMIDEALER})
rp.AddBMI('Отмычки','models/sup/weapons/lockpick/lockpick.mdl', 'lockpick', 14000, 10, false, 950, false, {TEAM_BMIDEALER})
rp.AddBMI('Броня','models/props_junk/cardboard_box004a.mdl', 'armor_piece_full', 7500, 10, false, 900, false, {TEAM_BMIDEALER})
rp.AddBMI('Лом','models/weapons/w_crowbar.mdl', 'weapon_crowbar', 5500, 10, false, 700, false, {TEAM_BMIDEALER})
rp.AddBMI('Дубинка','models/weapons/w_stunbaton.mdl', 'weapon_stunstick', 5000, 10, false, 650, false, {TEAM_BMIDEALER})
rp.AddBMI('Палка для освобождения','models/weapons/w_stunbaton.mdl', 'unarrest_baton', 6500, 10, false, 800, false, {TEAM_BMIDEALER})
rp.AddBMI('Нож','models/weapons/w_knife_t.mdl', 'swb_knife', 5000, 10, false, 675, false, {TEAM_BMIDEALER})
rp.AddBMI('Полицейский Щит','models/drover/w_shield.mdl', 'weapon_shield', 8000, 5, false, 2000, false, {TEAM_BMIDEALER})
rp.AddBMI('Фальшивая Лицензия','models/props_lab/clipboard.mdl', 'ent_licence', 9500, 10, false, 1250, false, {TEAM_BMIDEALER})
rp.AddBMI('Маскировка','models/props_c17/SuitCase_Passenger_Physics.mdl', 'ent_disguise', 10000, 10, false, 1250, false, {TEAM_BMIDEALER})
rp.AddBMI('Тазер','models/weapons/w_pistol.mdl', 'weapon_taser', 7500, 10, false, 1000, false, {TEAM_BMIDEALER})
rp.AddBMI('Стяжки', 'models/props/cs_office/Snowman_arm.mdl', 'weapon_ziptie', 25000, 10, false, 950, false, {TEAM_BMIDEALER}, nil, nil, 60)
rp.AddEntity('Раздатчик Брони', 'lab_armor', 'models/props_combine/suit_charger001.mdl', 3500, 4, '/buyarmorlab', TEAM_BMIDEALER, false)
rp.AddEntity('BMI lab', 'item_lab_bmi', 'models/props/cs_italy/it_mkt_table3.mdl', 2500, 1, '/buybmicrafter', TEAM_BMIDEALER, false)
rp.AddShipment('Граната', {
	index = 61,// use custom index so pockets dont fuck up
	model = 'models/weapons/w_npcnade.mdl',
	entity = 'weapon_frag',
	amount = 5,
	price = 500000,
	seperate = false,
	allowed = {TEAM_BMIDEALER}
})
rp.AddShipment('RPG', {
	index = 62,// use custom index so pockets dont fuck up
	model = 'models/weapons/w_rocket_launcher.mdl',
	entity = 'weapon_rpg',
	amount = 5,
	price = 20000000,
	seperate = false,
	allowed = {TEAM_BMIDEALER}
})
rp.AddShipment('Slam', {
	index = 63,
	model = 'models/weapons/w_slam.mdl',
	entity = 'weapon_slam',
	amount = 5,
	price = 25000000,
	seperate = false,
	allowed = {TEAM_BMIDEALER}
})


-- all sellers
rp.AddEntity('Вещевая Лаборатория', 'lab_item', 'models/props_c17/TrapPropeller_Engine.mdl', 4500, 4, '/buyitemlab', {TEAM_GUN, TEAM_BMIDEALER, TEAM_DRUGDEALER, TEAM_BARTENDER, TEAM_DOCTOR}, false)

-- Anarchist
rp.AddShipment('Стяжка', {
	index = 59,
	model = 'models/props/cs_office/Snowman_arm.mdl',
	entity = 'weapon_ziptie',
	amount = 1,
	price = 2500,
	seperate = false,
	allowed = {TEAM_ANARCHIST}
})


-- Medic
rp.AddEntity('Медецинская Лаборатория', 'lab_med', 'models/props_combine/suit_charger001.mdl', 3500, 4, '/buymedlab', TEAM_DOCTOR, false)
rp.AddShipment('Лекарство от СПИДА', {
		index = 52,
		model = 'models/jaanus/aspbtl.mdl',
		entity = 'ent_stdmeds',
		amount = 10,
		price = 1000,
		seperate = false,
		allowed = {TEAM_DOCTOR}
	})

-- drug dealer
rp.AddEntity('Горшок', {
	ent = 'weed_plant',
	model = 'models/alakran/marijuana/pot_empty.mdl',
	price = 250,
	max = 10,
	cmd = '/buypot',
	allowed = {TEAM_DRUGDEALER},
	pocket = false
})

rp.AddEntity('Семена', {
	ent = 'seed_weed',
	model = 'models/Items/AR2_Grenade.mdl',
	price = 40,
	max = 20,
	cmd = '/buyseed',
	allowed = {TEAM_DRUGDEALER}
})

rp.AddEntity('Лаборатория', {
	ent = 'drug_lab',
	model = 'models/props_lab/crematorcase.mdl',
	price = 2500,
	max = 2,
	cmd = '/buydruglab',
	allowed = {TEAM_DRUGDEALER},
	pocket = false
})

rp.AddWeapon('Вейп', 'models/swamponions/vape.mdl', 'weapon_vape', 5000, {TEAM_DRUGDEALER})

-- Bartender
rp.AddEntity('Спиртовая Лаборатория', 'alcohol_lab', 'models/props_junk/plasticbucket001a.mdl', 2500, 2, '/buyalclab', {TEAM_BARTENDER}, false)


rp.AddEntity('Микроволновка', {
	ent = 'microwave',
	model = 'models/props/cs_office/microwave.mdl',
	price = 2000,
	max = 4,
	cmd = '/buymicrowave',
	allowed = TEAM_COOK,
	pocket = false
})

rp.AddEntity('50/50 Игровой Автомат', {
	catagory = 'Gambling devices',
	ent = 'gambling_machine_fiftyfifty',
	model = 'models/props/cs_office/computer.mdl',
	price = 10000,
	max = 2,
	cmd = '/buyfiftyfifty',
	allowed = TEAM_CASINOOWNER,
	pocket = false
})

rp.AddEntity('Рулетка Игровой Автомат', {
	catagory = 'Gambling devices',
	ent = 'gambling_machine_spinwheel',
	model = 'models/props/cs_office/computer.mdl',
	price = 25000,
	max = 2,
	cmd = '/buyspinwheel',
	allowed = TEAM_CASINOOWNER,
	pocket = false
})

rp.AddEntity('Базовый Игровой Автомат', {
	catagory = 'Gambling devices',
	ent = 'gambling_machine_basicslots',
	model = 'models/props/cs_office/computer.mdl',
	price = 35000,
	max = 2,
	cmd = '/buybasicslots',
	allowed = TEAM_CASINOOWNER,
	pocket = false
})

hook.Call('rp.AddEntities', GAMEMODE)

-- Cook
rp.AddFoodItem('Бананы', 'models/props/cs_italy/bananna.mdl', 10)
rp.AddFoodItem('Связка Бананов', 'models/props/cs_italy/bananna_bunch.mdl', 10)
rp.AddFoodItem('Арбуз', 'models/props_junk/watermelon01.mdl', 20)
rp.AddFoodItem('Молоко', 'models/props_junk/garbage_milkcarton002a.mdl', 20)
rp.AddFoodItem('Апельсин', 'models/props/cs_italy/orange.mdl',20)
rp.AddFoodItem('Бургер', 'models/food/burger.mdl', 50)
rp.AddFoodItem('Хотдог', 'models/food/hotdog.mdl', 45)
rp.AddFoodItem('Китайская Лапша', 'models/props_junk/garbage_takeoutcarton001a.mdl', 40)
rp.AddFoodItem('Бобы', 'models/props_junk/garbage_metalcan001a.mdl', 40)
rp.AddFoodItem('Пончик', 'models/noesis/donut.mdl', 40)
rp.AddFoodItem('Рыба', 'models/props/CS_militia/fishriver01.mdl', 40)
rp.AddFoodItem('Заказ Бигсмоука', 'models/props_junk/garbage_bag001a.mdl', 40)

-- Ammo
rp.AddAmmoType('Buckshot', 'Патроны для дробовика', 'models/Items/BoxBuckshot.mdl', 250, 25)
rp.AddAmmoType('Pistol', 'Пистолетные Патроны', 'models/items/357ammobox.mdl', 300, 25)
rp.AddAmmoType('smg1', 'SMG Патроны ', 'models/Items/BoxSRounds.mdl', 325, 100)
rp.AddAmmoType('Rifle', 'Винтовочные Патроны ', 'models/Items/BoxSRounds.mdl', 425, 100)
rp.AddAmmoType('XBowBolt', 'Арбалетная Стрела ', 'models/items/crossbowrounds.mdl', 500, 5, true)
rp.AddAmmoType('RPG_Round', 'RPG Ракета', 'models/buildables/sentry3_rockets.mdl', 1000, 1, true)


-- Copshop
rp.AddCopItem('Riot Shield', {
	Price = 750,
	Weapon = 'weapon_shield',
	Model = 'models/drover/w_shield.mdl',
})

rp.AddCopItem('Тазер', {
	Price = 1000,
	Model = 'models/weapons/w_pistol.mdl',
	Callback = function(pl)
		pl:Give('weapon_taser')
	end
})

rp.AddCopItem('Комплект Патрон', {
	Price = 500,
	Model = 'models/Items/BoxSRounds.mdl',
	Callback = function(pl)
		for k, v in ipairs(rp.ammoTypes) do
			if (not v.special) then
				pl:GiveAmmo(120, v.ammoType, true)
			end
		end
	end
})

rp.AddCopItem('C4', {
	Price = 30000,
	Model = 'models/weapons/2_c4_planted.mdl',
	Callback = function(pl)
		pl:Give('weapon_c4')
	end
})

rp.AddCopItem('Здоровье', {
	Price = 250,
	Model = 'models/Items/HealthKit.mdl',
	Callback = function(pl)
		pl:SetHealth(100)
	end
})

rp.AddCopItem('Броня', {
	Price = 300,
	Model = 'models/props_junk/cardboard_box004a.mdl',
	Callback = function(pl)
		pl:SetArmor(100)
	end
})

timer.Simple(0, function()print('Shipments: '.. #rp.shipments)end)
