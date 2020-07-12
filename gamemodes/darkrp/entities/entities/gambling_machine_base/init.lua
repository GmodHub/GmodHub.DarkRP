AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.AgreedPlayers = {}

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
		self.ItemOwner:AddMoney(-amount)
		timer.Simple(1.5, function()
			ply:AddMoney(amount)
			self:SetIsPayingOut(false)
		end)
	else
		ply:AddMoney(amount)
		timer.Simple(1.5, function()
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

for k, v in pairs(ents.FindByClass("gambling_machine_*")) do
	v:Remove()
end