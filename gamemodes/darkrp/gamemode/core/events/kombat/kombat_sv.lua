util.AddNetworkString("KombatBegin");
util.AddNetworkString("KombatEnd");
util.AddNetworkString("KombatStartTime")

local KombatWeps = { "weapon_crowbar", "weapon_stunstick", "swb_knife", "weapon_crossbow", "swb_usp", "swb_fiveseven", "swb_357", 'swb_awp', 'swb_scout', 'swb_deagle', 'swb_m249'}

KombatPlayers = KombatPlayers or {};

local kombatQueue = {};
local startKombatIn = false;

//question, voteType, target, time, callback, excludeVoters, fail, extraInfo)
function TriggerKombat()
	local inf = GetKombatInfo();

	if (!inf) then
		return false;
	end
	
	kombatQueue = {};
	startKombatIn = CurTime() + 30;
	
	table.foreach(player.GetAll(), function(k, v)
		if not v:IsBanned() and not v:IsJailed() and not v:IsArrested() then
			GAMEMODE.ques:Create("Вы хотите участвовать в боях без правил?", "kombat" .. v:UserID(), v, 30, function(answer, ent, initiator, target)
				if (tobool(answer)) then
					table.insert(kombatQueue, ent);
					
					net.Start("KombatStartTime")
						net.WriteFloat(startKombatIn)
					net.Send(ent)
				end
			end, v, v);
		end
	end)
end
timer.Create("KombatTimer", 1200, 0, TriggerKombat);

local function StartKombat()
	local inf = GetKombatInfo();
	local wep = table.Random( KombatWeps )
	
	table.foreach(kombatQueue, function(k, v)
		if not v:IsBanned() and not v:IsJailed() and not v:IsArrested() then
			if (!v:Alive()) then v:Spawn(); end

			table.foreach(v:GetWeapons(), function(i, w)
				v.PreKombatWeps = v.PreKombatWeps or {}
				v.PreKombatWeps[i] = w:GetClass()
			end)

			v:RemoveAllHighs(); -- can't have drugs making you god!
			v:SetHealth(100);
			v:SetArmor(0)
			v:SetPos(util.FindEmptyPos(inf.SpawnPoint))
			v:StripWeapons();

			table.foreach(rp.ammoTypes, function(k, a)
				v:GiveAmmo(1000, a.ammoType, false)
			end)

			v:GiveAmmo(1000, 'CROSSBOW', false)
			
			v:Give("hl2_combo_fists");
			v:Give(wep);
			v:SendLua( [[ LocalPlayer():ConCommand( 'play music/HL1_song10.mp3' ) ]] );
			
			KombatPlayers[v:SteamID()] = v;
		end
	end)
	
	net.Start("KombatBegin");
	net.Send(kombatQueue);
end

local function returnPreKombatWeps(pl)
	pl:StripWeapons()
	pl:StripAmmo()
	if not pl:Alive() then pl:Spawn() end
	table.foreach(pl.PreKombatWeps or {}, function(i, w)
		pl:Give(w)
	end)
	pl.PreKombatWeps = nil
end

local function RemoveKombatPlayer(sid, pl)
	net.Start("KombatEnd");
	net.Send(KombatPlayers[sid]);
	
	KombatPlayers[sid] = nil;
	returnPreKombatWeps(pl)
end

local function WinKombat(pl)
	KombatPlayers = {};
	pl:Spawn();
	returnPreKombatWeps(pl)
	net.Start("KombatEnd");
	net.Send(pl);

	if (math.random(1, 50) == 5) then
		local amt = 10000
		for k, v in ipairs(player.GetAll()) do
			v:ChatPrint(pl:Name() .. " выйгра в бою джекпот $10,000!");
		end
		pl:AddMoney(amt)
	else
		local amt = math.random(200, 1000)
		for k, v in ipairs(player.GetAll()) do
			v:ChatPrint(pl:Name() .. " получает $" .. amt .. " за выйгрыш в боях!");
		end
		pl:AddMoney(amt)
	end
end

local b = rp.cfg.KombatRoom[game.GetMap()]
local function KombatTick()
	if (startKombatIn) then
		if (CurTime() >= startKombatIn) then
			startKombatIn = false;

			if (#kombatQueue > 1) then
				for k, v in pairs(kombatQueue) do
					v:ChatPrint("Вы готовы к бою!");
				end
				
				StartKombat();
				
				kombatQueue = {};
			else
				table.foreach(kombatQueue, function(k, v)
					v:ChatPrint("Нужно 2 игрока для боя как минимум.");
				end)
				
				kombatQueue = {};
			end
		end
	end
	
	local numPlayers = table.Count(KombatPlayers);
	if (numPlayers == 0) then return; end
	
	local inf = GetKombatInfo();
	
	for k, v in pairs(KombatPlayers) do
		if (!IsValid(v) or !v:Alive()) then
			RemoveKombatPlayer(k, v);
		else
			if not v:InBox(b[1], b[2]) then
				v:Kill();
				RemoveKombatPlayer(k, v);
			elseif (table.Count(KombatPlayers) == 1) then
				WinKombat(v);
			end
		end
	end
end
hook("Tick", "KombatTick", KombatTick);

hook('PlayerCanPickupWeapon', 'kombat.PlayerCanPickupWeapon', function(pl)
	if KombatPlayers[pl:SteamID()] ~= nil then
		return false
	end
end)