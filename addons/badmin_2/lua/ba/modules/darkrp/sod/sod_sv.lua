hook.Add('PlayerShouldTakeDamage', 'SOD.PlayerShouldTakeDamage', function(pl, attacker)
	if (pl:IsSOD() and (attacker:IsPlayer() and !attacker:IsSuperAdmin())) or (attacker:IsPlayer() and attacker:IsSOD()) then
		return false
	end
end)

hook.Add('PlayerHasHunger', 'SOD.PlayerHasHunger', function(pl)
	if (pl:IsSOD()) then return false end
end)
