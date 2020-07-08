hook('PlayerFootstep', 'rp.police.PlayerFootstep', function(pl, pos, foot, sound, volume, rf)
	if pl:IsCP() and (not pl:IsMayor()) and (not pl:IsDisguised()) then
		pl.StepSoundNum = pl.StepSoundNum and (pl.StepSoundNum == 6 and 1 or (pl.StepSoundNum + 1)) or 1
		pl:EmitSound('npc/footsteps/hardboot_generic' .. pl.StepSoundNum .. '.wav', 75, 100, 0.75)
		return true
	end
end)
