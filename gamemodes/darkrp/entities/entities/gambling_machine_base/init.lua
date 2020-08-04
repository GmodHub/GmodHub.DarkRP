dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.AgreedPlayers = {}
//ENT.LazyFreeze = true
ENT.RemoveOnJobChange = true

util.AddNetworkString('rp.gambling.Loss')
util.AddNetworkString('rp.gambling.Profit')

function ENT:Initialize()
	self:SetModel("models/props/cs_office/computer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:CPPISetOwner(self.ItemOwner)
	self:Setprice(self.MinPrice)
end

function ENT:CanNetworkUse(pl)
	return self.ItemOwner == pl
end

function ENT:CanUse(pl)
	if self.ItemOwner == pl then return true end

	return self:GetInService() and not self:GetIsPayingOut()
end

function ENT:PlayerUse(pl)
	if(not self.ItemOwner) then return end
	if(not IsValid(self)) then return end

	if not pl:CanAfford(self:Getprice()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GamblingMachinePlayerCannotAfford'), self.PrintName)
		return
	end

	if not self.ItemOwner:CanAfford(self:Getprice()) then
		rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('GamblingMachineHouseCannotAfford'), self.PrintName)
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GamblingMachineOwnerCannotAfford'), self.PrintName)
		self:SetInService(false)
		return
	end

	if(self.AgreedPlayers[pl:SteamID64()] ~= true) then
		rp.question.Create("Вы желаете сыграть в казино ".. self.PrintName .." за " .. rp.FormatMoney(self:Getprice()) .. "?", 15, tostring(self:GetClass() .. pl:SteamID()), function(pl, answer)
		    if tobool(answer) then
		    	self.AgreedPlayers[pl:SteamID64()] = true
		    end
		end, false, pl)
	else
		self:Play(pl)
	end
end

function ENT:PayOut(ply, amount)
	self:SetIsPayingOut(true)

	if(amount > 0) then
		net.Start('rp.gambling.Loss')
			net.WriteUInt(amount, 32)
		net.Send(self.ItemOwner)
		self.ItemOwner:AddMoney(-amount)
		timer.Simple(0.8, function()
			if(not self.ItemOwner) then return end
			ply:AddMoney(amount)
			self:SetIsPayingOut(false)
		end)
		hook.Call('PlayerGamble', GAMEMODE, ply, self.ItemOwner, self, amount, true)
	else
		net.Start('rp.gambling.Profit')
			net.WriteUInt(-amount, 32)
		net.Send(self.ItemOwner)
		ply:AddMoney(amount)
		timer.Simple(0.8, function()
			if(not self.ItemOwner) then return end
			self.ItemOwner:AddMoney(-amount)
			self:SetIsPayingOut(false)
		end)
		hook.Call('PlayerGamble', GAMEMODE, ply, self.ItemOwner, self, amount, false)
	end

	if not self.ItemOwner:CanAfford(self:Getprice()) then
		rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('GamblingMachineHouseCannotAfford'), ENT.PrintName)
		rp.Notify(ply, NOTIFY_ERROR, term.Get('GamblingMachineOwnerCannotAfford'), ENT.PrintName)
		self:SetInService(false)
		return
	end
end

rp.AddCommand("setmachineservice", function(ply)
	local trEnt = ply:GetEyeTrace().Entity
	if(not IsValid(trEnt) or not scripted_ents.IsBasedOn(trEnt:GetClass(), "gambling_machine_base") or trEnt.ItemOwner ~= ply) then return end

	trEnt:SetInService(not trEnt:GetInService())
	if trEnt:GetInService() then
		rp.Notify(ply, NOTIFY_GENERIC, term.Get('GamblingMachineInService'), trEnt.PrintName)
	else
		rp.Notify(ply, NOTIFY_GENERIC, term.Get('GamblingMachineIOutService'), trEnt.PrintName)
	end
end)
