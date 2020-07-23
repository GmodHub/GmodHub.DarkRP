local db = rp._Stats

function rp.karma.BuySkill(pl, id)
	local skill = rp.karma.Skills[id]

	if not skill then return end

	local id = skill.ID
	local cost = skill.Prices[pl:GetSkillLevel(id) + 1]

	if not cost or not id then return end

	if not pl:CanAffordKarma(cost) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	pl:TakeKarma(cost)

	local skills = pl:GetNetVar('Skills') or {}
	local level = pl:GetSkillLevel(id) + 1

	skills[id] = level

	db:Query('UPDATE player_data SET Skills=? WHERE SteamID=' .. pl:SteamID64() .. ';', util.TableToJSON(skills), function(data)

		pl:SetNetVar('Skills', skills)
		pl:Notify(NOTIFY_SUCCESS, term.Get('UpgradedSkill'), skill.Name, level)

	end)

end

hook('PlayerDeath', 'Karma.PlayerDeath', function(victim, inflictor, attacker)
	if attacker:IsPlayer() and (attacker ~= victim) and (not victim:IsBanned()) then
		attacker:TakeKarma(5)
		rp.Notify(attacker, NOTIFY_ERROR, term.Get('LostKarma'), '5', 'убийство')
	end
end)

rp.AddCommand('buyskill', function(pl, skill)
	if (not rp.karma.Skills[skill]) then return end
	rp.karma.BuySkill(pl, skill)
end)
:AddParam(cmd.STRING)
