SKILL_JAIL = rp.karma.AddSkill {
	Name = 'Подкупить Судью',
	Icon = 'gmh/gui/skills/jail.png',
	Description = 'Уменьшает время ареста',
	Hooks = {
		[0] = function() return rp.cfg.ArrestTime end,
		[1] = function() return rp.cfg.ArrestTime * 0.85 end,
		[2] = function() return rp.cfg.ArrestTime * 0.7 end,
		[3] = function() return rp.cfg.ArrestTime * 0.4 end,
	},
	Descriptions = {
		'На 15% меньше',
		'На 30% меньше',
		'На 60% меньше',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

local maxRun = rp.cfg.RunSpeed * 1.15
SKILL_RUN = rp.karma.AddSkill {
	Name = 'Усейн Болт',
	Icon = 'gmh/gui/skills/run.png',
	Description = 'Увеличивает скорость бега',
	Hooks = {
		[0] = function(speed) return speed end,
		[1] = function(speed, max) return math.Clamp(speed * 1.02, 0, max or maxRun) end,
		[2] = function(speed, max) return math.Clamp(speed * 1.05, 0, max or maxRun) end,
		[3] = function(speed, max) return math.Clamp(speed * 1.1, 0, max or maxRun) end,
	},
	Descriptions = {
		'На 2% быстрее',
		'На 5% быстрее',
		'На 10% быстрее',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

SKILL_JUMP = rp.karma.AddSkill {
	Name = 'Кенгуру',
	Icon = 'gmh/gui/skills/jump.png',
	Description = 'Прыгай выше',
	Hooks = {
		[0] = function(power) return power end,
		[1] = function(power) return power * 1.05 end,
		[2] = function(power) return power * 1.1 end,
		[3] = function(power) return power * 1.15 end,
	},
	Descriptions = {
		'На 5% выше',
		'На 10% выше',
		'На 15% выше',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_LOCKPICK = rp.karma.AddSkill {
	Name = 'Мастер Взлома',
	Icon = 'gmh/gui/skills/lockpick.png',
	Description = 'Взламывай быстрее',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'На 5% быстрее',
		'На 10% быстрее',
		'На 15% быстрее',
		'На 20% быстрее'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}

SKILL_HACK = rp.karma.AddSkill {
	Name = '4N0NYM0U5',
	Icon = 'gmh/gui/skills/keypadcracking.png',
	Description = 'Взламывай кейпады быстрее',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'На 5% быстрее',
		'На 10% быстрее',
		'На 15% быстрее',
		'На 20% быстрее'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}

SKILL_CRAFTING = rp.karma.AddSkill {
	Name = 'Умелые Ручки',
	Icon = 'gmh/gui/skills/crafting.png',
	Description = 'Крафти быстрее',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.98 end,
		[2] = function(time) return time * 0.95 end,
		[3] = function(time) return time * 0.9 end,
	},
	Descriptions = {
		'На 2% быстрее',
		'На 5% быстрее',
		'На 10% быстрее',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

SKILL_SCAVENGE = rp.karma.AddSkill {
	Name = 'Мусорщик',
	Icon = 'gmh/gui/skills/scavenger.png',
	Description = 'Увелечение шанса в мусорках',
	Hooks = {
		[0] = function() return math.random(1, 100) end,
		[1] = function() return math.random(10, 100) end,
		[2] = function() return math.random(20, 100) end,
		[3] = function() return math.random(35, 100) end,
	},
	Descriptions = {
		'На 5% больше',
		'На 10% больше',
		'На 20% больше',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_HUNGER = rp.karma.AddSkill {
	Name = 'Большой Желудок',
	Icon = 'gmh/gui/skills/hunger.png',
	Description = 'Поедайте больше еды',
	Hooks = {
		[0] = function() return 100 end,
		[1] = function() return 125 end,
		[2] = function() return 150 end,
		[3] = function() return 175 end,
		[4] = function() return 200 end,
	},
	Descriptions = {
		'125 еды',
		'150 еды',
		'175 еды',
		'200 еды',
	},
	Prices = {
		1000,
		5000,
		10000,
		15000
	}
}

SKILL_FALL = rp.karma.AddSkill {
	Name = 'Лёгкая Нога',
	Icon = 'gmh/gui/skills/fall.png',
	Description = 'Снижение урона от падения',
	Hooks = {
		[0] = function(damage) return damage end,
		[1] = function(damage) return damage * 0.9 end,
		[2] = function(damage) return damage * 0.85 end,
		[3] = function(damage) return damage * 0.8 end,
	},
	Descriptions = {
		'На 10% меньше',
		'На 15% меньше',
		'На 20% меньше',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_THUG = rp.karma.AddSkill {
	Name = 'Качок',
	Icon = 'gmh/gui/skills/thug.png',
	Description = 'Негр выбивает двери быстрее',
	Hooks = {
		[0] = function(hits) return hits end,
		[1] = function(hits) return hits * 0.95 end,
		[2] = function(hits) return hits * 0.9 end,
		[3] = function(hits) return hits * 0.85 end,
		[4] = function(hits) return hits * 0.8 end,
	},
	Descriptions = {
		'На 5% быстрее',
		'На 10% быстрее',
		'На 15% быстрее',
		'На 20% быстрее'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}

SKILL_MEDIC = rp.karma.AddSkill {
	Name = 'Профессиональный Доктор',
	Icon = 'gmh/gui/skills/medic.png',
	Description = 'Лечите быстрее',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'На 5% быстрее',
		'На 10% быстрее',
		'На 15% быстрее',
		'На 20% быстрее'
	},
	Prices = {
		1000,
		2000,
		3000,
		4000
	}
}

SKILL_ZIPTIE_BREAK_FREE = rp.karma.AddSkill {
	Name = 'Ловкие Ручки',
	Icon = 'gmh/gui/skills/ziptie.png',
	Description = 'Выбирайтесь из стяжек быстрее',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.8 end,
		[2] = function(time) return time * 0.7 end,
		[3] = function(time) return time * 0.6 end,
		[4] = function(time) return time * 0.5 end,
	},
	Descriptions = {
		'На 20% быстрее',
		'На 30% быстрее',
		'На 40% быстрее',
		'На 50% быстрее'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}
