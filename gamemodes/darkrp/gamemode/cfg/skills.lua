SKILL_JAIL = rp.karma.AddSkill {
	Name = 'Bribe The Judge',
	Icon = 'sup/gui/skills/jail.png',
	Description = 'Reduced jail time',
	Hooks = {
		[0] = function() return rp.cfg.ArrestTime end,
		[1] = function() return rp.cfg.ArrestTime * 0.85 end,
		[2] = function() return rp.cfg.ArrestTime * 0.7 end,
		[3] = function() return rp.cfg.ArrestTime * 0.4 end,
	},
	Descriptions = {
		'15% reduction',
		'30% reduction',
		'60% reduction',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

local maxRun = rp.cfg.RunSpeed * 1.15
SKILL_RUN = rp.karma.AddSkill {
	Name = 'Professional Kenyan',
	Icon = 'sup/gui/skills/run.png',
	Description = 'Faster run speed',
	Hooks = {
		[0] = function(speed) return speed end,
		[1] = function(speed, max) return math.Clamp(speed * 1.02, 0, max or maxRun) end,
		[2] = function(speed, max) return math.Clamp(speed * 1.05, 0, max or maxRun) end,
		[3] = function(speed, max) return math.Clamp(speed * 1.1, 0, max or maxRun) end,
	},
	Descriptions = {
		'2% faster',
		'5% faster',
		'10% faster',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

SKILL_JUMP = rp.karma.AddSkill {
	Name = 'Hoodrat',
	Icon = 'sup/gui/skills/jump.png',
	Description = 'Jump higher',
	Hooks = {
		[0] = function(power) return power end,
		[1] = function(power) return power * 1.05 end,
		[2] = function(power) return power * 1.1 end,
		[3] = function(power) return power * 1.15 end,
	},
	Descriptions = {
		'5% higher',
		'10% higher',
		'15% higher',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_LOCKPICK = rp.karma.AddSkill {
	Name = 'Locksmith',
	Icon = 'sup/gui/skills/lockpick.png',
	Description = 'Lockpick faster',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'5% faster',
		'10% faster',
		'15% faster',
		'20% faster'
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
	Icon = 'sup/gui/skills/keypadcracking.png',
	Description = 'Crack scanners/keypads faster',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'5% faster',
		'10% faster',
		'15% faster',
		'20% faster'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}

SKILL_CRAFTING = rp.karma.AddSkill {
	Name = 'Handyman',
	Icon = 'sup/gui/skills/crafting.png',
	Description = 'Craft items faster',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.98 end,
		[2] = function(time) return time * 0.95 end,
		[3] = function(time) return time * 0.9 end,
	},
	Descriptions = {
		'2% faster',
		'5% faster',
		'10% faster',
	},
	Prices = {
		1000,
		5000,
		10000
	}
}

SKILL_SCAVENGE = rp.karma.AddSkill {
	Name = 'Scavenger',
	Icon = 'sup/gui/skills/scavenger.png',
	Description = 'Higher dumpster drop rate',
	Hooks = {
		[0] = function() return math.random(1, 100) end,
		[1] = function() return math.random(10, 100) end,
		[2] = function() return math.random(20, 100) end,
		[3] = function() return math.random(35, 100) end,
	},
	Descriptions = {
		'5% higher',
		'10% higher',
		'20% higher',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_HUNGER = rp.karma.AddSkill {
	Name = 'Big Belly',
	Icon = 'sup/gui/skills/hunger.png',
	Description = 'Higher hunger capacity',
	Hooks = {
		[0] = function() return 100 end,
		[1] = function() return 125 end,
		[2] = function() return 150 end,
		[3] = function() return 175 end,
		[4] = function() return 200 end,
	},
	Descriptions = {
		'125 hunger',
		'150 hunger',
		'175 hunger',
		'200 hunger',
	},
	Prices = {
		1000,
		5000,
		10000,
		15000
	}
}

SKILL_FALL = rp.karma.AddSkill {
	Name = 'Light Feet',
	Icon = 'sup/gui/skills/fall.png',
	Description = 'Lower fall damage',
	Hooks = {
		[0] = function(damage) return damage end,
		[1] = function(damage) return damage * 0.9 end,
		[2] = function(damage) return damage * 0.85 end,
		[3] = function(damage) return damage * 0.8 end,
	},
	Descriptions = {
		'10% lower',
		'15% lower',
		'20% lower',
	},
	Prices = {
		500,
		2500,
		5000
	}
}

SKILL_THUG = rp.karma.AddSkill {
	Name = 'Gainz',
	Icon = 'sup/gui/skills/thug.png',
	Description = 'Thug punch doors faster',
	Hooks = {
		[0] = function(hits) return hits end,
		[1] = function(hits) return hits * 0.95 end,
		[2] = function(hits) return hits * 0.9 end,
		[3] = function(hits) return hits * 0.85 end,
		[4] = function(hits) return hits * 0.8 end,
	},
	Descriptions = {
		'5% faster',
		'10% faster',
		'15% faster',
		'20% faster'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}

SKILL_MEDIC = rp.karma.AddSkill {
	Name = 'Bedside Manner',
	Icon = 'sup/gui/skills/medic.png',
	Description = 'Faster doctor healing',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.95 end,
		[2] = function(time) return time * 0.9 end,
		[3] = function(time) return time * 0.85 end,
		[4] = function(time) return time * 0.8 end,
	},
	Descriptions = {
		'5% faster',
		'10% faster',
		'15% faster',
		'20% faster'
	},
	Prices = {
		1000,
		2000,
		3000,
		4000
	}
}

SKILL_ZIPTIE_BREAK_FREE = rp.karma.AddSkill {
	Name = 'Tiny Hands',
	Icon = 'sup/gui/skills/ziptie.png',
	Description = 'Break free from zipties sooner',
	Hooks = {
		[0] = function(time) return time end,
		[1] = function(time) return time * 0.8 end,
		[2] = function(time) return time * 0.7 end,
		[3] = function(time) return time * 0.6 end,
		[4] = function(time) return time * 0.5 end,
	},
	Descriptions = {
		'20% faster',
		'30% faster',
		'40% faster',
		'50% faster'
	},
	Prices = {
		1000,
		3000,
		6000,
		9000
	}
}
