ba.banneds = ba.banneds or {}

local db = ba.data.GetDB()

hook.Remove('PlayerSay', 'ba.cmd.PlayerSay')

local function banPlayer(pl)
	if isplayer(pl) and IsValid(pl) then
		if pl:IsJailed() then
			ba.unJailPlayer(pl)
		end
		pl:SetNetVar('IsBanned', true)
		timer.Simple(1, function()
			if not IsValid(pl) then return end
			pl:SetHealth(5)
			pl:ChangeTeam(TEAM_BANNED, true)
			pl:Spawn()
		end)
	end
end

hook.Add('OnPlayerBan', 'rp.OnPlayerBan', function(pl)
	if isplayer(pl) and IsValid(pl) then
		pl:SetBVar('adminmode', false)
		pl:SellProperty()
		for k, v in ipairs(ents.GetAll()) do
			if IsValid(v) and (v:CPPIGetOwner() == pl) then
				v:Remove()
			end
		end

		banPlayer(pl)
	end
end)

hook.Add('OnPlayerUnban', 'rp.OnPlayerUnban', function(steamid)
	local pl = player.Find(steamid)

	if isplayer(pl) and IsValid(pl) then
		pl:SetNetVar('IsBanned', nil)
		pl:ChangeTeam(1, true)
	end
end)

hook.Add('KickOnPlayerBan', 'rp.KickOnPlayerBan', function(pl, reason, time, admin)
	return (time == 0)
end)

hook.Add('playerCanRunCommand', 'rp.playerCanRunCommand', function(pl, cmd)
	if pl:IsBanned() and (cmd ~= 'motd') and (cmd ~= 'smotd') then
		return false, 'You cannot use commands while banned!'
	end
end)

hook.Add('PlayerEntityCreated', 'rp.checkbans', function(pl)
	if ba.banneds[pl:SteamID64()] then
		banPlayer(pl)
	end
end)

hook.Add('CanPlayerEnterVehicle', 'Banned_PlayerEnteredVehicle', function(pl)
	if pl:IsBanned() then
		return false
	end
end)

hook.Add('PlayerCanUseAdminChat', 'banned.PlayerCanUseAdminChat', function(pl)
	if pl:IsBanned() then
		return false
	end
end)

hook.Add('PlayerAdminCheck', 'banned.PlayerIsAdmin', function(pl)
	if pl:GetRankTable():IsAdmin() and !pl:IsRoot() then
		return !pl:IsBanned()
	end
end)
