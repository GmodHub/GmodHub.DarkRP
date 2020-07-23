util.AddNetworkString('ba.rewards.Claim')

local db = ba.data.GetDB()
/*
net("ba.rewards.Claim", function(len, ply)
	local claimtype = net.ReadString()

	if claimtype == 'award_steam' then
		db:Query("SELECT * FROM steamgroupawards WHERE SteamID64='" .. pl:SteamID64() .. "';", function(data)
			if not data[1] then
				db:Query("UPDATE steamgroupawards SET Reward='award_steam' WHERE SteamID64='" .. pl:SteamID64() .. "';", function()
					hook.Call('PlayerJoinSteamGroup', GAMEMODE, pl)
				end);
			end
		end);
	end
end)

hook.Add('PlayerJoinSteamGroup', function(pl)
	pl:AddCredits(150, 'Steam group join')
	ba.notify_all(term.Get('RewardSteam'), pl)
end)

hook.Add('PlayerJoinVK', function(pl)
	pl:AddCredits(150, 'VK join')
	ba.notify_all(term.Get('RewardVK'), pl)
end)
