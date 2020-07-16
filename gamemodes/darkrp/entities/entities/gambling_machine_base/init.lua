AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.AgreedPlayers = {}
ENT.LazyFreeze = true

util.AddNetworkString('rp.gambling.Loss')
util.AddNetworkString('rp.gambling.Profit')

local function SetMachineService(ply)
	local trEnt = ply:GetEyeTrace().Entity
	if(not IsValid(trEnt) or not string.StartWith(trEnt:GetClass(), "gambling_machine") or trEnt.ItemOwner ~= ply) then return end

	trEnt:SetInService(not trEnt:GetInService())
end
rp.AddCommand("setmachineservice", SetMachineService)

function ENT:Initialize()
	self:SetModel("models/props/cs_office/computer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:Setprice(500)
	self.HP = 100
end

function ENT:PayOut(ply, amount)
	self:SetIsPayingOut(true)

	if(amount > 0) then
		net.Start('rp.gambling.Loss')
			net.WriteUInt(amount, 32)
		net.Send(self.ItemOwner)
		self.ItemOwner:AddMoney(-amount)
		timer.Simple(1.5, function()
			if(not self.ItemOwner) then return end
			ply:AddMoney(amount)
			self:SetIsPayingOut(false)
		end)
	else
		net.Start('rp.gambling.Profit')
			net.WriteUInt(-amount, 32)
		net.Send(self.ItemOwner)
		ply:AddMoney(amount)
		timer.Simple(1, function()
			if(not self.ItemOwner) then return end
			self.ItemOwner:AddMoney(-amount)
			self:SetIsPayingOut(false)
		end)
	end
end

function ENT:OnTakeDamage(dmg)
	self.HP = self.HP - dmg:GetDamage()

	if (self.HP <= 0) then
		self:Explode()
		self:Remove()
	end
end
