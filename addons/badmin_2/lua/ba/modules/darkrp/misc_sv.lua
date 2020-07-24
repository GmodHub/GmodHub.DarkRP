local function mergeVIP(pl)
	ba.data.SetRank(pl, 'vip', 'vip' , 0, function(data)
		ba.notify(pl, ba.Term('YourVIPRestored'))
	end)
end

hook.Add('playerRankLoaded', 'datamerger.playerRankLoaded', function(pl)
	timer.Simple(10, function()
		if (!IsValid(pl)) then return end

		if ((pl:HasUpgrade('vip') or pl:HasUpgrade('vip_package')) and !pl:IsVIP()) then
			mergeVIP(pl)
		end
	end)
end)

hook.Add( "PlayerButtonDown", "rp.Motd.Show", function( pl, button )
	if (button == KEY_F10) then
		pl:ConCommand('ba motd')
	end
end)
