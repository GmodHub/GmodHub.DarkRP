dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString("rp.StartHigh")
util.AddNetworkString("rp.EndHigh")

CurrentHighs = CurrentHighs or {};

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

end

function ENT:Use(activator, caller)
	local ind = self.Index
	local drug = rp.Drugs[ind]
	CurrentHighs[caller] = CurrentHighs[caller] or {}
	local highs = CurrentHighs[caller]

	if highs[ind] then
		highs[ind].endTime = CurTime() + (drug.Time or 60)
		highs[ind].stacks = highs[ind].stacks + 1
	else
		highs[ind] = {
			endTime = CurTime() + (drug.Time or 60),
			stacks = 1,
		}
	end

	// STD Chance
	if drug.CanGiveSTD then
		local std = 0

		if istable(drug.STDChance) then
			std = drug.STDChance[highs[ind].stacks] or drug.STDChance[#drug.STDChance]
		else
			std = drug.STDChance
		end

		if math.Rand(0, 1) <= std then
			caller:GiveSTD("Гепатит")
		end
	end

	// Karma lost
	if drug.Karma then
		caller:TakeKarma(drug.Karma)
		rp.Notify(caller, NOTIFY_ERROR, term.Get('LostKarmaDrugs'), drug.Karma)
	end

	// Overdose Chance
	if drug.CanOverdose then
		local overdose = 0

		if istable(drug.OverdoseChance) then
			overdose = drug.OverdoseChance[highs[ind].stacks] or drug.OverdoseChance[#drug.OverdoseChance]
		else
			overdose = drug.OverdoseChance
		end

		if math.Rand(0, 1) <= overdose then
			caller:Kill()
		end
	end

	rp.Drugs[ind].StartHigh(caller)
	net.Start("rp.StartHigh")
		net.WriteUInt(ind, 6)
	net.Send(caller)
	self:Remove()

end

function PLAYER:RemoveAllHighs()
	CurrentHighs[self] = CurrentHighs[self] or {}
	local highs = CurrentHighs[self];

	for k, v in pairs(highs) do
		v.endTime = CurTime()
	end

end

hook("InitPostEntity", function()
	timer.Create("DrugsThink", 1, 0, function()
		for pl, drugs in pairs(CurrentHighs) do
			for k,v in pairs(drugs) do
				if v.endTime and CurTime() >= v.endTime then
					rp.Drugs[k].EndHigh(pl, v.stacks)
					net.Start("rp.EndHigh")
						net.WriteUInt(k, 6)
					net.Send(pl)
					drugs[k] = nil
				end
			end
		end
	end)
end)

hook.Add("PlayerDeath", "RemoveDrugHighs", function(pl)
	pl:RemoveAllHighs()
end)
