--[[
rp.AddDrug {
	Name  = '',
	Price = ,
	Model = '',
	Time  = 60,
	CanOverdose = true,
	OverdoseChance = .5, -- OR {0.25, 0.75}
	CanGiveSTD 		= true,
	STDChance 		= .5,
	StartHigh = function(pl, stacks)
	end,
	EndHigh = function(pl, stacks)
	end,
	Movement = false,
	Sayings = {
	},
	ClientHooks = {
	}
]]


-- Drug Dealer
rp.AddDrug {
	Name  = 'Трава',
	Price = 300,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl',
	StartHigh = function(pl, stacks)
		if (math.random(0, 10) == 0) then
			pl:Ignite(5, 0)
			pl:Say('БЛЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ')
			return
		end
		pl:SetDSP(6)
		pl:SetGravity(0.2)
		pl:TakeHunger(10)
		pl:AddHealth(25)
	end,
	EndHigh = function(pl, stacks)
		pl:SetDSP(1)
		pl:SetGravity(1)
	end,
	Sayings = {
		'у кго нибд есть злтая рыбка!?1 я хчу злтую рыбку, пж, спс',
		'Мои глаза не красные. О чём ты говоришь?',
		'чуууууууваааааааааак',
		'привет, как писать в чат, я не могу разобраться',
	},
	ColorModify = {
		['$pp_colour_addr'] 		= 0,
		['$pp_colour_addg'] 		= 0,
		['$pp_colour_addb'] 		= 0,
		['$pp_colour_mulr'] 		= 0,
		['$pp_colour_mulg'] 		= 0,
		['$pp_colour_mulb'] 		= 0,
		['$pp_colour_colour'] 		= 0.77,
		['$pp_colour_brightness'] 	= -0.11,
		['$pp_colour_contrast'] 	= 2.62
	},
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawMotionBlur(0.03, 0.77, 0)
			DrawColorModify(inf.ColorModify)
		end,
	}
}

rp.AddDrug {
	Name  = 'Сигареты',
	Price = 200,
	PlaySound = false,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/boxopencigshib.mdl',
	StartHigh = function(pl, stacks)
		if (math.random(0, 10) == 0) then
			pl:Ignite(5, 0)
			pl:Say('я думаю у меня рак')
			return
		end
		local smoke = EffectData()
		smoke:SetOrigin(pl:EyePos())
		util.Effect('drug_weed_smoke', smoke)
	end,
	Sayings = {
		'Я КРУТ.',
	},
	ClientHooks = {
		HUDPaint = function(inf)
			draw.SimpleTextOutlined('Ты куришь. Теперь ты крутой.','Trebuchet24', ScrW()/2, ScrH() * 0.6, Color(255,255,255,math.sin(SysTime() / math.pi) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, ui.col.Red)
		end,
		RenderScreenspaceEffects = function(inf)
			DrawSharpen(1, 1)
		end,
	}
}

rp.AddDrug {
	Name  = 'Героин',
	Price = 1500,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/katharsmodels/syringe_out/syringe_out.mdl',
	Time = 15,
	Karma = 10,
	CanOverdose = true,
	OverdoseChance = {0.2, 0.75},
	CanGiveSTD = true,
	STDChance = {0.2, 0.5, 0.75},
	StartHigh = function(pl, stacks)
		if (pl:Health() > 25) then
			pl:SetHealth(25)
		end

		pl:GodEnable()
	end,
	EndHigh = function(pl, stacks)
		pl:GodDisable()

		if pl:Alive() then
			pl:Kill()
			pl.CurrentDeathReason = 'Heroin'
		end
	end,
	Sayings = {
		'Я НЕПОБЕДИМ!',
	},
	ColorModify = {
		['$pp_colour_addr'] 		= 0,
		['$pp_colour_addg'] 		= 0,
		['$pp_colour_addb'] 		= 0,
		['$pp_colour_mulr'] 		= 0,
		['$pp_colour_mulg'] 		= 0,
		['$pp_colour_mulb'] 		= 0,
		['$pp_colour_colour'] 		= 1,
		['$pp_colour_brightness'] 	= 0,
		['$pp_colour_contrast'] 	= 1
	},
	ClientHooks = {
		HUDPaint = function(inf)
			draw.SimpleTextOutlined('Снова приход!','Trebuchet24', ScrW()/2, ScrH() * 0.6, Color(255,255,255,math.sin(SysTime() / math.pi) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, ui.col.Red)
		end,
		RenderScreenspaceEffects = function(inf)
			DrawMaterialOverlay('highs/shader3', math.sin(SysTime()/math.pi) * 0.05)
			DrawColorModify(inf.ColorModify)
		end,
	}
}

rp.AddDrug {
	Name  = 'ЛСД',
	Price = 350,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/smile/smile.mdl',
	Sayings = {
		'О БОЖЕ, Я ПЕРЕРОДИЛСЯ',
		'ИНТЕРЕСНО, ЧТО ПРОИСХОДИТ, КОГДА Я ОБЛИВАЮСЬ БЕНЗИНОМ? ЭТО ДОЛЖНО БЫТЬ ЛЕКАРСТВО ОТ РАКА, ЧУВАК',
	},
	ColorModify = {
		['$pp_colour_addr'] 		= 0,
		['$pp_colour_addg'] 		= 0,
		['$pp_colour_addb'] 		= 0,
		['$pp_colour_mulr'] 		= 0,
		['$pp_colour_mulg'] 		= 0,
		['$pp_colour_mulb'] 		= 0,
		['$pp_colour_colour'] 		= 4,
		['$pp_colour_brightness'] 	= -0.19,
		['$pp_colour_contrast'] 	= 6.31
	},
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawBloom(0.65, 0.1, 9, 9, 4, 7.7, 255, 255, 255)
			DrawColorModify(inf.ColorModify)
		end,
	}
}

rp.AddDrug {
	Name  = 'Грибы',
	Price = 525,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/ipha/mushroom_small.mdl',
	StartHigh = function(pl, stacks)
		if (math.random(0, 22) == 0) then
			pl:Ignite(5, 0)
			pl:Say('БЛЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ')
			return
		end
		pl:SetGravity(0.135)
	end,
	EndHigh = function(pl, stacks)
		pl:SetGravity(1)
	end,
	ColorModify = {
		['$pp_colour_addr'] 		= 0,
		['$pp_colour_addg'] 		= 0,
		['$pp_colour_addb'] 		= 0,
		['$pp_colour_mulr'] 		= 0,
		['$pp_colour_mulg'] 		= 0,
		['$pp_colour_mulb'] 		= 0,
		['$pp_colour_colour'] 		= 0.63,
		['$pp_colour_brightness'] 	= -0.15,
		['$pp_colour_contrast'] 	= 2.57
	},
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawColorModify(inf.ColorModify)
			DrawSharpen(8.32, 1.03)
		end,
	}
}

rp.AddDrug {
	Name  = 'Кокаин',
	Price = 700,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/cocn.mdl',
	StartHigh = function(pl, stacks)
		if (pl:Health() > 1) then
			pl:Say('У МЕНЯ ИЗ НОСА КАПАЕТ КТО НИБУДЬ ЕЩЕ КАПАЕТ ИЗ НОСА ЭТО ДЕЙСТВИТЕЛЬНО СТРАННО НАДЕЮСЬ Я НЕ ПРОСТУДИЛСЯ')
			pl:SetHealth(pl:Health() / 2)

			pl.DrugOldWalkSpeed = pl.DrugOldWalkSpeed or pl:GetWalkSpeed()
			pl.DrugOldRunSpeed = pl.DrugOldRunSpeed or pl:GetRunSpeed()

			pl:SetWalkSpeed(pl.DrugOldWalkSpeed * 2)
			pl:SetRunSpeed(pl.DrugOldRunSpeed * 2)
		else
			pl:SetWalkSpeed(50)
			pl:SetRunSpeed(100)
			timer.Simple(1, function()
				if (IsValid(pl)) then
					pl:Say('Моё сердце не бьётся..')
					timer.Simple(2, function()
						if (IsValid(pl)) then
							pl:Kill()
						end
					end)
				end
			end)
		end
	end,
	EndHigh = function(pl, stacks)
		if pl.DrugOldWalkSpeed then
			pl:SetWalkSpeed(pl.DrugOldWalkSpeed)
			pl.DrugOldWalkSpeed = nil
		end

		if pl.DrugOldRunSpeed then
			pl:SetRunSpeed(pl.DrugOldRunSpeed)
			pl.DrugOldRunSpeed = nil
		end
	end,
	ColorModify = {
		['$pp_colour_addr'] = 0,
		['$pp_colour_addg'] = 0,
		['$pp_colour_addb'] = 0,
		['$pp_colour_brightness'] = 0,
		['$pp_colour_contrast'] = 1,
		['$pp_colour_mulr'] = 0,
		['$pp_colour_mulg'] = 0,
		['$pp_colour_mulb'] = 0
	},
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawMaterialOverlay('highs/shader3', math.sin(SysTime()/math.pi) * 0.05)
			DrawColorModify(inf.ColorModify)
		end
	}
}

local vec4 = Vector(4, 4, 4)
local vec1 = Vector(1, 1, 1)
rp.AddDrug {
	Name  = 'Мет',
	Price = 600,
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/cocn.mdl',
	Color = Color(0, 150, 250),
	CanGiveSTD = true,
	STDChance = 0.1,
	StartHigh = function(pl, stacks)
		if (pl:Health() > 1) then
			pl:Say('ЭТО ЖУКИ НА МОЕЙ РУКЕ Я ДУМАЮ ЧТО ЖУКИ НА МОЕЙ РУКЕ')

			pl.DrugOldWalkSpeed = pl.DrugOldWalkSpeed or pl:GetWalkSpeed()
			pl.DrugOldRunSpeed = pl.DrugOldRunSpeed or pl:GetRunSpeed()

			pl:SetWalkSpeed(pl.DrugOldWalkSpeed * 2)
			pl:SetRunSpeed(pl.DrugOldRunSpeed * 2)

			pl:ManipulateBoneScale(6, vec4)
			pl:SetHunger(200)
		else
			pl:SetWalkSpeed(50)
			pl:SetRunSpeed(100)
			timer.Simple(1, function()
				if (IsValid(pl)) then
					pl:Say('Моё сердце не бьётся..')
					timer.Simple(2, function()
						if (IsValid(pl)) then
							pl:Kill()
						end
					end)
				end
			end)
		end
	end,
	EndHigh = function(pl, stacks)
		if pl.DrugOldWalkSpeed then
			pl:SetWalkSpeed(pl.DrugOldWalkSpeed)
			pl.DrugOldWalkSpeed = nil
		end

		if pl.DrugOldRunSpeed then
			pl:SetRunSpeed(pl.DrugOldRunSpeed)
			pl.DrugOldRunSpeed = nil
		end
		pl:ManipulateBoneScale(6, vec1)
	end,
	ColorModify = {
		['$pp_colour_addr'] = 0,
		['$pp_colour_addg'] = 0,
		['$pp_colour_addb'] = 0,
		['$pp_colour_brightness'] = -0.15,
		['$pp_colour_contrast'] = 2.57,
		['$pp_colour_mulr'] = 0,
		['$pp_colour_mulg'] = 0,
		['$pp_colour_mulb'] = 0,
		['$pp_colour_colour'] = 0.63,
	},
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawMaterialOverlay('highs/shader3', math.sin(SysTime()/math.pi) * 0.05)
			DrawMotionBlur(0.82, 1, 0)
			DrawColorModify(inf.ColorModify)
			DrawSharpen(8.32, 1.03)
		end
	}
}

rp.AddDrug {
	Name  = 'Соль Для Ванны',
	Price = 1000,
	CanOverdose = true,
	OverdoseChance = {0, 0, 0.5, 0.10, 0.15, 0.20},
	Team  = {TEAM_DRUGDEALER},
	Model = 'models/props_lab/jar01a.mdl',
	Sayings = {
		'ТВОЕ ЛИЦО ВЫГЛЯДИТ ПРОСТО ВОСХИТИТЕЛЬНО',
	},
	StartHigh = function(pl, stacks)
		pl:SetGravity(0.25)

		pl:AddHealth(200)
	end,
	EndHigh = function(pl, stacks)
		pl:SetGravity(1)

		pl:TakeHealth(stacks * 200)
	end,
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawSharpen(-1, 2)
			DrawMaterialOverlay('models/props_lab/Tank_Glass001', 0)
			DrawMotionBlur(0.13, 1, 0.00)
		end
	}
}

rp.AddDrug {
	Name  = 'Отбеливатель',
	Price = 300,
	Team  = {TEAM_DRUGDEALER, TEAM_SJW},
	Model = 'models/props_junk/garbage_plasticbottle001a.mdl',
	Time = 3,
	Sayings = {
		'ПЕЙТЕ ОТБЕЛИВАТЕЛЬ ЭТО ПОЛЕЗНО ДЛЯ ДУШИ',
		'ЭТО НЕ ПОХОЖЕ НА КАПСУЛЫ TIDE',
		'ПРОСТО ОЧИЩАЮ СТАРУЮ ПИЩЕВАРИТЕЛЬНУЮ СИСТЕМУ'
	},
	StartHigh = function(pl, stacks)
		pl:SetHealth(1)
		timer.Simple(math.random(1,3), function()
			if IsValid(pl) and pl:Alive() then
				pl:EmitSound('ambient/creatures/town_child_scream1.wav')
				pl.CurrentDeathReason = 'Bleach'
				pl:Kill()
			end
		end)
	end,
	ClientHooks = {
		RenderScreenspaceEffects = function(inf)
			DrawSharpen(-18, 2)
		end
	}
}


-- Bartender
local function addalcohol(name, model, price, armor, health, blur, lag, index)
	rp.AddDrug {
		Index = index,
		Name  = name,
		Price = price,
		PlaySound = false,
		Team  = {TEAM_BARTENDER},
		Model = model,
		Time = 30,
		Movement = true,
		KarmaLoss = false,
		Sayings = {
			'погодите. паааарни. я должн расскаазать вам о micrsfoft excel!11!',
			'я думаю я люблю её',
		},
		StartHigh = function(pl)
			for i = 1, pl:GetBoneCount() do
				local name = pl:GetBoneName(i):lower()

				if string.find(name, 'foot') or string.find(name, 'calf') or string.find(name, 'thigh') or string.find(name, 'toe') then continue end

				pl:ManipulateBoneJiggle(i, 1)
			end

			pl:AddArmor(armor)
		end,
		EndHigh = function(pl, stacks)
			for i = 1, pl:GetBoneCount() do
				pl:ManipulateBoneJiggle(i, 0)
			end

			pl:TakeArmor(armor * stacks)
			pl:TakeHealth(health * stacks)
		end,
		ClientHooks = {
			RenderScreenspaceEffects = function(inf)
				DrawMotionBlur(0.03, blur, lag)
			end
		}
	}
end

addalcohol('Пиво', 'models/drug_mod/alcohol_can.mdl', 200, 20, 2, 0.4, 0.05)
addalcohol('Балтика', 'models/props_junk/garbage_glassbottle002a.mdl', 300, 30, 3, 0.6, 0.06, 53)
addalcohol('Вино', 'models/props_junk/garbage_glassbottle003a.mdl', 400, 40, 5, 0.8, 0.08, 54)
addalcohol('Водка', 'models/props_junk/GlassBottle01a.mdl', 500, 50, 8, 0.8, 0.08, 55)
addalcohol('Самогон', 'models/props_junk/glassjug01.mdl', 750, 100, 25, 1, 0.09, 56)

rp.AddDrug {
	Index = 57,
	Name  = 'Кола',
	Price = 400,
	PlaySound = false,
	Team  = {TEAM_BARTENDER},
	Model = 'models/props_junk/PopCan01a.mdl',
	Time = 30,
	KarmaLoss = false,
	StartHigh = function(pl, stacks)
		pl:AddHealth(2)
		pl:AddHunger(2)

		pl:EmitSound('vo/npc/male01/moan0' .. math.random(4, 5) .. '.wav')

		pl.DrugOldWalkSpeed = pl.DrugOldWalkSpeed or pl:GetWalkSpeed()
		pl.DrugOldRunSpeed = pl.DrugOldRunSpeed or pl:GetRunSpeed()

		pl:SetWalkSpeed(pl.DrugOldWalkSpeed * 1.1)
		pl:SetRunSpeed(pl.DrugOldRunSpeed * 1.1)
	end,
	EndHigh = function(pl, stacks)
		if pl.DrugOldWalkSpeed then
			pl:SetWalkSpeed(pl.DrugOldWalkSpeed)
			pl.DrugOldWalkSpeed = nil
		end
		if pl.DrugOldRunSpeed then
			pl:SetRunSpeed(pl.DrugOldRunSpeed)
			pl.DrugOldRunSpeed = nil
		end
	end,
}

rp.AddDrug {
	Index = 58,
	Name  = 'Кофе',
	Price = 500,
	PlaySound = false,
	Team  = {TEAM_BARTENDER},
	Model = 'models/props_junk/garbage_coffeemug001a.mdl',
	Time = 30,
	KarmaLoss = false,
	StartHigh = function(pl, stacks)
		pl:RemoveAllHighs()

		pl:AddHealth(2)
		pl:AddHunger(2)

		pl:EmitSound('vo/npc/male01/moan0' .. math.random(4, 5) .. '.wav')

		pl.DrugOldWalkSpeed = pl.DrugOldWalkSpeed or pl:GetWalkSpeed()
		pl.DrugOldRunSpeed = pl.DrugOldRunSpeed or pl:GetRunSpeed()

		pl:SetWalkSpeed(pl.DrugOldWalkSpeed * 1.2)
		pl:SetRunSpeed(pl.DrugOldRunSpeed * 1.2)
	end,
	EndHigh = function(pl, stacks)
		if pl.DrugOldWalkSpeed then
			pl:SetWalkSpeed(pl.DrugOldWalkSpeed)
			pl.DrugOldWalkSpeed = nil
		end
		if pl.DrugOldRunSpeed then
			pl:SetRunSpeed(pl.DrugOldRunSpeed)
			pl.DrugOldRunSpeed = nil
		end
	end,
}

rp.AddDrug {
	Name  = 'Вода',
	Price = 350,
	PlaySound = false,
	Team  = {TEAM_BARTENDER},
	Model = 'models/drug_mod/the_bottle_of_water.mdl',
	Time = 0,
	KarmaLoss = false,
	StartHigh = function(pl, stacks)
		pl:RemoveAllHighs()
		pl:Extinguish()

		pl:AddHealth(2)
		pl:AddHunger(2)

		pl:EmitSound('vo/npc/male01/moan0' .. math.random(4, 5) .. '.wav')
	end
}

rp.AddDrug {
	Name  = 'Молоко',
	Price = 750,
	PlaySound = false,
	Team  = {TEAM_BARTENDER},
	Model = 'models/props_junk/garbage_milkcarton001a.mdl',
	Time = 0,
	KarmaLoss = false,
	StartHigh = function(pl, stacks)
		pl:AddHealth(75)
		pl:AddHunger(75)
	end
}



-- Medic
local snd = Sound 'HealthVial.Touch'
rp.AddDrug {
	Name  = 'Аспирин',
	Price = 500,
	PlaySound = false,
	Team  = {TEAM_DOCTOR},
	Model = 'models/jaanus/aspbtl.mdl',
	Time = 0,
	KarmaLoss = false,
	StartHigh = function(pl, stacks)
		pl:SetHealth(100)
		pl:EmitSound(snd)
	end
}
