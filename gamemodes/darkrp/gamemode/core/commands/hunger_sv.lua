local CurTime 		= CurTime
local math_abs		= math.abs
local math_clamp	= math.Clamp
local math_max 		= math.max

timer.Create("HungerUpdate", 10, 0, function()
	for k, v in ipairs(player.GetAll()) do
		if IsValid(v) and v:Alive() and (v:GetHunger() <= 0) then
			local shouldHunger = hook.Call("PlayerHasHunger", nil, v)
			if (shouldHunger == nil) then shouldHunger = true end

			if (shouldHunger) then
				v:SetHealth(v:Health() - 15)
				v:EmitSound(Sound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav"), SNDLVL_45dB)
				if (v:Health() <= 0) then
					v:Kill()
				end
			end
		end
	end
end)

hook("PlayerSpawn", function(pl)
	if pl:GetNetVar('Energy') then
		pl:SetNetVar("Energy", CurTime() + rp.cfg.HungerRate)
	end
end)

hook("PlayerEntityCreated", function(pl)
	pl:SetNetVar("Energy", CurTime() + rp.cfg.HungerRate)
end)

function PLAYER:SetHunger(amount, noclamp)
	if noclamp then
		amount = math_max(0, (amount/100 * rp.cfg.HungerRate))
	else
		amount = math_clamp((amount/100 * rp.cfg.HungerRate), 0, rp.cfg.HungerRate)
	end
	self:SetNetVar('Energy', CurTime() + amount)
end

function PLAYER:AddHunger(amount)
	self:SetHunger(self:GetHunger() + amount)
end

function PLAYER:TakeHunger(amount)
	self:AddHunger(-math_abs(amount))
end

rp.AddCommand("buyfood", function(pl, food)
	if not rp.Foods[food] then return end

	if pl:GetCount('Food') >= 15 then
		pl:Notify(NOTIFY_ERROR, term.Get('FoodLimitReached'))
		return
	end

	local trace = {}
	trace.start = pl:EyePos()
	trace.endpos = trace.start + pl:GetAimVector() * 85
	trace.filter = pl

	local tr = util.TraceLine(trace)

	if pl:Team() != TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		pl:Notify(NOTIFY_ERROR, term.Get('ThereIsACook'))
		return
	end

	local cost = 50
	if pl:CanAfford(cost) then
		pl:AddMoney(-cost)
	else
		pl:Notify(NOTIFY_ERROR,  term.Get('CannotAfford'))
		return
	end

	rp.Notify(pl, NOTIFY_GREEN,  term.Get('RPItemBought'), food, rp.FormatMoney(cost))

	local SpawnedFood = ents.Create("spawned_food")
	SpawnedFood:SetPos(tr.HitPos)
	SpawnedFood:SetModel(rp.Foods[food].model)
	SpawnedFood.FoodEnergy = rp.Foods[food].amount
	SpawnedFood.ItemOwner = pl
	SpawnedFood:Spawn()

	pl:_AddCount('Food', SpawnedFood)
	return
end)
:AddParam(cmd.STRING)
