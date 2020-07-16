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
	self:PhysWake()

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


function ENT:Crafting(class, namem, model)
	local time = math.random(15, 60)
	self:SetCraftTime(CurTime() + time)
	--self:SetCraftName(name)

			timer.Create(self:EntIndex() .. 'Lab', time, 1, function()
				if IsValid(self) then

			local item = ents.Create('spawned_weapon')
			item.weaponclass = class
			item:SetModel(model)
			item:SetPos(self:GetPos() + ((self:GetAngles():Up() * 40) + (self:GetAngles():Forward() * 0)))
			item:Spawn()
			item:Activate()
		end
	end)
end



net.Receive('rp.ItemLabCraft', function(len, pl)
	local ent = net.ReadEntity()
	local class = net.ReadUInt(8)
	print(class)

	if ent:GetMetal() <= 0 then return end
	ent:SetMetal(ent:GetMetal()-1)
	rp.Notify(pl, NOTIFY_SUCCESS, term.Get('ItemLabCrafting'), 1,ent:GetCraftables()[class].Class)
	ent:Crafting(ent:GetCraftables()[class].Class, ent:GetCraftables()[class].Class, ent:GetCraftables()[class].Model)
end)

net.Receive("rp.ItemLabRefill", function(len, ply)
local ent = net.ReadEntity()
--if not ply == ent.ItemOwner then return end
if not ply:CanAfford(rp.cfg.ItemLabMetalPrice * (rp.cfg.ItemLabMaxMetal - ent:GetMetal())) then
	return 	rp.Notify(ent.ItemOwner, NOTIFY_ERROR, term.Get("CannotAfford"))
end
local cost = 300
ply:AddMoney(-cost)
ent:SetMetal(ent:GetMetal()+1)
rp.Notify(ent.ItemOwner, NOTIFY_SUCCESS, term.Get('ItemLabRefilled'), cost, ent:GetMetal() )
end)