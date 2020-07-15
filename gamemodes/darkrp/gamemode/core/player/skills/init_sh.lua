rp.karma = {
	Skills = {}
}

function rp.karma.MoneyToKarma(cost)
	return math.max(math.floor(cost/rp.cfg.SecondMoneyPerKarma), 0)
end


function rp.karma.AddSkill(tab)
	local id = #rp.karma.Skills + 1

	rp.karma.Skills[id] = {
		ID = id,
		Name = tab.Name,
		Description = tab.Description,
		Descriptions = tab.Descriptions or {},
		Hooks = tab.Hooks or {},
		Icon = CLIENT and Material(tab.Icon),
		Prices = tab.Prices,
	}

	rp.karma.Skills[tab.Name] = rp.karma.Skills[id]

	return id
end

function PLAYER:CallSkillHook(skillId, ...)
	local skill = rp.karma.Skills[skillId]
	return skill.Hooks[self:GetSkillLevel(skillId)](...)
end

function PLAYER:GetSkillLevel(skillId)
	local skills = self:GetNetVar('Skills')
	return skills and (skills[skillId] or 0) or 0
end

function PLAYER:CanAffordKarma(price)
	return (price <= self:GetKarma())
end

hook('PlayerDeath', 'Karma.PlayerDeath', function(victim, inflictor, attacker)
	if attacker:IsPlayer() and (attacker ~= victim) and (not victim:IsBanned()) then
		attacker:AddKarma(-2)
		rp.Notify(attacker, NOTIFY_ERROR, term.Get('LostKarma'), '2', 'убийство')
	end
end)
