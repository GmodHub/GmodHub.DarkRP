local db = ba.data.GetDB()

concommand.Add("sgr", function(pl, cmd, args)
	if (!args[1]) then return; end
	
	if (pl.lastsgrrequest and pl.lastsgrrequest > (CurTime() - 5)) then pl:ChatPrint("Please wait"); return; end
	
	pl.lastsgrrequest = CurTime();
	
	if (args[1] == "request") then
		db:query("SELECT * FROM steamgroupawards WHERE SteamID64='" .. pl:SteamID64() .. "';", function(data)
			if (data[1]) then
				if (tonumber(data[1].InSteamGroup) == 1 and tonumber(data[1].AwardGiven) == 0) then
					db:query("UPDATE steamgroupawards SET AwardGiven=1 WHERE SteamID64='" .. pl:SteamID64() .. "';", function()
						hook.Call('PlayerJoinSteamGroup', GAMEMODE, pl)
					end);
				end
			end
		end);
	elseif (args[1] == "delay") then
		local newTime = os.time() + 86400; -- 24h
		db:query("UPDATE steamgroupawards SET NextAskTime='" .. newTime .. "' WHERE SteamID64='" .. pl:SteamID64() .. "';");
	elseif (args[1] == "never") then
		db:query("UPDATE steamgroupawards SET NextAskTime='-1' WHERE SteamID64='" .. pl:SteamID64() .. "';");
	end
end);