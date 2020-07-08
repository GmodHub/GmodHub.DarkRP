-- Printer
rp.RegisterEvent('Printer', {
	NiceName = 'Printer',
	Hooks = {
		['calcPrintAmount'] = function(amt)
			return (amt * 1.5)
		end,
	}
})

-- VIP
rp.RegisterEvent('VIP', {
	NiceName = 'VIP',
	Hooks = {
		['PlayerVIPCheck'] = function(pl)
			return true
		end,
	}
})

-- Salary
rp.RegisterEvent('Salary', {
	NiceName = 'Salary',
	Hooks = {
		['PlayerPayDay'] = function(pl, salary)
			return (salary * 2)
		end,
	}
})

-- Free Runner
rp.RegisterEvent('Parkour', {
	NiceName = 'Parkour',
	Hooks = {
		['PlayerLoadout'] = function(pl)
			pl:Give('climb_swep')
		end,
	},
	OnStart = function()
		for k, v in ipairs(player.GetAll()) do
			v:Give('climb_swep')
		end
	end,
})

-- BURGATRON
rp.RegisterEvent('BURGATRON', {
	NiceName = 'BURGATRON',
	Hooks = {
		['PlayerHasHunger'] = function(pl)
			if (pl.HungerImmune) then return false end
		end,
		['PlayerLoadout'] = function(pl)
			pl:Give('weapon_burgatron')
		end,
		['PlayerDeath'] = function(pl)
			pl.HungerImmune = nil
		end,
		['KeyPress'] = function(pl, key)
			if (key == IN_USE) then
				local tr = pl:GetEyeTrace()
				
				if (tr.Entity and tr.Entity:IsPlayer() and tr.Entity.IsBurger) then
					tr.Entity:Kill();
					
					pl.HungerImmune = true;
					
					pl:EmitSound("vo/sandwicheat09.wav", 100, 100)
					
					pl:Notify(NOTIFY_GREEN, rp.Term('BURGHungerImmune'))
					tr.Entity:Notify(NOTIFY_GREEN, rp.Term('BURGNotPeople'))
				end
			end
		end
	},
	OnStart = function()
		for k, v in ipairs(player.GetAll()) do
			v:Give("weapon_burgatron");
		end
	end,
	OnEnd = function()
		for k, v in ipairs(player.GetAll()) do
			if (v:GetActiveWeapon():IsValid() and v:GetActiveWeapon():GetClass() == "weapon_burgatron") then
				v:SelectWeapon("weapon_physgun")
			end
			
			v.HungerImmune = nil
			if (not v:IsRoot()) then
				v:StripWeapon("weapon_burgatron")
			end
		end
	end
})