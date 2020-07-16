AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString('rp.ItemLabCraft')
util.AddNetworkString('rp.ItemLabRefill')

ENT.SeizeReward = 500
ENT.WantReason = 'Black Market Item (Drug lab)'
ENT.LazyFreeze = true

ENT.RemoveOnJobChange = true

function ENT:Initialize()
	self:SetModel(self.MainModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:SetMetal(3)
	self.HP = 100
end

function ENT:OnTakeDamage(dmg)
	self.HP = self.HP - dmg:GetDamage()

	if (self.HP <= 0) then
		self:Explode()
	end
end

function ENT:Explode()
	timer.Destroy(self:EntIndex() .. 'Drug')
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)

	self:Remove()

	if IsValid(self.ItemOwner) then
		rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('DrugLabExploded'))
	end
end


function ENT:Crafting(class, crafter)
	local time = crafter:CallSkillHook(SKILL_CRAFTING, math.random(15, 60))
	self:SetCraftTime(CurTime() + time)

	timer.Create(self:EntIndex() .. 'Lab', time, 1, function()
		if IsValid(self) then

			local e = ents.Create(class)
			e:SetPos(self:GetPos() + ((self:GetAngles():Up() * 40) + (self:GetAngles():Forward() * 0)))
			e:Spawn()
			e:Activate()
			self:SetCraftTime(0)
		end
	end)
end



net.Receive('rp.ItemLabCraft', function(len, pl)
	local ent = net.ReadEntity()
	local class = net.ReadUInt(8)

	if ent:GetClass() == "lab_base" and ent:GetMetal() <= 0 or ent:IsCrafting() then return end
	ent:SetMetal(ent:GetMetal()-1)
	rp.Notify(pl, NOTIFY_SUCCESS, term.Get('ItemLabCrafting'), 1,ent:GetCraftables()[class].Class)
	ent:Crafting(ent:GetCraftables()[class].Class, pl)
end)

net.Receive("rp.ItemLabRefill", function(len, ply)
	local ent = net.ReadEntity()
	--if not ply == ent.ItemOwner then return end
	local cost = rp.cfg.ItemLabMetalPrice * (rp.cfg.ItemLabMaxMetal - ent:GetMetal())
	if not ply:CanAfford(cost) then
		rp.Notify(ent.ItemOwner, NOTIFY_ERROR, term.Get("CannotAfford"))
		return
	end

	ply:AddMoney(-cost)
	ent:SetMetal(rp.cfg.ItemLabMaxMetal - ent:GetMetal())
	rp.Notify(ent.ItemOwner, NOTIFY_SUCCESS, term.Get('ItemLabRefilled'), cost, ent:GetMetal() )
end)
