dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.OpenBail')

function ENT:Initialize()
	self:SetModel('models/props_combine/combine_intmonitor003.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()
end

function ENT:PlayerUse(pl)
	local tbl = {}

	for k, v in pairs(rp.ArrestedPlayers) do
		if v then
			tbl[#tbl + 1] = player.GetBySteamID64(k)
		end
	end

	net.Start('rp.OpenBail')
		net.WriteUInt(#tbl, 8)
		for k, v in ipairs(tbl) do
			net.WritePlayer(v)
			net.WriteUInt(v:GetArrestInfo().ReleaseTime, 32)
		end
	net.Send(pl)
end

rp.AddCommand('bail', function(pl, t)
	if (pl:GetEyeTrace().Entity:GetClass() ~= "bail_machine") and (pl:IsMayor() and pl:GetEyeTrace().Entity:GetClass() ~= "mayor_machine") then return end

	if (not IsValid(t)) or (not t:IsArrested()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerNotInJail'), t)
		return
	end

	if (t == pl) then
		pl:ConCommand('rp 911 Эй, я пытаюсь сбежать из тюрьмы, арестуйте меня!')
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PlayerFuckedBailing'))
		return
	end

	if IsValid(t) then
		local price = pl:IsMayor() and 0 or math.ceil((t:GetArrestInfo().ReleaseTime - CurTime())/60) * rp.cfg.BailCostPerMin
		local karma = math.ceil((t:GetArrestInfo().ReleaseTime - CurTime())/60) * 10

		pl:TakeMoney(price)
		pl:AddKarma(karma)

		rp.Notify(pl, NOTIFY_GREEN, term.Get('PlayerBailedPlayer'), t, rp.FormatMoney(price), karma)
		rp.Notify(t, NOTIFY_GREEN, term.Get('YouWereBailed'), pl)
		t:UnArrest(t)
		t:FlashNotify('Залог', term.Get('YouWereBailed'), pl)

		hook.Call('PlayerBailPlayer', nil, pl, t, price)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetAllowInJail()

hook.Add("InitPostEntity", "Bail", function()
	for k, v in pairs(rp.cfg.BailMachines[game.GetMap()]) do
		local ent = ents.Create("bail_machine")
		ent:SetPos(v.Pos)
		ent:SetAngles(v.Ang)
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():EnableMotion(false)
	end
end)
