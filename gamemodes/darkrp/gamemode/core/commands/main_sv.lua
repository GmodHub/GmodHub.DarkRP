/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
rp.AddCommand("randomname", function(ply)
	if ply.NextNameChange and ply.NextNameChange > CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('PleaseWaitX'), math.ceil(ply.NextNameChange - CurTime()))
		return ""
	end

	local name = rp.names.Random()
	hook.Call("playerChangedRPName", GAMEMODE, ply, name)
	ply:SetRPName(name)
	ply.NextNameChange = CurTime() + 20
end)

rp.AddCommand("rpname", function(ply, name)

	local len = string.len(name)
	local low = string.lower(name)

	if len > 20 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameLong'), "21")
		return
	elseif len < 3 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameShort'), "2")
		return
	end

	local canChangeName = hook.Call("CanChangeRPName", GAMEMODE, ply, low)
	if canChangeName == false then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotRPName'))
		return
	end

	local allowed = {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ', '-', 'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', 'ё'}

	for k in string.gmatch(name, "%a") do
		if not table.HasValue(allowed, string.lower(k)) then
			rp.Notify(ply, NOTIFY_ERROR, term.Get('RPNameUnallowed'), k)
			return
		end
	end
	hook.Call("playerChangedRPName", GAMEMODE, ply, args)
	ply:SetRPName(name)

end)
:AddParam(cmd.STRING)
:SetCooldown(20)
:AddAlias("name")
:AddAlias("nick")


local function ChangeJob(ply, args)
	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('NeedToWait'), math.ceil(10 - (CurTime() - ply.LastJob)))
		return
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return
	end

	local len = string.len(args)

	if len < 3 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLenShort'), 2)
		return
	end

	if len > 25 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('JobLenLong'), 26)
		return
	end

	local canChangeJob, message, replace = hook.Call("canChangeJob", nil, ply, args)
	if canChangeJob == false then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotJob'))
		return ""
	end

	local job = replace or args
	rp.NotifyAll(NOTIFY_GENERIC, term.Get('ChangeJob'), ply, (string.match(job, '^h?[AaEeIiOoUu]') and 'an' or 'a'), job)

	ply:SetNetVar('job', job)
	return
end
rp.AddCommand("job", ChangeJob)
:AddParam(cmd.STRING)

local function DropWeapon(pl)
	local ent = pl:GetActiveWeapon()
	if not IsValid(ent) then
		return
	end

	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, pl, ent)
	if not canDrop then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotDropWeapon'))
		return
	end

	if IsValid(pl) and IsValid(ent) and ent:GetModel() then
		pl:DropDRPWeapon(ent)
	end
end
rp.AddCommand("drop", DropWeapon)

rp.AddCommand("buyhealth", function(ply)
	local cost = rp.cfg.HealthCost

	if not ply:Alive() then
		return
	end

	if not ply:CanAfford(cost) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	if team.NumPlayers(TEAM_DOCTOR) > 0 then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('MedicExists'))
		return
	end

	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('HealthIsFull'))
		return
	end

	if ply.NextBuyHealth != nil && ply.NextBuyHealth >= CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, term.Get('NeedToWait'), math.Round(ply.NextBuyHealth - CurTime(), 0))
		return
	end

	ply.NextBuyHealth = CurTime() + 30
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	rp.Notify(ply, NOTIFY_GREEN, term.Get('RPItemBought'), 'health', rp.FormatMoney(cost))
	ply:SetHealth(ply.StartHealth)

end)

rp.AddCommand("destroy", function(pl)
	local active = pl:GetActiveWeapon()
	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, pl, active)

	if !canDrop then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotDestroyWeapon'))
		return
	end

	pl:StripWeapon(active)
end)
