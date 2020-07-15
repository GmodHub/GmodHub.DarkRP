-------------------------------------------------
-- Slay
-------------------------------------------------
term.Add('AbusePlayerNotAlive', '# не живой!')
term.Add('AbuseAdminSlainPlayer', '# шлёпнул #.')

ba.AddCommand('Slay', function(pl, targ)
	if (not targ:Alive()) then
		return ba.NOTIFY_ERROR, term.Get('AbusePlayerNotAlive'), targ
	end

	targ:SetVelocity(Vector(0, 0, 2048))
	timer.Simple(0.2, function()
		local effect = EffectData()
		effect:SetOrigin(targ:GetPos())
		effect:SetMagnitude(512)
		effect:SetScale(128)
		util.Effect('Explosion', effect)
		targ:Kill()
	end)

	return ba.NOTIFY_STAFF, term.Get('AbuseAdminSlainPlayer'), pl, targ
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'S'
:SetHelp 'Kills your target'
