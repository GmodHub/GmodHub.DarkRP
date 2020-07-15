util.AddNetworkString('ba.rewards.Claim')

local db = ba.data.GetDB()

net("ba.rewards.Claim", function(len, ply)
	local claimtype = net.ReadString()

	if claimtype == 'award_steam' then
		db:query("SELECT * FROM steamgroupawards WHERE SteamID64='" .. pl:SteamID64() .. "';", function(data)
			if data[1] and (tonumber(data[1].InSteamGroup) == 1 and tonumber(data[1].AwardGiven) == 0) then
				db:query("UPDATE steamgroupawards SET AwardGiven=1 WHERE SteamID64='" .. pl:SteamID64() .. "';", function()
					hook.Call('PlayerJoinSteamGroup', GAMEMODE, pl)
				end);
			end
		end);
	end
end)

hook.Add('PlayerJoinSteamGroup', function(pl)
	pl:AddCredits(300, 'Steam group join')
	ba.notify_all(ba.Term('PlayerJoinedSteamGroup'), pl)
end)
