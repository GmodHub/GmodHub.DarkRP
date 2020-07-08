AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("rp.StartHigh")
util.AddNetworkString("rp.EndHigh")

function ENT:Initialize()
	self:SetModel(self.Model);
	
	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);

		self:PhysWake();
		
		self:GetPhysicsObject():SetMass(2);
	end
		local ind = self.Index

end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo);
end

function ENT:Use(activator, caller)
	rp.Drugs[self.Index]:StartHigh()
	net.Start("rp.StartHigh")
	net.WriteUInt(self.Index,6)
	net.Send(caller)
	timer.Create(caller:SteamID64().."Drug"..math.Rand(0,999), 60, 1, function(self)
		net.Start("rp.EndHigh")
		net.WriteUInt(self.Index,6)
		net.Send(caller)		
	end)
    self:Remove();
end

AddCSLuaFile("autorun/client/cl_DrugLogic.lua");

util.AddNetworkString("DrugStatus");
util.AddNetworkString("ClearDrugs");

DRUGS = DRUGS or {};

function RegisterDrug(DRUG)
	DRUG.TickServer = DRUG.TickServer or function(this, pl, stacks, startTime, endTime) end;
	DRUG.StartHighServer = DRUG.StartHighServer or function(this, pl) end;
	DRUG.EndHighServer = DRUG.EndHighServer or function(this, pl) end;

	DRUGS[DRUG.Name] = DRUG;
end

CURRENTHIGHS = CURRENTHIGHS or {};

-- Structure:
-- CURRENTHIGHS["Cocaine"] = {
-- 	plEnt = {
--		stacks = <number>, -- Can be used as a multiplier, or overdosing
--		startTime = <number>,
--		endTime = <number>
--	}
-- }

local pMeta = FindMetaTable("Player");

function pMeta:AddHigh(ID, noKarmaLoss)
	if (!ID or ID == "") then
		return;
	end
	
	local highs = CURRENTHIGHS;
	
	highs[ID] = highs[ID] or {};
	
	high = highs[ID];
	
	local drugRef = DRUGS[ID];
	
	if (!drugRef) then
		return;
	end
	
	if (self.AddKarma and !drugRef.NoKarmaLoss and !noKarmaLoss) then
		self:AddKarma(drugRef.KarmaAmount or -2)
		rp.Notify(self, NOTIFY_ERROR, term.Get('LostKarmaDrugs'), drugRef.KarmaAmount or 2)
	end
	
	if (high[self]) then
		high[self].endTime = CurTime() + drugRef.Duration;
		high[self].stacks = high[self].stacks + 1;
	else
		high[self] = {
			stacks = 1,
			startTime = CurTime(),
			endTime = CurTime() + drugRef.Duration
		};
		
		drugRef:StartHighServer(self);
	end
	
	net.Start("DrugStatus");
		net.WriteString(ID);
		net.WriteBit(true);
		net.WriteFloat(high[self].startTime);
		net.WriteFloat(high[self].endTime);
	net.Send(self);
end

function pMeta:RemoveHigh(ID)
	local highs = CURRENTHIGHS;
	
	if (highs[ID] and highs[ID][self]) then
		highs[ID][self].endTime = CurTime();
	end
end

function pMeta:RemoveAllHighs()
	local highs = CURRENTHIGHS;
	
	for k, v in pairs(highs) do
		for i, l in pairs(v) do
			if (i == self) then
				l.endTime = CurTime();
				l.removingAll = true;
			end
		end
	end
	
	net.Start("ClearDrugs");
	net.Send(self);
end

function TickDrugs()
	local highs = CURRENTHIGHS;
	
	for k, v in pairs(highs) do
		for i, l in pairs(v) do
			if (!i:IsValid()) then
				highs[k][i] = nil;
				continue;
			end
			
			if (CurTime() >= l.endTime) then
				local drugRef = DRUGS[k];
				
				drugRef:EndHighServer(i);
			
				highs[k][i] = nil;
				
				if (!l.removingAll) then
					net.Start("DrugStatus");
						net.WriteString(k);
						net.WriteBit(false);
					net.Send(i);
				end
			else
				local drugRef = DRUGS[k];
				
				drugRef:TickServer(i, stacks, startTime, endTime);
			end
		end
	end
end
hook.Add("Tick", "TickDrugs", TickDrugs);

hook.Add("PlayerDeath", "RemoveDrugHighs", function(pl) pl:RemoveAllHighs(); end);